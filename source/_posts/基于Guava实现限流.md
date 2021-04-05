---
title: 基于Guava实现限流
date: 2021-04-03 22:06:18
tags: limiting
categories: limiting
description: 前面说过目前几种比较常见的限流的中间件，Sentinel、Hystrix和resilience4j，也提到过自己实现限流功能，今天就基于Guava实现一哈限流功能。
---

【**前情提要**】前面说过目前几种比较常见的限流的中间件，Sentinel、Hystrix和resilience4j，也提到过自己实现限流功能，今天就基于Guava实现一哈限流功能。

# 壹、Guava介绍

[Guava](https://github.com/google/guava) 是一种基于开源的Java库，其中包含谷歌正在由他们很多项目使用的很多核心库。这个库是为了方便编码，并减少编码错误。这个库提供用于集合，缓存，支持原语，并发性，常见注解，字符串处理，I/O和验证的实用方法。


[Guava](https://github.com/google/guava) 的好处

- 标准化 - Guava库是由谷歌托管。 
- 高效 - 可靠，快速和有效的扩展JAVA标准库
- 优化 -Guava库经过高度的优化。
- 函数式编程 -增加JAVA功能和处理能力。
- 实用程序 - 提供了经常需要在应用程序开发的许多实用程序类。
- 验证 -提供标准的故障安全验证机制。
- 最佳实践 - 强调最佳的做法。

下面就使用[Guava](https://github.com/google/guava) 中提供的并发相关的工具中的`RateLimiter`来实现一个限流的功能。

# 贰、引入依赖

~~~pom
dependency>
    <groupId>com.google.guava</groupId>
    <artifactId>guava</artifactId>
    <version>30.0-jre</version>
</dependency>
~~~

# 叁、拦截器方式实现

## 3.2、 定义接口

~~~java
@RequestMapping("/get")
@ResponseBody
public JsonResult allInfos(HttpServletRequest request, HttpServletResponse response, @RequestParam Integer num){
    log.info("param----->" + num);
    try {
        Thread.sleep(num*100);
        
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
    } catch (ProgramException | InterruptedException exception) {
        log.info("error");
        return JsonResult.error("error");
    }
}
~~~

## 3.2、 添加拦截器

~~~java
package com.eelve.limiting.guava.aspect;

import com.eelve.limiting.guava.vo.JsonResult;
import com.google.common.util.concurrent.RateLimiter;
import org.springframework.http.MediaType;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.nio.charset.StandardCharsets;

/**
 * @ClassName RateLimiterInterceptor
 * @Description TODO
 * @Author zhao.zhilue
 * @Date 2021/1/11 12:10
 * @Version 1.0
 **/
public class RateLimiterInterceptor extends HandlerInterceptorAdapter {
    private final RateLimiter rateLimiter;

    /**
     * 通过构造函数初始化限速器
     */
    public RateLimiterInterceptor(RateLimiter rateLimiter) {
        super();
        this.rateLimiter = rateLimiter;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

        if(this.rateLimiter.tryAcquire()) {
            /**
             * 成功获取到令牌
             */
            return true;
        }

        /**
         * 获取失败，直接响应“错误信息”
         * 也可以通过抛出异常，通过全全局异常处理器响应客户端
         */
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.getWriter().write(JsonResult.error().toString());
        return false;
    }
}

~~~

~~~java
package com.eelve.limiting.guava.configuration;

import com.eelve.limiting.guava.aspect.RateLimiterInterceptor;
import com.google.common.util.concurrent.RateLimiter;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.concurrent.TimeUnit;

/**
 * @ClassName WebMvcConfiguration
 * @Description TODO
 * @Author zhao.zhilue
 * @Date 2021/1/11 12:14
 * @Version 1.0
 **/
@Configuration
public class WebMvcConfiguration implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        /**
         * get接口，1秒钟生成1个令牌，也就是1秒中允许一个人访问
         */
        registry.addInterceptor(new RateLimiterInterceptor(RateLimiter.create(1, 1, TimeUnit.SECONDS)))
                .addPathPatterns("/get");
    }

}
~~~

> 通过上面的代码我们就可用对`/get`接口实现限流了，但是也有明显的缺点，就是规则被写死，所以下面我们通过注解方式实现。

# 肆、使用注解实现

## 4.1、定义注解

~~~java
package com.eelve.limiting.guava.annotation;

import java.lang.annotation.*;
import java.util.concurrent.TimeUnit;

/**
 * @author zhao.zhilue
 * @Description:
 * @date 2021/1/1112:27
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface MyRateLimiter {
    int NOT_LIMITED = 0;

    /**
     *
     * 资源名称
     */
    String name() default "";

    /**
     * qps
     */
    double qps() default NOT_LIMITED;

    /**
     * 获取令牌超时时长
     */
    int timeout() default 0;

    /**
     * 超时时间单位
     */
    TimeUnit timeUnit() default TimeUnit.MILLISECONDS;

    /**
     * 执行超时时长
     */
    int executeTimeout() default 0;

    /**
     * 执行超时时间单位
     */
    TimeUnit executeTimeUnit() default TimeUnit.MILLISECONDS;
}

~~~

## 4.2、添加通知

~~~java
package com.eelve.limiting.guava.aspect;

import com.eelve.limiting.guava.annotation.MyRateLimiter;
import com.eelve.limiting.guava.exception.BaseException;
import com.google.common.util.concurrent.RateLimiter;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.core.annotation.AnnotationUtils;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

/**
 * @ClassName RateLimiterAspect
 * @Description TODO
 * @Author zhao.zhilue
 * @Date 2021/1/11 12:28
 * @Version 1.0
 **/
@Slf4j
@Aspect
@Component
public class MyRateLimiterAspect {
    private static final ConcurrentMap<String, RateLimiter> RATE_LIMITER_CACHE = new ConcurrentHashMap<>();

    @Pointcut("@annotation(com.eelve.limiting.guava.annotation.MyRateLimiter)")
    public void MyRateLimit() {

    }

    @Around("MyRateLimit()")
    public Object pointcut(ProceedingJoinPoint point) throws Throwable {
        Object obj =null;
        MethodSignature signature = (MethodSignature) point.getSignature();
        Method method = signature.getMethod();
        // 通过 AnnotationUtils.findAnnotation 获取 RateLimiter 注解
        MyRateLimiter myRateLimiter = AnnotationUtils.findAnnotation(method, MyRateLimiter.class);
        if (myRateLimiter != null && myRateLimiter.qps() > MyRateLimiter.NOT_LIMITED) {
            double qps = myRateLimiter.qps();
            String name = myRateLimiter.name();
            int executeTimeout = myRateLimiter.executeTimeout();
            if(Objects.isNull(name)){
                name = method.getName();
            }
            if (RATE_LIMITER_CACHE.get(name) == null) {
                // 初始化 QPS
                RATE_LIMITER_CACHE.put(name, RateLimiter.create(qps));
            }

            log.debug("【{}】的QPS设置为: {}", method.getName(), RATE_LIMITER_CACHE.get(name).getRate());
            Long start = System.currentTimeMillis();
            // 尝试获取令牌
            if (RATE_LIMITER_CACHE.get(method.getName()) != null && !RATE_LIMITER_CACHE.get(method.getName()).tryAcquire(myRateLimiter.timeout(), myRateLimiter.timeUnit())) {
                throw new BaseException("请求频繁，请稍后再试~");
            }
            obj = point.proceed();

            Long end = System.currentTimeMillis();
            Long executeTime = end - start;
            if((end - start) >  executeTimeout){
                log.debug("请求超时，请稍后再试~" + (end - start));
                throw new BaseException("请求超时，请稍后再试~");
            }
        }
        return obj;
    }

}

~~~

> 通过上面的代码我们就实现了零活的通过注解的方式实现了限流功能，并且我们还可以在`Around`通知的时候灵活实现。包括过滤某些异常等等。

---

【**后面的话**】除了前面我们使用的`RateLimiter`之外，`Guava`还提供了专门针对超时的`SimpleTimeLimiter`组件，有兴趣的也可以尝试一下。另外以上的源码都可用在 [limiting](https://github.com/eelve/limiting/tree/master/guava) 中找到。

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
