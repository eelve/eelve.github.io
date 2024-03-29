---
title: Sentinel入门指北
tags:
  - java
  - springboot
  - sentinel
categories: sentinel
description: 在前文 浅析Spring Boot单体应用熔断技术 中对比了一下几种常见的接口熔断的技术。这里就具体使用 Sentinel 来记录以下。
abbrlink: d2ca763d
date: 2021-02-01 20:30:57
---

【**前面的话**】在前文 [浅析Spring Boot单体应用熔断技术](https://eelve.com/posts/56832225.html) 中对比了一下几种常见的接口熔断的技术。这里就具体使用 `Sentinel` 来记录以下。

---

# 壹、sentinel介绍

随着微服务的流行，服务和服务之间的稳定性变得越来越重要。`Sentinel` 是面向分布式服务架构的流量控制组件，主要以流量为切入点，从流量控制、熔断降级、系统自适应保护等多个维度来帮助您保障微服务的稳定性。

## Sentinel的基本概念基本概念包括:

### 资源 
    
资源是 `Sentinel` 的关键概念。它可以是 `Java` 应用程序中的任何内容，例如，由应用程序提供的服务，或由应用程序调用的其它应用提供的服务，甚至可以是一段代码。只要通过 `Sentinel API` 定义的代码，就是资源，能够被 `Sentinel` 保护起来。大部分情况下，可以使用方法签名，URL，甚至服务名称作为资源名来标示资源。

### 规则

围绕资源的实时状态设定的规则，可以包括流量控制规则、熔断降级规则以及系统保护规则。所有规则可以动态实时调整。

## Sentinel的主要功能

### 流量控制

流量控制在网络传输中是一个常用的概念，它用于调整网络包的发送数据。然而，从系统稳定性角度考虑，在处理请求的速度上，也有非常多的讲究。任意时间到来的请求往往是随机不可控的，而系统的处理能力是有限的。我们需要根据系统的处理能力对流量进行控制。Sentinel 作为一个调配器，可以根据需要把随机的请求调整成合适的形状，如下图所示：

![流控效果](https://image.eelve.com/eblog/sentinel-flow-overview-ca2015f6c76449e2ac74f5a377e0573d.jpg)

流量控制有以下几个角度:

- 资源的调用关系，例如资源的调用链路，资源和资源之间的关系；
- 运行指标，例如 `QPS`、线程池、系统负载等；
- 控制的效果，例如直接限流、冷启动、排队等。

Sentinel 的设计理念是让您自由选择控制的角度，并进行灵活组合，从而达到想要的效果。

### 熔断降级

除了流量控制以外，降低调用链路中的不稳定资源也是 `Sentinel` 的使命之一。由于调用关系的复杂性，如果调用链路中的某个资源出现了不稳定，最终会导致请求发生堆积。当调用链路中某个资源出现不稳定，例如，表现为 `timeout`，异常比例升高的时候，则对这个资源的调用进行限制，并让请求快速失败，避免影响到其它的资源，最终产生雪崩的效果。

降级有以下几个角度:

- 通过并发线程数进行限制

和资源池隔离的方法不同，Sentinel 通过限制资源并发线程的数量，来减少不稳定资源对其它资源的影响。这样不但没有线程切换的损耗，也不需要您预先分配线程池的大小。当某个资源出现不稳定的情况下，例如响应时间变长，对资源的直接影响就是会造成线程数的逐步堆积。当线程数在特定资源上堆积到一定的数量之后，对该资源的新请求就会被拒绝。堆积的线程完成任务后才开始继续接收请求。

- 通过响应时间对资源进行降级

除了对并发线程数进行控制以外，`Sentinel` 还可以通过响应时间来快速降级不稳定的资源。当依赖的资源出现响应时间过长后，所有对该资源的访问都会被直接拒绝，直到过了指定的时间窗口之后才重新恢复。

### 系统负载保护

Sentinel同时提供系统维度的自适应保护能力。防止雪崩，是系统防护中重要的一环。当系统负载较高的时候，如果还持续让请求进入，可能会导致系统崩溃，无法响应。在集群环境下，网络负载均衡会把本应这台机器承载的流量转发到其它的机器上去。如果这个时候其它的机器也处在一个边缘状态的时候，这个增加的流量就会导致这台机器也崩溃，最后导致整个集群不可用。

针对这个情况，`Sentinel` 提供了对应的保护机制，让系统的入口流量和系统的负载达到一个平衡，保证系统在能力范围之内处理最多的请求。

## 主要工作机制

- 对主流框架提供适配或者显示的 `API`，来定义需要保护的资源，并提供设施对资源进行实时统计和调用链路分析。
- 根据预设的规则，结合对资源的实时统计信息，对流量进行控制。同时，`Sentinel` 提供开放的接口，方便您定义及改变规则。
- `Sentinel` 提供实时的监控系统，方便您快速了解目前系统的状态。

# 贰、基础使用

## 2.1、 通过抛出异常的方式

`SphU`包含了`try-catch`风格的`API`。用这种方式，当资源发生了限流之后会抛出`BlockException`。这个时候可以捕捉异常，进行限流之后的逻辑处理。示例代码如下:

~~~java
// 资源名可使用任意有业务语义的字符串，比如方法名、接口名或其它可唯一标识的字符串。
try (Entry entry = SphU.entry("resourceName")) {
  // 被保护的业务逻辑
  // do something here...
} catch (BlockException ex) {
  // 资源访问阻止，被限流或被降级
  // 在此处进行相应的处理操作
}
~~~

> 注意：`SphU.entry(xxx)`需要与`entry.exit()`方法成对出现，匹配调用，否则会导致调用链记录异常，抛出`ErrorEntryFreeException`异常。

## 2.2、通过返回布尔值方式

`SphO`提供 `if-else` 风格的 `API`。用这种方式，当资源发生了限流之后会返回 `false`，这个时候可以根据返回值，进行限流之后的逻辑处理。示例代码如下:

~~~java
  // 资源名可使用任意有业务语义的字符串
  if (SphO.entry("自定义资源名")) {
    // 务必保证finally会被执行
    try {
      /**
      * 被保护的业务逻辑
      */
    } finally {
      SphO.exit();
    }
  } else {
    // 资源访问阻止，被限流或被降级
    // 进行相应的处理操作
  }
~~~

### 2.3、异步调用支持

`Sentinel` 支持异步调用链路的统计。在异步调用中，需要通过 `SphU.asyncEntry(xxx)` 方法定义资源，并通常需要在异步的回调函数中调用 `exit` 方法。以下是一个简单的示例：

~~~java
try {
    AsyncEntry entry = SphU.asyncEntry(resourceName);

    // 异步调用.
    doAsync(userId, result -> {
        try {
            // 在此处处理异步调用的结果.
        } finally {
            // 在回调结束后 exit.
            entry.exit();
        }
    });
} catch (BlockException ex) {
    // Request blocked.
    // Handle the exception (e.g. retry or fallback).
}
~~~

`SphU.asyncEntry(xxx)` 不会影响当前（调用线程）的 `Context`，因此以下两个 `entry` 在调用链上是平级关系（处于同一层），而不是嵌套关系：

~~~java
// 调用链类似于：
// -parent
// ---asyncResource
// ---syncResource
asyncEntry = SphU.asyncEntry(asyncResource);
entry = SphU.entry(normalResource);
~~~

若在异步回调中需要嵌套其它的资源调用（无论是 `entry` 还是 `asyncEntry`），只需要借助`Sentinel`提供的上下文切换功能，在对应的地方通过 `ContextUtil.runOnContext(context, f)` 进行 `Context` 变换，将对应资源调用处的 `Context` 切换为生成的异步 `Context`，即可维持正确的调用链路关系。示例如下：

~~~java
public void handleResult(String result) {
    Entry entry = null;
    try {
        entry = SphU.entry("handleResultForAsync");
        // Handle your result here.
    } catch (BlockException ex) {
        // Blocked for the result handler.
    } finally {
        if (entry != null) {
            entry.exit();
        }
    }
}

public void someAsync() {
    try {
        AsyncEntry entry = SphU.asyncEntry(resourceName);

        // Asynchronous invocation.
        doAsync(userId, result -> {
            // 在异步回调中进行上下文变换，通过 AsyncEntry 的 getAsyncContext 方法获取异步 Context
            ContextUtil.runOnContext(entry.getAsyncContext(), () -> {
                try {
                    // 此处嵌套正常的资源调用.
                    handleResult(result);
                } finally {
                    entry.exit();
                }
            });
        });
    } catch (BlockException ex) {
        // Request blocked.
        // Handle the exception (e.g. retry or fallback).
    }
}
~~~

此时的调用链就类似于：

~~~java
-parent
---asyncInvocation
-----handleResultForAsync
~~~

# 叁、注解使用

`Sentinel` 提供了 `@SentinelResource` 注解用于定义资源，并提供了 `AspectJ` 的扩展用于自动定义资源、处理 `BlockException` 等。使用 `Sentinel Annotation AspectJ Extension` 的时候需要引入以下依赖：

~~~xml
<dependency>
    <groupId>com.alibaba.csp</groupId>
    <artifactId>sentinel-annotation-aspectj</artifactId>
    <version>1.8.1</version>
</dependency>
~~~

> 注意：注解方式埋点不支持 private 方法。

`@SentinelResource` 用于定义资源，并提供可选的异常处理和 `fallback` 配置项。 `@SentinelResource` 注解包含以下属性：


- `value`：资源名称，必需项（不能为空）
- `entryType`：`entry` 类型，可选项（默认为 `EntryType.OUT`）
- `blockHandler` / `blockHandlerClass`: `blockHandler` 对应处理 `BlockException` 的函数名称，可选项。`blockHandler` 函数访问范围需要是 `public`，返回类型需要与原方法相匹配，参数类型需要和原方法相匹配并且最后加一个额外的参数，类型为 `BlockException`。`blockHandler` 函数默认需要和原方法在同一个类中。若希望使用其他类的函数，则可以指定 `blockHandlerClass` 为对应的类的 `Class` 对象，注意对应的函数必需为 `static` 函数，否则无法解析。
- `fallback`：`fallback` 函数名称，可选项，用于在抛出异常的时候提供 `fallback` 处理逻辑。  `fallback` 函数可以针对所有类型的异常（除了 `exceptionsToIgnore` 里面排除掉的异常类型）进行处理。`fallback` 函数签名和位置要求：
  - 返回值类型必须与原函数返回值类型一致；
  - 方法参数列表需要和原函数一致，或者可以额外多一个 `Throwable` 类型的参数用于接收对应的异常。
  - `fallback` 函数默认需要和原方法在同一个类中。若希望使用其他类的函数，则可以指定 `fallbackClass` 为对应的类的 `Class` 对象，注意对应的函数必需为 `static` 函数，否则无法解析。
- `defaultFallback`（since 1.6.0）：默认的 `fallback` 函数名称，可选项，通常用于通用的 `fallback` 逻辑（即可以用于很多服务或方法）。默认 `fallback` 函数可以针对所以类型的异常（除了 `exceptionsToIgnore` 里面排除掉的异常类型）进行处理。若同时配置了 `fallback` 和 `defaultFallback`，则只有 `fallback` 会生效。`defaultFallback` 函数签名要求：
  - 返回值类型必须与原函数返回值类型一致；
  - 方法参数列表需要为空，或者可以额外多一个 `Throwable` 类型的参数用于接收对应的异常。
  - `defaultFallback` 函数默认需要和原方法在同一个类中。若希望使用其他类的函数，则可以指定 `fallbackClass` 为对应的类的 `Class` 对象，注意对应的函数必需为 `static` 函数，否则无法解析。
- `exceptionsToIgnore`（since 1.6.0）：用于指定哪些异常被排除掉，不会计入异常统计中，也不会进入 `fallback` 逻辑中，而是会原样抛出。

> 注：1.6.0 之前的版本 `fallback` 函数只针对降级异常（`DegradeException`）进行处理，不能针对业务异常进行处理。

特别地，若 `blockHandler` 和 `fallback` 都进行了配置，则被限流降级而抛出 `BlockException` 时只会进入 `blockHandler` 处理逻辑。若未配置 `blockHandler`、`fallback` 和 `defaultFallback`，则被限流降级时会将 `BlockException` 直接抛出。

# 肆、规则的种类

`Sentinel` 的所有规则都可以在内存态中动态地查询及修改，修改之后立即生效。同时 `Sentinel` 也提供相关 `API`，供您来定制自己的规则策略。

`Sentinel` 支持以下几种规则：流量控制规则、熔断降级规则、系统保护规则、来源访问控制规则 和 热点参数规则。

## 4.1、流量控制规则 (FlowRule)
- 重要属性

|Field|说明|默认值|
|----|----|----| 	 	
|resource| 	资源名，资源名是限流规则的作用对象 |	
|count| 	限流阈值 	|
|grade| 	限流阈值类型，QPS 或线程数模式| 	QPS 模式|
|limitApp| 	流控针对的调用来源| 	default，代表不区分调用来源|
|strategy| 	调用关系限流策略：直接、链路、关联| 	根据资源本身（直接）|
|controlBehavior| 	流控效果（直接拒绝 / 排队等待 / 慢启动模式），不支持按调用关系限流| 	直接拒绝|

> 同一个资源可以同时有多个限流规则。

- 通过代码定义流量控制规则

理解上面规则的定义之后，我们可以通过调用 `FlowRuleManager.loadRules()` 方法来用硬编码的方式定义流量控制规则，比如：

~~~java
private static void initFlowQpsRule() {
    List<FlowRule> rules = new ArrayList<>();
    FlowRule rule1 = new FlowRule();
    rule1.setResource(resource);
    // Set max qps to 20
    rule1.setCount(20);
    rule1.setGrade(RuleConstant.FLOW_GRADE_QPS);
    rule1.setLimitApp("default");
    rules.add(rule1);
    FlowRuleManager.loadRules(rules);
}
~~~

## 4.2、熔断降级规则 (DegradeRule)

- 熔断降级规则包含下面几个重要的属性：

|Field| 	说明| 	默认值|
|----|----|----|
|resource 	|资源名，即规则的作用对象 	|
|grade 	|熔断策略，支持慢调用比例/异常比例/异常数策略 	|慢调用比例|
|count 	|慢调用比例模式下为慢调用临界 RT（超出该值计为慢调用）；异常比例/异常数模式下为对应的阈值 |	
|timeWindow 	|熔断时长，单位为 s |	
|minRequestAmount 	|熔断触发的最小请求数，请求数小于该值时即使异常比率超出阈值也不会熔断（1.7.0 引入） 	|5|
|statIntervalMs 	|统计时长（单位为 ms），如 60*1000 代表分钟级（1.8.0 引入） 	|1000 ms|
|slowRatioThreshold 	|慢调用比例阈值，仅慢调用比例模式有效（1.8.0 引入）|

> 同一个资源可以同时有多个降级规则

- 通过代码定义流量控制规则

理解上面规则的定义之后，我们可以通过调用 `DegradeRuleManager.loadRules()` 方法来用硬编码的方式定义流量控制规则。

~~~java
private static void initDegradeRule() {
    List<DegradeRule> rules = new ArrayList<>();
    DegradeRule rule = new DegradeRule(resource);
        .setGrade(CircuitBreakerStrategy.ERROR_RATIO.getType());
        .setCount(0.7); // Threshold is 70% error ratio
        .setMinRequestAmount(100)
        .setStatIntervalMs(30000) // 30s
        .setTimeWindow(10);
    rules.add(rule);
    DegradeRuleManager.loadRules(rules);
}
~~~

## 4.3、系统保护规则 (SystemRule)

`Sentinel` 系统自适应限流从整体维度对应用入口流量进行控制，结合应用的 `Load`、`CPU` 使用率、`总体平均 RT`、`入口 QPS` 和`并发线程数`等几个维度的监控指标，通过自适应的流控策略，让系统的入口流量和系统的负载达到一个平衡，让系统尽可能跑在最大吞吐量的同时保证系统整体的稳定性。

- 系统规则包含下面几个重要的属性

|Field 	|说明 	|默认值|
|----|----|----|
|highestSystemLoad 	|load1 触发值，用于触发自适应控制阶段 	|-1 (不生效)|
|avgRt 	|所有入口流量的平均响应时间 	|-1 (不生效)|
|maxThread 	|入口流量的最大并发数 	|-1 (不生效)|
|qps 	|所有入口资源的 QPS 	|-1 (不生效)|
|highestCpuUsage 	|当前系统的 CPU 使用率（0.0-1.0） 	|-1 (不生效)|



- 通过代码定义流量控制规则

理解上面规则的定义之后，我们可以通过调用 `SystemRuleManager.loadRules()` 方法来用硬编码的方式定义流量控制规则

~~~java
private void initSystemProtectionRule() {
  List<SystemRule> rules = new ArrayList<>();
  SystemRule rule = new SystemRule();
  rule.setHighestSystemLoad(10);
  rules.add(rule);
  SystemRuleManager.loadRules(rules);
}
~~~

## 4.4、访问控制规则 (AuthorityRule)

很多时候，我们需要根据调用方来限制资源是否通过，这时候可以使用 `Sentinel` 的访问控制（黑白名单）的功能。黑白名单根据资源的请求来源（`origin`）限制资源是否通过，若配置白名单则只有请求来源位于白名单内时才可通过；若配置黑名单则请求来源位于黑名单时不通过，其余的请求通过。

授权规则，即黑白名单规则（AuthorityRule）非常简单，主要有以下配置项：

- `resource`：资源名，即限流规则的作用对象
- `limitApp`：对应的黑名单/白名单，不同 `origin` 用 , 分隔，如 `appA`,`appB`
- `strategy`：限制模式，`AUTHORITY_WHITE` 为白名单模式，`AUTHORITY_BLACK` 为黑名单模式，默认为白名单模式

---

【**后面的话**】在使用`API`去加载规则的时候，发现存在规则不生效的时候，通过调试发现：`Sentinel`在加载规则到内存中的时候会校验规则的合法性，如果规则不合法，该规则将不被加载。

具体可以查看`com.alibaba.csp.sentinel.property#configLoad`方法的实现类中参数校验方法，下面贴出`FlowRule` 和 `Degrade`的校验方法

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

~~~java

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

> 最后是我自己实现的 [demo](https://github.com/eelve/awesomesentinel/tree/basic-sentinel) 。

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
