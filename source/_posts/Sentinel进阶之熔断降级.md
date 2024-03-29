---
title: Sentinel进阶之熔断降级
tags: sentinel
categories: sentinel
description: 在前文Sentinel进阶之流量控制中简单介绍了一下Sentinel的流量控制，今天就来继续说一下Sentinel的熔断降级。
abbrlink: b6bfdc75
date: 2021-06-06 19:03:25
---

【**前面的话**】在前文 [Sentinel进阶之流量](https://eelve.com/posts/2c2378a.html) 中简单介绍了一下`Sentinel`的流量控制，今天就来继续说一下Sentinel的熔断降级。

---

# 壹、概述

除了流量控制以外，对调用链路中不稳定的资源进行熔断降级也是保障高可用的重要措施之一。一个服务常常会调用别的模块，可能是另外的一个远程服务、数据库，或者第三方 API 等。例如，支付的时候，可能需要远程调用银联提供的 API；查询某个商品的价格，可能需要进行数据库查询。然而，这个被依赖服务的稳定性是不能保证的。如果依赖的服务出现了不稳定的情况，请求的响应时间变长，那么调用服务的方法的响应时间也会变长，线程会产生堆积，最终可能耗尽业务自身的线程池，服务本身也变得不可用。

![服务调用链](https://image.eelve.com/eblog/service-chain.png)

现代微服务架构都是分布式的，由非常多的服务组成。不同服务之间相互调用，组成复杂的调用链路。以上的问题在链路调用中会产生放大的效果。复杂链路上的某一环不稳定，就可能会层层级联，最终导致整个链路都不可用。因此我们需要对不稳定的`弱依赖服务调用`进行熔断降级，暂时切断不稳定调用，避免局部不稳定因素导致整体的雪崩。熔断降级作为保护自身的手段，通常在客户端（调用端）进行配置。

> Sentinel 1.8.0 及以上版本对熔断降级特性进行了全新的改进升级，我们可以选择最新版本体验降级规则熔断。

# 贰、熔断策略

Sentinel 提供以下几种熔断策略：

- 慢调用比例 (`SLOW_REQUEST_RATIO`)：选择以慢调用比例作为阈值，需要设置允许的慢调用 `RT`（即最大的响应时间），请求的响应时间大于该值则统计为慢调用。当单位统计时长（`statIntervalMs`）内请求数目大于设置的最小请求数目，并且慢调用的比例大于阈值，则接下来的熔断时长内请求会自动被熔断。经过熔断时长后熔断器会进入探测恢复状态（`HALF-OPEN 状态`），若接下来的一个请求响应时间小于设置的慢调用 `RT` 则结束熔断，若大于设置的慢调用 `RT` 则会再次被熔断。
  ~~~
  public class SlowRatioCircuitBreakerDemo {

    private static final String KEY = "some_method";

    private static volatile boolean stop = false;
    private static int seconds = 120;

    private static AtomicInteger total = new AtomicInteger();
    private static AtomicInteger pass = new AtomicInteger();
    private static AtomicInteger block = new AtomicInteger();

    public static void main(String[] args) throws Exception {
        initDegradeRule();
        registerStateChangeObserver();
        startTick();

        int concurrency = 8;
        for (int i = 0; i < concurrency; i++) {
            Thread entryThread = new Thread(() -> {
                while (true) {
                    Entry entry = null;
                    try {
                        entry = SphU.entry(KEY);
                        pass.incrementAndGet();
                        // RT: [40ms, 60ms)
                        sleep(ThreadLocalRandom.current().nextInt(40, 60));
                    } catch (BlockException e) {
                        block.incrementAndGet();
                        sleep(ThreadLocalRandom.current().nextInt(5, 10));
                    } finally {
                        total.incrementAndGet();
                        if (entry != null) {
                            entry.exit();
                        }
                    }
                }
            });
            entryThread.setName("sentinel-simulate-traffic-task-" + i);
            entryThread.start();
        }
    }

    private static void registerStateChangeObserver() {
        EventObserverRegistry.getInstance().addStateChangeObserver("logging",
            (prevState, newState, rule, snapshotValue) -> {
                if (newState == State.OPEN) {
                    System.err.println(String.format("%s -> OPEN at %d, snapshotValue=%.2f", prevState.name(),
                        TimeUtil.currentTimeMillis(), snapshotValue));
                } else {
                    System.err.println(String.format("%s -> %s at %d", prevState.name(), newState.name(),
                        TimeUtil.currentTimeMillis()));
                }
            });
    }

    private static void initDegradeRule() {
        List<DegradeRule> rules = new ArrayList<>();
        DegradeRule rule = new DegradeRule(KEY)
            .setGrade(CircuitBreakerStrategy.SLOW_REQUEST_RATIO.getType())
            // Max allowed response time
            .setCount(50)
            // Retry timeout (in second)
            .setTimeWindow(10)
            // Circuit breaker opens when slow request ratio > 60%
            .setSlowRatioThreshold(0.6)
            .setMinRequestAmount(100)
            .setStatIntervalMs(20000);
        rules.add(rule);

        DegradeRuleManager.loadRules(rules);
        System.out.println("Degrade rule loaded: " + rules);
    }

    private static void sleep(int timeMs) {
        try {
            TimeUnit.MILLISECONDS.sleep(timeMs);
        } catch (InterruptedException e) {
            // ignore
        }
    }

    private static void startTick() {
        Thread timer = new Thread(new TimerTask());
        timer.setName("sentinel-timer-tick-task");
        timer.start();
    }

    static class TimerTask implements Runnable {
        @Override
        public void run() {
            long start = System.currentTimeMillis();
            System.out.println("Begin to run! Go go go!");
            System.out.println("See corresponding metrics.log for accurate statistic data");

            long oldTotal = 0;
            long oldPass = 0;
            long oldBlock = 0;

            while (!stop) {
                sleep(1000);

                long globalTotal = total.get();
                long oneSecondTotal = globalTotal - oldTotal;
                oldTotal = globalTotal;

                long globalPass = pass.get();
                long oneSecondPass = globalPass - oldPass;
                oldPass = globalPass;

                long globalBlock = block.get();
                long oneSecondBlock = globalBlock - oldBlock;
                oldBlock = globalBlock;

                System.out.println(TimeUtil.currentTimeMillis() + ", total:" + oneSecondTotal
                    + ", pass:" + oneSecondPass + ", block:" + oneSecondBlock);

                if (seconds-- <= 0) {
                    stop = true;
                }
            }

            long cost = System.currentTimeMillis() - start;
            System.out.println("time cost: " + cost + " ms");
            System.out.println("total: " + total.get() + ", pass:" + pass.get()
                + ", block:" + block.get());
            System.exit(0);
        }
    }
  }
  ~~~
- 异常比例 (`ERROR_RATIO`)：当单位统计时长（`statIntervalMs`）内请求数目大于设置的最小请求数目，并且异常的比例大于阈值，则接下来的熔断时长内请求会自动被熔断。经过熔断时长后熔断器会进入探测恢复状态（`HALF-OPEN 状态`），若接下来的一个请求成功完成（没有错误）则结束熔断，否则会再次被熔断。异常比率的阈值范围是 `[0.0, 1.0]`，代表 `0% - 100%`。
- 异常数 (`ERROR_COUNT`)：当单位统计时长内的异常数目超过阈值之后会自动进行熔断。经过熔断时长后熔断器会进入探测恢复状态（`HALF-OPEN 状态`），若接下来的一个请求成功完成（没有错误）则结束熔断，否则会再次被熔断。

注意异常降级仅针对业务异常，对 `Sentinel` 限流降级本身的异常（`BlockException`）不生效。为了统计异常比例或异常数，需要通过 `Tracer.trace(ex)` 记录业务异常。示例：

```java
Entry entry = null;
try {
  entry = SphU.entry(resource);

  // Write your biz code here.
  // <<BIZ CODE>>
} catch (Throwable t) {
  if (!BlockException.isBlockException(t)) {
    Tracer.trace(t);
  }
} finally {
  if (entry != null) {
    entry.exit();
  }
}
```

> 开源整合模块，如 `Sentinel Dubbo Adapter`, `Sentinel Web Servlet Filter` 或 `@SentinelResource` 注解会自动统计业务异常，无需手动调用。但是如果你的程序发生异常的异常被处理过，或者异常时并不会抛出异常，则需要你自己手动调用 `Tracer.trace(ex)` 来记录业务异常。否则你的`异常比例`和`异常数`将不会生效。

# 叁、熔断降级规则说明

熔断降级规则（DegradeRule）包含下面几个重要的属性：

|Field|说明|默认值|
|----|----|----|
|resource|资源名，即规则的作用对象||
|grade|熔断策略，支持慢调用比例/异常比例/异常数策略|慢调用比例|
|count|慢调用比例模式下为慢调用临界 RT（超出该值计为慢调用）；异常比例/异常数模式下为对应的阈值|| 	
|timeWindow|熔断时长，单位为 s ||	
|minRequestAmount|熔断触发的最小请求数，请求数小于该值时即使异常比率超出阈值也不会熔断（1.7.0 引入）|5|
|statIntervalMs|统计时长（单位为 ms），如 60*1000 代表分钟级（1.8.0 引入）|1000 ms|
|slowRatioThreshold|慢调用比例阈值，仅慢调用比例模式有效（1.8.0 引入）||


# 肆、熔断器事件监听

`Sentinel` 支持注册自定义的事件监听器监听熔断器状态变换事件（state change event）。示例：

```java
EventObserverRegistry.getInstance().addStateChangeObserver("logging",
    (prevState, newState, rule, snapshotValue) -> {
        if (newState == State.OPEN) {
            // 变换至 OPEN state 时会携带触发时的值
            System.err.println(String.format("%s -> OPEN at %d, snapshotValue=%.2f", prevState.name(),
                TimeUtil.currentTimeMillis(), snapshotValue));
        } else {
            System.err.println(String.format("%s -> %s at %d", prevState.name(), newState.name(),
                TimeUtil.currentTimeMillis()));
        }
    });
```

---

【**后面的话**】[最后是我自己实践的源码](https://github.com/eelve/awesomesentinel) ,包括流量控制和初始规则加载等等。

另外在使用`API`去加载规则的时候，发现存在规则不生效的时候，通过调试发现：`Sentinel`在加载规则到内存中的时候会校验规则的合法性，如果规则不合法，该规则将不被加载。

具体可以查看`com.alibaba.csp.sentinel.property#configLoad`方法的实现类中参数校验方法，下面贴出`DegradeRule` 的校验方法


~~~

    public static boolean isValidRule(DegradeRule rule) {
        boolean baseValid = rule != null && !StringUtil.isBlank(rule.getResource())
            && rule.getCount() >= 0 && rule.getTimeWindow() > 0;
        if (!baseValid) {
            return false;
        }
        if (rule.getMinRequestAmount() <= 0 || rule.getStatIntervalMs() <= 0) {
            return false;
        }
        switch (rule.getGrade()) {
            case RuleConstant.DEGRADE_GRADE_RT:
                return rule.getSlowRatioThreshold() >= 0 && rule.getSlowRatioThreshold() <= 1;
            case RuleConstant.DEGRADE_GRADE_EXCEPTION_RATIO:
                return rule.getCount() <= 1;
            case RuleConstant.DEGRADE_GRADE_EXCEPTION_COUNT:
                return true;
            default:
                return false;
        }
    }

~~~

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
