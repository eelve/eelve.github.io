---
title: Sentinel进阶之流量控制
tags: sentinel
categories: sentinel
description: 在前文Sentinel进阶之基本原理中简单介绍了一下Sentinel的基本原理，今天就来具体说一下Sentinel的流量控制。
abbrlink: 2c2378a
date: 2021-06-06 12:50:28
---

【**前面的话**】在前文 [Sentinel进阶之基本原理](https://eelve.com/posts/950c5430.html) 中简单介绍了一下`Sentinel`的基本原理，今天就来具体说一下`Sentinel`的流量控制。

---

壹、概述

`FlowSlot` 会根据预设的规则，结合前面 `NodeSelectorSlot`、`ClusterNodeBuilderSlot`、`StatistcSlot` 统计出来的实时信息进行流量控制。

限流的直接表现是在执行 `Entry nodeA = SphU.entry(资源名字)` 的时候抛出 `FlowException` 异常。`FlowException` 是 `BlockException` 的子类，您可以捕捉 `BlockException` 来自定义被限流之后的处理逻辑。

同一个资源可以对应多条限流规则。`FlowSlot` 会对该资源的所有限流规则依次遍历，直到有规则触发限流或者所有规则遍历完毕。

一条限流规则主要由下面几个因素组成，我们可以组合这些元素来实现不同的限流效果：

- `resource`：资源名，即限流规则的作用对象 
- `count`: 限流阈值
- `grade`: 限流阈值类型，QPS 或线程数
- `strategy`: 根据调用关系选择策略


贰、基于QPS/并发数的流量控制

流量控制主要有两种统计类型，一种是统计`线程数`，另外一种则是统计 `QPS`。类型由 `FlowRule.grade` 字段来定义。其中，`0` 代表根据并发数量来限流，`1` 代表根据 QPS 来进行流量控制。其中`线程数`、`QPS` 值，都是由 `StatisticSlot` 实时统计获取的。

可以通过下面的命令查看实时统计信息：

```
curl http://localhost:8719/cnode?id=resourceName
```
> `8719`端口可以通过配置文件修改

输出内容格式如下：

```
idx id   thread  pass  blocked   success  total Rt   1m-pass   1m-block   1m-all   exeption
2   abc647 0     46     0           46     46   1       2763      0         2763     0
```

其中：

- thread： 代表当前处理该资源的线程数；
- pass： 代表一秒内到来到的请求；
- blocked： 代表一秒内被流量控制的请求数量；
- success： 代表一秒内成功处理完的请求；
- total： 代表到一秒内到来的请求以及被阻止的请求总和；
- RT： 代表一秒内该资源的平均响应时间；
- 1m-pass： 则是一分钟内到来的请求；
- 1m-block： 则是一分钟内被阻止的请求；
- 1m-all： 则是一分钟内到来的请求和被阻止的请求的总和；
- exception： 则是一秒内业务本身异常的总和。

## 2.1、并发线程数流量控制

线程数限流用于保护业务线程数不被耗尽。例如，当应用所依赖的下游应用由于某种原因导致服务不稳定、响应延迟增加，对于调用者来说，意味着吞吐量下降和更多的线程数占用，极端情况下甚至导致线程池耗尽。为应对高线程占用的情况，业内有使用隔离的方案，比如通过不同业务逻辑使用不同线程池来隔离业务自身之间的资源争抢（线程池隔离），或者使用信号量来控制同时请求的个数（信号量隔离）。这种隔离方案虽然能够控制线程数量，但无法控制请求排队时间。当请求过多时排队也是无益的，直接拒绝能够迅速降低系统压力。Sentinel线程数限流不负责创建和管理线程池，而是简单统计当前请求上下文的线程个数，如果超出阈值，新的请求会被立即拒绝。

```java
public class FlowThreadDemo {

    private static AtomicInteger pass = new AtomicInteger();
    private static AtomicInteger block = new AtomicInteger();
    private static AtomicInteger total = new AtomicInteger();
    private static AtomicInteger activeThread = new AtomicInteger();

    private static volatile boolean stop = false;
    private static final int threadCount = 100;

    private static int seconds = 60 + 40;
    private static volatile int methodBRunningTime = 2000;

    public static void main(String[] args) throws Exception {
        System.out.println(
            "MethodA will call methodB. After running for a while, methodB becomes fast, "
                + "which make methodA also become fast ");
        tick();
        initFlowRule();

        for (int i = 0; i < threadCount; i++) {
            Thread entryThread = new Thread(new Runnable() {
                @Override
                public void run() {
                    while (true) {
                        Entry methodA = null;
                        try {
                            TimeUnit.MILLISECONDS.sleep(5);
                            methodA = SphU.entry("methodA");
                            activeThread.incrementAndGet();
                            Entry methodB = SphU.entry("methodB");
                            TimeUnit.MILLISECONDS.sleep(methodBRunningTime);
                            methodB.exit();
                            pass.addAndGet(1);
                        } catch (BlockException e1) {
                            block.incrementAndGet();
                        } catch (Exception e2) {
                            // biz exception
                        } finally {
                            total.incrementAndGet();
                            if (methodA != null) {
                                methodA.exit();
                                activeThread.decrementAndGet();
                            }
                        }
                    }
                }
            });
            entryThread.setName("working thread");
            entryThread.start();
        }
    }

    private static void initFlowRule() {
        List<FlowRule> rules = new ArrayList<FlowRule>();
        FlowRule rule1 = new FlowRule();
        rule1.setResource("methodA");
        // set limit concurrent thread for 'methodA' to 20
        rule1.setCount(20);
        rule1.setGrade(RuleConstant.FLOW_GRADE_THREAD);
        rule1.setLimitApp("default");

        rules.add(rule1);
        FlowRuleManager.loadRules(rules);
    }

    private static void tick() {
        Thread timer = new Thread(new TimerTask());
        timer.setName("sentinel-timer-task");
        timer.start();
    }

    static class TimerTask implements Runnable {

        @Override
        public void run() {
            long start = System.currentTimeMillis();
            System.out.println("begin to statistic!!!");

            long oldTotal = 0;
            long oldPass = 0;
            long oldBlock = 0;

            while (!stop) {
                try {
                    TimeUnit.SECONDS.sleep(1);
                } catch (InterruptedException e) {
                }
                long globalTotal = total.get();
                long oneSecondTotal = globalTotal - oldTotal;
                oldTotal = globalTotal;

                long globalPass = pass.get();
                long oneSecondPass = globalPass - oldPass;
                oldPass = globalPass;

                long globalBlock = block.get();
                long oneSecondBlock = globalBlock - oldBlock;
                oldBlock = globalBlock;

                System.out.println(seconds + " total qps is: " + oneSecondTotal);
                System.out.println(TimeUtil.currentTimeMillis() + ", total:" + oneSecondTotal
                    + ", pass:" + oneSecondPass
                    + ", block:" + oneSecondBlock
                    + " activeThread:" + activeThread.get());
                if (seconds-- <= 0) {
                    stop = true;
                }
                if (seconds == 40) {
                    System.out.println("method B is running much faster; more requests are allowed to pass");
                    methodBRunningTime = 20;
                }
            }

            long cost = System.currentTimeMillis() - start;
            System.out.println("time cost: " + cost + " ms");
            System.out.println("total:" + total.get() + ", pass:" + pass.get()
                + ", block:" + block.get());
            System.exit(0);
        }
    }
}
```

## 2.2、QPS流量控制

当 `QPS` 超过某个阈值的时候，则采取措施进行流量控制。流量控制的手段包括下面 3 种，对应 `FlowRule` 中的 `controlBehavior` 字段：

- 1、直接拒绝（`RuleConstant.CONTROL_BEHAVIOR_DEFAULT`）方式。该方式是默认的流量控制方式，当`QPS`超过任意规则的阈值后，新的请求就会被立即拒绝，拒绝方式为抛出`FlowException`。这种方式适用于对系统处理能力确切已知的情况下，比如通过压测确定了系统的准确水位时。

- 2、冷启动（`RuleConstant.CONTROL_BEHAVIOR_WARM_UP`）方式。该方式主要用于系统长期处于低水位的情况下，当流量突然增加时，直接把系统拉升到高水位可能瞬间把系统压垮。通过"冷启动"，让通过的流量缓慢增加，在一定时间内逐渐增加到阈值上限，给冷系统一个预热的时间，避免冷系统被压垮的情况。

    通常冷启动的过程系统允许通过的 QPS 曲线如下图所示：
    ![冷启动](https://image.eelve.com/eblog/warmup.gif)

- 3、匀速器（`RuleConstant.CONTROL_BEHAVIOR_RATE_LIMITER`）方式。这种方式严格控制了请求通过的间隔时间，也即是让请求以均匀的速度通过，对应的是漏桶算法。
    
    ![排队](https://image.eelve.com/eblog/queue.gif)

    这种方式主要用于处理间隔性突发的流量，例如消息队列。想象一下这样的场景，在某一秒有大量的请求到来，而接下来的几秒则处于空闲状态，我们希望系统能够在接下来的空闲期间逐渐处理这些请求，而不是在第一秒直接拒绝多余的请求。

叁、基于调用关系的流量控制

调用关系包括调用方、被调用方；方法又可能会调用其它方法，形成一个调用链路的层次关系。`Sentinel` 通过 `NodeSelectorSlot` 建立不同资源间的调用的关系，并且通过 `ClusterNodeBuilderSlot` 记录每个资源的实时统计信息。

有了调用链路的统计信息，我们可以衍生出多种流量控制手段。

## 3.1 根据调用方限流

`ContextUtil.enter(resourceName, origin)` 方法中的 `origin` 参数标明了调用方身份。这些信息会在 `ClusterBuilderSlot` 中被统计。可通过以下命令来展示不同的调用方对同一个资源的调用数据：

~~~
curl http://localhost:8719/origin?id=nodeA
~~~

调用数据示例：

~~~
id: nodeA
idx origin  threadNum passedQps blockedQps totalQps aRt   1m-passed 1m-blocked 1m-total 
1   caller1 0         0         0          0        0     0         0          0
2   caller2 0         0         0          0        0     0         0          0
~~~

上面这个命令展示了资源名为 `nodeA` 的资源被两个不同的调用方调用的统计。

限流规则中的 `limitApp` 字段用于根据调用方进行流量控制。该字段的值有以下三种选项，分别对应不同的场景：

- `default`：表示不区分调用者，来自任何调用者的请求都将进行限流统计。如果这个资源名的调用总和超过了这条规则定义的阈值，则触发限流。
- `{some_origin_name}`：表示针对特定的调用者，只有来自这个调用者的请求才会进行流量控制。例如 `NodeA` 配置了一条针对调用者`caller1`的规则，那么当且仅当来自 `caller1` 对 `NodeA` 的请求才会触发流量控制。
- `other`：表示针对除 `{some_origin_name}` 以外的其余调用方的流量进行流量控制。例如，资源`NodeA`配置了一条针对调用者 `caller1` 的限流规则，同时又配置了一条调用者为 `other` 的规则，那么任意来自非 `caller1` 对 `NodeA` 的调用，都不能超过 `other` 这条规则定义的阈值。

> 同一个资源名可以配置多条规则，规则的生效顺序为：{some_origin_name} > other > default

## 3.2 根据调用链路入口限流：链路限流

`NodeSelectorSlot` 中记录了资源之间的调用链路，这些资源通过调用关系，相互之间构成一棵调用树。这棵树的根节点是一个名字为 `machine-root` 的虚拟节点，调用链的入口都是这个虚节点的子节点。

一棵典型的调用树如下图所示：

~~~
     	          machine-root
                    /       \
                   /         \
             Entrance1     Entrance2
                /             \
               /               \
      DefaultNode(nodeA)   DefaultNode(nodeA)
~~~

上图中来自入口 `Entrance1` 和 `Entrance2` 的请求都调用到了资源 `NodeA`，`Sentinel` 允许只根据某个入口的统计信息对资源限流。比如我们可以设置 `FlowRule.strategy` 为 `RuleConstant.CHAIN`，同时设置 `FlowRule.ref_identity` 为 `Entrance1` 来表示只有从入口 `Entrance1` 的调用才会记录到 `NodeA` 的限流统计当中，而对来自 `Entrance2` 的调用漠不关心。

调用链的入口是通过 `API` 方法 `ContextUtil.enter(name)` 定义的。

## 3.3 具有关系的资源流量控制：关联流量控制

当两个资源之间具有资源争抢或者依赖关系的时候，这两个资源便具有了关联。比如对数据库同一个字段的读操作和写操作存在争抢，读的速度过高会影响写得速度，写的速度过高会影响读的速度。如果放任读写操作争抢资源，则争抢本身带来的开销会降低整体的吞吐量。可使用关联限流来避免具有关联关系的资源之间过度的争抢，举例来说，`read_db` 和 `write_db` 这两个资源分别代表数据库读写，我们可以给 `read_db` 设置限流规则来达到写优先的目的：设置 `FlowRule.strategy` 为 `RuleConstant.RELATE` 同时设置 `FlowRule.ref_identity` 为 `write_db`。这样当写库操作过于频繁时，读数据的请求会被限流。

---

【**后面的话**】[最后是我自己实践的源码](https://github.com/eelve/awesomesentinel) ,包括流量控制和初始规则加载等等。

另外在使用`API`去加载规则的时候，发现存在规则不生效的时候，通过调试发现：`Sentinel`在加载规则到内存中的时候会校验规则的合法性，如果规则不合法，该规则将不被加载。

具体可以查看`com.alibaba.csp.sentinel.property#configLoad`方法的实现类中参数校验方法，下面贴出`FlowRule` 的校验方法

~~~

    /**
     * Check whether provided flow rule is valid.
     *
     * @param rule flow rule to check
     * @return true if valid, otherwise false
     */
    public static boolean isValidRule(FlowRule rule) {
        boolean baseValid = rule != null && !StringUtil.isBlank(rule.getResource()) && rule.getCount() >= 0
            && rule.getGrade() >= 0 && rule.getStrategy() >= 0 && rule.getControlBehavior() >= 0;
        if (!baseValid) {
            return false;
        }
        // Check strategy and control (shaping) behavior.
        return checkClusterField(rule) && checkStrategyField(rule) && checkControlBehaviorField(rule);
    }

    private static boolean checkClusterField(/*@NonNull*/ FlowRule rule) {
        if (!rule.isClusterMode()) {
            return true;
        }
        ClusterFlowConfig clusterConfig = rule.getClusterConfig();
        if (clusterConfig == null) {
            return false;
        }
        if (!validClusterRuleId(clusterConfig.getFlowId())) {
            return false;
        }
        if (!isWindowConfigValid(clusterConfig.getSampleCount(), clusterConfig.getWindowIntervalMs())) {
            return false;
        }
        switch (clusterConfig.getStrategy()) {
            case ClusterRuleConstant.FLOW_CLUSTER_STRATEGY_NORMAL:
                return true;
            default:
                return false;
        }
    }

    public static boolean isWindowConfigValid(int sampleCount, int windowIntervalMs) {
        return sampleCount > 0 && windowIntervalMs > 0 && windowIntervalMs % sampleCount == 0;
    }

    private static boolean checkStrategyField(/*@NonNull*/ FlowRule rule) {
        if (rule.getStrategy() == RuleConstant.STRATEGY_RELATE || rule.getStrategy() == RuleConstant.STRATEGY_CHAIN) {
            return StringUtil.isNotBlank(rule.getRefResource());
        }
        return true;
    }

    private static boolean checkControlBehaviorField(/*@NonNull*/ FlowRule rule) {
        switch (rule.getControlBehavior()) {
            case RuleConstant.CONTROL_BEHAVIOR_WARM_UP:
                return rule.getWarmUpPeriodSec() > 0;
            case RuleConstant.CONTROL_BEHAVIOR_RATE_LIMITER:
                return rule.getMaxQueueingTimeMs() > 0;
            case RuleConstant.CONTROL_BEHAVIOR_WARM_UP_RATE_LIMITER:
                return rule.getWarmUpPeriodSec() > 0 && rule.getMaxQueueingTimeMs() > 0;
            default:
                return true;
        }
    }

~~~

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)

