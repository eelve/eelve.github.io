---
title: 浅析Spring Boot单体应用熔断技术
tags:
  - java
  - springboot
categories: springboot
description: 最近在看服务熔断的相关技术，下面就来总结一下。
abbrlink: '56832225'
date: 2021-01-20 20:20:20
---

【**前面的话**】最近在看服务熔断的相关技术，下面就来总结一下。

# 壹、入围方案

- Sentinel
    - [github地址](https://github.com/alibaba/Sentinel)
    - [https://sentinelguard.io/zh-cn/docs/introduction.html](https://sentinelguard.io/zh-cn/docs/introduction.html)
    - 阿里出品，Spring Cloud Alibaba限流组件，目前持续更新中
    - 自带Dashboard，可以查看接口Qps等，并且可以动态修改各种规则
    - 流量控制，直接限流、冷启动、排队
    - 熔断降级，限制并发限制数和相应时间
    - 系统负载保护，提供系统级别防护，限制总体CPU等
    - 主要核心：资源，规则（流量控制规则、熔断降级规则、系统保护规则、来源访问控制规则 和 热点参数规则。），和指标
    - 文档非常清晰和详细，中文
    - 支持动态规则（推模式和拉模式）
- Hystrix
    - [github地址](https://github.com/Netflix/Hystrix)
    - [https://github.com/Netflix/Hystrix/wiki](https://github.com/Netflix/Hystrix/wiki)
    - Netflix出品，Spring Cloud Netflix限流组件，已经停止新特性开发，只进行bug修复，最近更新为2018年，功能稳定
    - 有简单的dashboard页面
    - 以隔离和熔断为主的容错机制，超时或被熔断的调用将会快速失败，并可以提供 fallback 机制的初代熔断框架，异常统计基于滑动窗口
- resilience4j
    - [github地址](https://github.com/resilience4j/resilience4j)
    - [https://resilience4j.readme.io/docs](https://resilience4j.readme.io/docs)
    - 是一款轻量、简单，并且文档非常清晰、丰富的熔断工具。是Hystrix替代品，实现思路和Hystrix一致，目前持续更新中
    - 需要自己对micrometer、prometheus以及Dropwizard metrics进行整合
    - CircuitBreaker 熔断
    - Bulkhead 隔离
    - RateLimiter QPS限制
    - Retry 重试
    - TimeLimiter 超时限制
    - Cache 缓存
- 自己实现(基于Guava)
    - 基于Guava的令牌桶，可以轻松实现对QPS进行限流

# 贰、技术对比

|                   | **Sentinel**                                           | **Hystrix**             | **resilience4j**                 | 使用Guava实现 |
| ----------------- | ------------------------------------------------------ | ----------------------- | -------------------------------- | ------------- |
| 隔离策略          | 信号量隔离（并发线程数限流）                           | 线程池隔离/信号量隔离   | 信号量隔离                       |               |
| 熔断降级策略      | 基于响应时间、异常比率、异常数                         | 基于异常比率            | 基于异常比率、响应时间           |               |
| 实时统计实现      | 滑动窗口（LeapArray）                                  | 滑动窗口（基于 RxJava） | Ring Bit Buffer                  | 令牌桶        |
| 动态规则配置      | 支持多种数据源                                         | 支持多种数据源          | 有限支持                         |               |
| 扩展性            | 多个扩展点                                             | 插件的形式              | 接口的形式                       |               |
| 基于注解的支持    | 支持                                                   | 支持                    | 支持                             | 支持          |
| 单机限流          | 基于 QPS，支持基于调用关系的限流                       | 有限的支持              | Rate Limiter                     | 基于 QPS      |
| 集群流控          | 支持                                                   | 不支持                  | 不支持                           |               |
| 流量整形          | 支持预热模式与匀速排队控制效果                         | 不支持                  | 简单的 Rate Limiter 模式         |               |
| 系统自适应保护    | 支持                                                   | 不支持                  | 不支持                           |               |
| 热点识别/防护     | 支持                                                   | 不支持                  | 不支持                           |               |
| Service Mesh 支持 | 支持 Envoy/Istio                                       | 不支持                  | 不支持                           |               |
| 控制台            | 提供开箱即用的控制台，可配置规则、实时监控、机器发现等 | 简单的监控查看          | 不提供控制台，可对接其它监控系统 |               |
| 是否支持默认规则  | 不支持，需要针对每个接口配置规则                       | 支持                    | 支持                             |               |
| 是否支持过滤异常  | 注解单个接口支持                                       | 注解和全局默认配置      | 注解和全局默认配置               |               |



# 叁、应用改造

## 3.1、sentinel

### 3.1.1、引入依赖

~~~pom
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-sentinel</artifactId>
    <version>2.0.3.RELEASE</version>
</dependency>
~~~

### 3.1.2、改造接口或者service层

> @SentinelResource(value = "allInfos",fallback = "errorReturn")

~~~java
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Inherited
public @interface SentinelResource {
    //资源名称
    String value() default "";

    //流量方向
    EntryType entryType() default EntryType.OUT;

    //资源类型
    int resourceType() default 0;

    //异常处理方法
    String blockHandler() default "";

    //异常处理类
    Class<?>[] blockHandlerClass() default {};

    //熔断方法
    String fallback() default "";

    //默认熔断方法
    String defaultFallback() default "";

    //熔断类
    Class<?>[] fallbackClass() default {};

    //统计异常
    Class<? extends Throwable>[] exceptionsToTrace() default {Throwable.class};

    //忽略异常
    Class<? extends Throwable>[] exceptionsToIgnore() default {};
}
~~~



~~~java
@RequestMapping("/get")
@ResponseBody
@SentinelResource(value = "allInfos",fallback = "errorReturn")
public JsonResult allInfos(HttpServletRequest request, HttpServletResponse response, @RequestParam Integer num){
        try {
            if (num % 2 == 0) {
                log.info("num % 2 == 0");
                throw new BaseException("something bad with 2", 400);
            }
            return JsonResult.ok();
        } catch (ProgramException e) {
            log.info("error");
            return JsonResult.error("error");
        }
    }
~~~

### 3.1.3、针对接口配置熔断方法或者限流方法

> 默认过滤拦截所有Controller接口

~~~java
/**
     * 限流，参数需要和方法保持一致
     * @param request
     * @param response
     * @param num
     * @return
     * @throws BlockException
     */
    public JsonResult errorReturn(HttpServletRequest request, HttpServletResponse response, @RequestParam Integer num) throws BlockException {
        return JsonResult.error("error 限流" + num );
    }

    /**
     * 熔断，参数需要和方法保持一直，并且需要添加BlockException异常
     * @param request
     * @param response
     * @param num
     * @param b
     * @return
     * @throws BlockException
     */
    public JsonResult errorReturn(HttpServletRequest request, HttpServletResponse response, @RequestParam Integer num,BlockException b) throws BlockException {
        return JsonResult.error("error 熔断" + num );
    }
~~~

> 注意也可以不配置限流或者熔断方法。通过全局异常去捕获**UndeclaredThrowableException**或者**BlockException**避免大量的开发量

### 3.1.4、接入dashboard

~~~yaml
spring:
  cloud:
    sentinel:
      transport:
        port: 8719
        dashboard: localhost:8080
~~~

![sentinel](https://image.eelve.com/eblog/2021012001.png)

### 3.1.5、规则持久化和动态更新

> 接入配置中心如：zookeeper等等，并对规则采用推模式

## 3.2、hystrix

### 3.2.1、引入依赖

 ~~~pom
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-hystrix-dashboard</artifactId>
    <version>2.0.4.RELEASE</version>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-hystrix</artifactId>
    <version>2.0.4.RELEASE</version>
</dependency>
 ~~~

### 3.2.2、改造接口

> @HystrixCommand(fallbackMethod = "timeOutError")

~~~java
@Target({ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Inherited
@Documented
public @interface HystrixCommand {
    String groupKey() default "";

    String commandKey() default "";

    String threadPoolKey() default "";

    String fallbackMethod() default "";

    HystrixProperty[] commandProperties() default {};

    HystrixProperty[] threadPoolProperties() default {};

    Class<? extends Throwable>[] ignoreExceptions() default {};

    ObservableExecutionMode observableExecutionMode() default ObservableExecutionMode.EAGER;

    HystrixException[] raiseHystrixExceptions() default {};

    String defaultFallback() default "";
}
~~~

~~~java
@RequestMapping("/get")
@ResponseBody
@HystrixCommand(fallbackMethod = "fallbackMethod")
public JsonResult allInfos(HttpServletRequest request, HttpServletResponse response, @RequestParam Integer num){
    try {
        if (num % 3 == 0) {
            log.info("num % 3 == 0");
            throw new BaseException("something bad whitch 3", 400);
        }

        return JsonResult.ok();
    } catch (ProgramException | InterruptedException exception) {
        log.info("error");
        return JsonResult.error("error");
    }
}
~~~

### 3.2.3、针对接口配置熔断方法

~~~java
/**
 * 该方法是熔断回调方法，参数需要和接口保持一致
 * @param request
 * @param response
 * @param num
 * @return
 */
public JsonResult fallbackMethod(HttpServletRequest request, HttpServletResponse response, @RequestParam Integer num) {
    response.setStatus(500);
    log.info("发生了熔断！！");
    return JsonResult.error("熔断");
}
~~~

### 3.2.4、配置默认策略

~~~yam
hystrix:
  command:
    default:
      execution:
        isolation:
          strategy: THREAD
          thread:
            # 线程超时15秒,调用Fallback方法
            timeoutInMilliseconds: 15000
      metrics:
        rollingStats:
          timeInMilliseconds: 15000
      circuitBreaker:
        # 10秒内出现3个以上请求(已临近阀值),并且出错率在50%以上,开启断路器.断开服务,调用Fallback方法
        requestVolumeThreshold: 3
        sleepWindowInMilliseconds: 10000
~~~

### 3.2.5、接入监控

![hystrix](https://image.eelve.com/eblog/2021012002.png)

![hystrix示意图](https://image.eelve.com/eblog/2021012003.png)

> 曲线：用来记录2分钟内流量的相对变化，我们可以通过它来观察到流量的上升和下降趋势。

> **集群监控需要用到注册中心**

## 3.3、resilience4j

### 3.3.1、引入依赖

~~~pom
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>

<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-spring-boot2</artifactId>
    <version>1.6.1</version>
</dependency>

<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-bulkhead</artifactId>
    <version>1.6.1</version>
</dependency>

<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-ratelimiter</artifactId>
    <version>1.6.1</version>
</dependency>

<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-timelimiter</artifactId>
    <version>1.6.1</version>
</dependency>
~~~

> 可以按需要引入：bulkhead，ratelimiter，timelimiter等

### 3.3.2、改造接口

~~~java
@RequestMapping("/get")
@ResponseBody
//@TimeLimiter(name = "BulkheadA",fallbackMethod = "fallbackMethod")
@CircuitBreaker(name = "BulkheadA",fallbackMethod = "fallbackMethod")
@Bulkhead(name = "BulkheadA",fallbackMethod = "fallbackMethod")
public JsonResult allInfos(HttpServletRequest request, HttpServletResponse response, @RequestParam Integer num){
    log.info("param----->" + num);
    try {
        //Thread.sleep(num);

        if (num % 2 == 0) {
            log.info("num % 2 == 0");
            throw new BaseException("something bad with 2", 400);
        }

        if (num % 3 == 0) {
            log.info("num % 3 == 0");
            throw new BaseException("something bad whitch 3", 400);
        }

        if (num % 5 == 0) {
            log.info("num % 5 == 0");
            throw new ProgramException("something bad whitch 5", 400);
        }
        if (num % 7 == 0) {
            log.info("num % 7 == 0");
            int res = 1 / 0;
        }
        return JsonResult.ok();
    } catch (BufferUnderflowException e) {
        log.info("error");
        return JsonResult.error("error");
    }
}
~~~

### 3.3.3、针对接口配置熔断方法

~~~java
/**
 * 需要参数一致，并且加上相应异常
 * @param request
 * @param response
 * @param num
 * @param exception
 * @return
 */
public JsonResult fallbackMethod(HttpServletRequest request, HttpServletResponse response, @RequestParam Integer num, BulkheadFullException exception) {
    return JsonResult.error("error 熔断" + num );
}
~~~

### 3.3.4、配置规则

~~~yaml
resilience4j.circuitbreaker:
    instances:
        backendA:
            registerHealthIndicator: true
            slidingWindowSize: 100
        backendB:
            registerHealthIndicator: true
            slidingWindowSize: 10
            permittedNumberOfCallsInHalfOpenState: 3
            slidingWindowType: TIME_BASED
            minimumNumberOfCalls: 20
            waitDurationInOpenState: 50s
            failureRateThreshold: 50
            eventConsumerBufferSize: 10
            recordFailurePredicate: io.github.robwin.exception.RecordFailurePredicate

resilience4j.retry:
    instances:
        backendA:
            maxRetryAttempts: 3
            waitDuration: 10s
            enableExponentialBackoff: true
            exponentialBackoffMultiplier: 2
            retryExceptions:
                - org.springframework.web.client.HttpServerErrorException
                - java.io.IOException
            ignoreExceptions:
                - io.github.robwin.exception.BusinessException
        backendB:
            maxRetryAttempts: 3
            waitDuration: 10s
            retryExceptions:
                - org.springframework.web.client.HttpServerErrorException
                - java.io.IOException
            ignoreExceptions:
                - io.github.robwin.exception.BusinessException

resilience4j.bulkhead:
    instances:
        backendA:
            maxConcurrentCalls: 10
        backendB:
            maxWaitDuration: 10ms
            maxConcurrentCalls: 20

resilience4j.thread-pool-bulkhead:
  instances:
    backendC:
      maxThreadPoolSize: 1
      coreThreadPoolSize: 1
      queueCapacity: 1

resilience4j.ratelimiter:
    instances:
        backendA:
            limitForPeriod: 10
            limitRefreshPeriod: 1s
            timeoutDuration: 0
            registerHealthIndicator: true
            eventConsumerBufferSize: 100
        backendB:
            limitForPeriod: 6
            limitRefreshPeriod: 500ms
            timeoutDuration: 3s

resilience4j.timelimiter:
    instances:
        backendA:
            timeoutDuration: 2s
            cancelRunningFuture: true
        backendB:
            timeoutDuration: 1s
            cancelRunningFuture: false
~~~

> 配置的规则可以被代码覆盖

### 3.3.5、配置监控

> 如grafana等

# 肆、关注点

- 是否需要过滤部分异常
- 是否需要全局默认规则
- 可能需要引入其他中间件
- k8s流量控制
- 规则存储和动态修改
- 接入改造代价

# 【**后面的话**】

个人建议的话，比较推荐sentinel，它提供了很多接口便于开发者自己拓展，同时我觉得他的规则动态更新也比较方便。最后是相关示例代码:[单体应用示例代码](https://github.com/eelve/limiting)


---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
