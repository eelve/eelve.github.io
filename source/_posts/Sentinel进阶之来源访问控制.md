---
title: Sentinel进阶之来源访问控制
tags: sentinel
categories: sentinel
description: 在前面几篇文章中简单介绍了一下Sentinel的功能都是针对所有的请求资源，今天就来继续说一下Sentinel的来源访问控制。
abbrlink: 3e0a90e5
date: 2021-10-03 12:08:36
---

【**前面的话**】在前面几篇文章中简单介绍了一下`Sentinel`的功能都是针对所有的请求资源，今天就来继续说一下`Sentinel`的来源访问控制。

---

# 壹、概述

很多时候，我们需要根据调用方来限制资源是否通过，这时候可以使用 `Sentinel` 的黑白名单控制的功能。黑白名单根据资源的请求来源（`origin`）限制资源是否通过，若配置白名单则只有请求来源位于白名单内时才可通过；若配置黑名单则请求来源位于黑名单时不通过，其余的请求通过。

> 调用方信息通过 `ContextUtil.enter(resourceName, origin)` 方法中的 `origin` 参数传入。

# 贰、规则配置

黑白名单规则（`AuthorityRule`）非常简单，主要有以下配置项：

- `resource`：资源名，即限流规则的作用对象
- `limitApp`：对应的黑名单/白名单，不同 `origin` 用 , 分隔，如 `appA`,`appB`
- `strategy`：限制模式，`AUTHORITY_WHITE` 为白名单模式，`AUTHORITY_BLACK` 为黑名单模式，默认为白名单模式

# 叁、示例

比如我们希望控制对资源 `test` 的访问设置白名单，只有来源为 `appA` 和 `appB` 的请求才可通过，则可以配置如下白名单规则：

```java
public class AuthorityDemo {

    private static final String RESOURCE_NAME = "testABC";

    public static void main(String[] args) {
        System.out.println("========Testing for black list========");
        initBlackRules();
        testFor(RESOURCE_NAME, "appA");
        testFor(RESOURCE_NAME, "appB");
        testFor(RESOURCE_NAME, "appC");
        testFor(RESOURCE_NAME, "appE");

        System.out.println("========Testing for white list========");
        initWhiteRules();
        testFor(RESOURCE_NAME, "appA");
        testFor(RESOURCE_NAME, "appB");
        testFor(RESOURCE_NAME, "appC");
        testFor(RESOURCE_NAME, "appE");
    }

    private static void testFor(/*@NonNull*/ String resource, /*@NonNull*/ String origin) {
        ContextUtil.enter(resource, origin);
        Entry entry = null;
        try {
            entry = SphU.entry(resource);
            System.out.println(String.format("Passed for resource %s, origin is %s", resource, origin));
        } catch (BlockException ex) {
            System.err.println(String.format("Blocked for resource %s, origin is %s", resource, origin));
        } finally {
            if (entry != null) {
                entry.exit();
            }
            ContextUtil.exit();
        }
    }

    private static void initWhiteRules() {
        AuthorityRule rule = new AuthorityRule();
        rule.setResource(RESOURCE_NAME);
        rule.setStrategy(RuleConstant.AUTHORITY_WHITE);
        rule.setLimitApp("appA,appE");
        AuthorityRuleManager.loadRules(Collections.singletonList(rule));
    }

    private static void initBlackRules() {
        AuthorityRule rule = new AuthorityRule();
        rule.setResource(RESOURCE_NAME);
        rule.setStrategy(RuleConstant.AUTHORITY_BLACK);
        rule.setLimitApp("appA,appB");
        AuthorityRuleManager.loadRules(Collections.singletonList(rule));
    }
}
```

# 肆、SpringBoot中的使用

## 4.1、限制来源token

~~~java
@Configurable
public class SentinelRequestParserConfig {

    public RequestOriginParser requestOriginParser(){
        return (httpServletRequest -> httpServletRequest.getHeader("token"));
    }
}
~~~

## 4.1、限制来源请求地址

~~~java
@Configurable
public class SentinelRequestParserConfig {

    public RequestOriginParser requestOriginParser() {
        return (httpServletRequest -> httpServletRequest.getRemoteAddr());
    }
}
~~~

---

【**后面的话**】[最后是我自己实践自定义调用链的源码](https://github.com/eelve/awesomesentinel) 。

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
