---
title: Spring Boot单体应用集成Sentinel熔断能力
tags:
  - java
  - springboot
  - sentinel
categories: sentinel
description: 前面对Sentinel的入门知识有了一定了解之后，这里就来介绍在生产中简单的应用。
abbrlink: 1523c2c1
date: 2021-02-13 11:52:54
---


【**前面的话**】在前文 [Sentinel入门指北](https://eelve.com/posts/d2ca763d.html) 中对`Sentinel`有了简单的了解之后，下面就`Spring Boot`单体应用集成`Sentinel`做一下简单的讨论。实际上官方已经提供了 [Spring Cloud Alibaba Sentinel](https://github.com/alibaba/spring-cloud-alibaba/wiki/Sentinel) ，然后在配合 `控制台` 就可以方便使用熔断能力。但是存在部分不想引入`控制台`的场景，此文就由此而来。

---

# 壹、总体设计

`Sentinel`在官方提供了`API`用于动态修改熔断的规则，针对每种规则都有独有的`loadRules`方法：

~~~java
/**
 * Load {@link FlowRule}s, former rules will be replaced.
 *
 * @param rules new rules to load.
 */
public static void loadRules(List<FlowRule> rules) {
    currentProperty.updateValue(rules);
}
~~~

~~~java
/**
 * Load {@link DegradeRule}s, former rules will be replaced.
 *
 * @param rules new rules to load.
 */
public static void loadRules(List<DegradeRule> rules) {
    try {
        currentProperty.updateValue(rules);
    } catch (Throwable e) {
        RecordLog.error("[DegradeRuleManager] Unexpected error when loading degrade rules", e);
    }
}
~~~

`Sentiunel`还有一个缺点，就是熔断规则只缓存在内存中，当应用重启之后，规则就消失了。所以解决方法就是可以考虑讲规则持久化，官方也有相应的实现的方案：[动态规则扩展](https://sentinelguard.io/zh-cn/docs/dynamic-rule-configuration.html) 。我这里实现的方案则是将规则存在数据库中，并提供API方式修改规则。 

# 贰、实现细节 

## 2.1、pom依赖

> `sentinel-annotation-aspectj` 提供注解支持功能，并且其中包含了 `sentinel-core` 所以就不需要单独再引入了。 

~~~xml
<dependency>
    <groupId>com.alibaba.csp</groupId>
    <artifactId>sentinel-annotation-aspectj</artifactId>
    <version>1.8.0</version>
</dependency>
~~~

## 2.2、实体类

> 包括流控规则和降级规则的实体类

~~~java
package com.eelve.limiting.sentinel.entity;

import com.alibaba.csp.sentinel.slots.block.RuleConstant;
import com.alibaba.csp.sentinel.slots.block.flow.FlowRule;
import lombok.Data;

import javax.persistence.*;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

/**
 * @author zhaozhilue
 */
@Data
@Entity
@Table(name = "flow_rule")
public class FlowRuleEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name="id")
    private Integer id;

    @Column(name="app")
    private String app;


    /**
     * Resource name.
     */
    @Column(name="resource")
    @NotBlank
    private String resource;

    /**
     * <p>
     * Application name that will be limited by origin.
     * The default c is {@code default}, which means allowing all origin apps.
     * </p>
     * <p>
     * For authority rules, multiple origin name can be separated with comma (',').
     * </p>
     */
    @Column(name="limit_app")
    @NotBlank
    private String limitApp;

    /**
     * The threshold type of flow control (0: thread count, 1: QPS).
     */
    @Column(name = "grade",columnDefinition="INT default 1",nullable = false)
    @NotNull
    private Integer grade = RuleConstant.FLOW_GRADE_QPS;

    /**
     * Flow control threshold count.
     */
    @Column(name = "count")
    @NotNull
    private Double count;

    /**
     * Flow control strategy based on invocation chain.
     *
     * {@link RuleConstant#STRATEGY_DIRECT} for direct flow control (by origin);
     * {@link RuleConstant#STRATEGY_RELATE} for relevant flow control (with relevant resource);
     * {@link RuleConstant#STRATEGY_CHAIN} for chain flow control (by entrance resource).
     */
    @Column(name = "strategy",columnDefinition="INT default 0",nullable = false)
    private Integer strategy = RuleConstant.STRATEGY_DIRECT;

    /**
     * Reference resource in flow control with relevant resource or context.
     */
    @Column(name = "ref_resource")
    private String refResource;

    /**
     * Rate limiter control behavior.
     * 0. default(reject directly), 1. warm up, 2. rate limiter, 3. warm up + rate limiter
     */
    @Column(name = "control_behavior",columnDefinition="INT default 0",nullable = false)
    private Integer controlBehavior = RuleConstant.CONTROL_BEHAVIOR_DEFAULT;

    @Column(name = "warm_up_period_sec")
    private Integer warmUpPeriodSec = 10;

    /**
     * Max queueing time in rate limiter behavior.
     */
    @Column(name = "max_queueing_time_ms")
    private Integer maxQueueingTimeMs = 500;

    @Column(name = "cluster_mode",columnDefinition="BOOLEAN default false",nullable = false)
    private Boolean clusterMode = false;

    public FlowRule toRule() {
        FlowRule flowRule = new FlowRule();
        flowRule.setCount(this.count);
        flowRule.setGrade(this.grade);
        flowRule.setResource(this.resource);
        flowRule.setLimitApp(this.limitApp);
        flowRule.setRefResource(this.refResource);
        flowRule.setStrategy(this.strategy);
        if (this.controlBehavior != null) {
            flowRule.setControlBehavior(controlBehavior);
        }
        if (this.warmUpPeriodSec != null) {
            flowRule.setWarmUpPeriodSec(warmUpPeriodSec);
        }
        if (this.maxQueueingTimeMs != null) {
            flowRule.setMaxQueueingTimeMs(maxQueueingTimeMs);
        }
        flowRule.setClusterMode(clusterMode);
        return flowRule;
    }

}

~~~

~~~java
package com.eelve.limiting.sentinel.entity;

import com.alibaba.csp.sentinel.slots.block.RuleConstant;
import com.alibaba.csp.sentinel.slots.block.degrade.DegradeRule;
import lombok.Data;

import javax.persistence.*;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

/**
 * @author zhaozhilue
 */
@Data
@Entity
@Table(name = "degrade_rule")
public class DegradeRuleEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name="id")
    private Integer id;

    @Column(name="app")
    private String app;


    /**
     * Resource name.
     */
    @Column(name="resource")
    @NotBlank
    private String resource;

    /**
     * <p>
     * Application name that will be limited by origin.
     * The default limitApp is {@code default}, which means allowing all origin apps.
     * </p>
     * <p>
     * For authority rules, multiple origin name can be separated with comma (',').
     * </p>
     */
    @Column(name="limit_app")
    @NotBlank
    private String limitApp;

    /**
     * Circuit breaking strategy (0: average RT, 1: exception ratio, 2: exception count).
     */
    @Column(name = "grade",columnDefinition="INT default 0",nullable = false)
    @NotNull
    private Integer grade = RuleConstant.DEGRADE_GRADE_RT;

    /**
     * Threshold count.
     */
    @Column(name = "count")
    @NotNull
    private Double count;

    /**
     * Recovery timeout (in seconds) when circuit breaker opens. After the timeout, the circuit breaker will
     * transform to half-open state for trying a few requests.
     */
    @Column(name = "timeWindow")
    @NotNull
    private Integer timeWindow;

    /**
     * Minimum number of requests (in an active statistic time span) that can trigger circuit breaking.
     *
     * @since 1.7.0
     */
    @Column(name = "min_request_amount",columnDefinition="INT default 5",nullable = false)
    private Integer minRequestAmount = RuleConstant.DEGRADE_DEFAULT_MIN_REQUEST_AMOUNT;

    /**
     * The threshold of slow request ratio in RT mode.
     */
    @Column(name = "slow_ratio_threshold",columnDefinition="DOUBLE default 1000",nullable = false)
    private Double slowRatioThreshold = 1.0d;

    @Column(name = "stat_interval_ms",columnDefinition="INT default 1000",nullable = false)
    private Integer statIntervalMs = 1000;

    public DegradeRule toRule() {
        DegradeRule rule = new DegradeRule();
        rule.setResource(resource);
        rule.setLimitApp(limitApp);
        rule.setCount(count);
        rule.setTimeWindow(timeWindow);
        rule.setGrade(grade);
        if (minRequestAmount != null) {
            rule.setMinRequestAmount(minRequestAmount);
        }
        if (slowRatioThreshold != null) {
            rule.setSlowRatioThreshold(slowRatioThreshold);
        }
        if (statIntervalMs != null) {
            rule.setStatIntervalMs(statIntervalMs);
        }

        return rule;
    }
}
~~~

## 2.3、核心规则变更

> 主要是提供规则更新的工具类

~~~java
package com.eelve.limiting.sentinel.enums;

public enum RulesEnum {

    Flow(1),

    Degrade(2),

    System(3),

    Authority(4);



    private int code;

    RulesEnum(int code) {
        this.code = code;
    }

    public int getCode() {
        return code;
    }
}

~~~

~~~java
package com.eelve.limiting.sentinel.util;

import com.alibaba.csp.sentinel.slots.block.AbstractRule;
import com.alibaba.csp.sentinel.slots.block.authority.AuthorityRule;
import com.alibaba.csp.sentinel.slots.block.authority.AuthorityRuleManager;
import com.alibaba.csp.sentinel.slots.block.degrade.DegradeRule;
import com.alibaba.csp.sentinel.slots.block.degrade.DegradeRuleManager;
import com.alibaba.csp.sentinel.slots.block.flow.FlowRule;
import com.alibaba.csp.sentinel.slots.block.flow.FlowRuleManager;
import com.alibaba.csp.sentinel.slots.system.SystemRule;
import com.alibaba.csp.sentinel.slots.system.SystemRuleManager;
import com.eelve.limiting.sentinel.enums.RulesEnum;
import lombok.extern.java.Log;

import java.util.List;

/**
 * @author zhaozhilue
 */
@Log
public class RefreshRulesUtil {

    public static <T extends AbstractRule> void refreshRule(List<T> ruleList, RulesEnum rulesEnum){

        log.info("操作类型:"+rulesEnum.getCode() + ",ruleList:" + ruleList.toString());

        switch (rulesEnum){
            case Flow:
                FlowRuleManager.loadRules((List<FlowRule>) ruleList);
                break;
            case Degrade:
                DegradeRuleManager.loadRules((List<DegradeRule>)ruleList);
                break;
            case System:
                SystemRuleManager.loadRules((List<SystemRule>)ruleList);
                break;
            case Authority:
                AuthorityRuleManager.loadRules((List<AuthorityRule>)ruleList);
                break;
            default:
                log.info("无效操作");
                break;

        }
    }
}

~~~

## 2.4、规则更新接口

> 主要是提供接口给前端用于规则更新，并且包括更新内存中的熔断规则。

~~~java
package com.eelve.limiting.sentinel.controller;

import com.alibaba.csp.sentinel.slots.block.flow.FlowRule;
import com.eelve.limiting.sentinel.entity.FlowRuleEntity;
import com.eelve.limiting.sentinel.enums.RulesEnum;
import com.eelve.limiting.sentinel.service.iml.FlowRuleServiceImpl;
import com.eelve.limiting.sentinel.util.RefreshRulesUtil;
import com.eelve.limiting.sentinel.vo.JsonResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/eelve/flow-rule")
public class FlowRuleController {

    @Autowired
    private FlowRuleServiceImpl flowRuleService;

    @GetMapping("/rules")
    @ResponseBody
    public JsonResult allRules(HttpServletRequest request, HttpServletResponse response){
        List<FlowRule> ruleList =  flowRuleService.allRules().stream().map(x -> x.toRule()).collect(Collectors.toList());
        RefreshRulesUtil.refreshRule(ruleList, RulesEnum.Flow);
        return JsonResult.ok().put(flowRuleService.allRules());
    }

    @PostMapping("/rules")
    @ResponseBody
    public JsonResult addRule(HttpServletRequest request, HttpServletResponse response, @RequestBody FlowRuleEntity flowRuleEntity){
        /**
         * 先添加，然后再查询出来批量更新
         */
        flowRuleService.addRule(flowRuleEntity);
        List<FlowRule> ruleList =  flowRuleService.allRules().stream().map(x -> x.toRule()).collect(Collectors.toList());
        RefreshRulesUtil.refreshRule(ruleList, RulesEnum.Flow);
        return JsonResult.ok().put(flowRuleEntity);
    }

    @PutMapping("/rules")
    @ResponseBody
    public JsonResult updateRule(HttpServletRequest request, HttpServletResponse response, @RequestBody FlowRuleEntity flowRuleEntity){
        /**
         * 先添加，然后再查询出来批量更新
         */
        flowRuleService.addRule(flowRuleEntity);
        List<FlowRule> ruleList =  flowRuleService.allRules().stream().map(x -> x.toRule()).collect(Collectors.toList());
        RefreshRulesUtil.refreshRule(ruleList, RulesEnum.Flow);
        return JsonResult.ok().put(flowRuleEntity);
    }

    @DeleteMapping("/rules/{id}")
    @ResponseBody
    public JsonResult deleteRule(HttpServletRequest request, HttpServletResponse response, @PathVariable(name = "id") Integer id){
        /**
         * 先添加，然后再查询出来批量更新
         */
        flowRuleService.deleteRuleById(id);
        List<FlowRule> ruleList =  flowRuleService.allRules().stream().map(x -> x.toRule()).collect(Collectors.toList());
        RefreshRulesUtil.refreshRule(ruleList, RulesEnum.Flow);
        return JsonResult.ok();
    }
}

~~~


~~~java
package com.eelve.limiting.sentinel.controller;

import com.alibaba.csp.sentinel.slots.block.degrade.DegradeRule;
import com.eelve.limiting.sentinel.entity.DegradeRuleEntity;
import com.eelve.limiting.sentinel.enums.RulesEnum;
import com.eelve.limiting.sentinel.service.iml.DegradeRuleServiceImpl;
import com.eelve.limiting.sentinel.util.RefreshRulesUtil;
import com.eelve.limiting.sentinel.vo.JsonResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.stream.Collectors;

/**
 * @ClassName DegradeRuleController
 * @Description TODO
 * @Author zhao.zhilue
 * @Date 2021/1/29 20:18
 * @Version 1.0
 **/
@RestController
@RequestMapping("/api/eelve/degrade-rule")
public class DegradeRuleController {

    @Autowired
    private DegradeRuleServiceImpl degradeRuleService;

    @GetMapping("/rules")
    @ResponseBody
    public JsonResult allRules(HttpServletRequest request, HttpServletResponse response){
        List<DegradeRule> ruleList =  degradeRuleService.allRules().stream().map(x -> x.toRule()).collect(Collectors.toList());
        RefreshRulesUtil.refreshRule(ruleList, RulesEnum.Degrade);
        return JsonResult.ok().put(degradeRuleService.allRules());
    }

    @PostMapping("/rules")
    @ResponseBody
    public JsonResult addRule(HttpServletRequest request, HttpServletResponse response, @RequestBody DegradeRuleEntity degradeRuleEntity){
        /**
         * 先添加，然后再查询出来批量更新
         */
        degradeRuleService.addRule(degradeRuleEntity);
        List<DegradeRule> ruleList =  degradeRuleService.allRules().stream().map(x -> x.toRule()).collect(Collectors.toList());
        RefreshRulesUtil.refreshRule(ruleList, RulesEnum.Degrade);
        return JsonResult.ok().put(degradeRuleEntity);
    }

    @PutMapping("/rules")
    @ResponseBody
    public JsonResult updateRule(HttpServletRequest request, HttpServletResponse response, @RequestBody DegradeRuleEntity degradeRuleEntity){
        /**
         * 先添加，然后再查询出来批量更新
         */
        degradeRuleService.addRule(degradeRuleEntity);
        List<DegradeRule> ruleList =  degradeRuleService.allRules().stream().map(x -> x.toRule()).collect(Collectors.toList());
        RefreshRulesUtil.refreshRule(ruleList, RulesEnum.Degrade);
        return JsonResult.ok().put(degradeRuleEntity);
    }

    @DeleteMapping("/rules/{id}")
    @ResponseBody
    public JsonResult deleteRule(HttpServletRequest request, HttpServletResponse response, @PathVariable(name = "id") Integer id){
        /**
         * 先添加，然后再查询出来批量更新
         */
        degradeRuleService.deleteRuleById(id);
        List<DegradeRule> ruleList =  degradeRuleService.allRules().stream().map(x -> x.toRule()).collect(Collectors.toList());
        RefreshRulesUtil.refreshRule(ruleList, RulesEnum.Degrade);
        return JsonResult.ok();
    }
}

~~~

## 2.5、规则初始化

> 规则初始化可以使用 `Sentinel` 提供的 `SPI` 机制，实现 `com.alibaba.csp.sentinel.init#InitFunc` 接口，在接口被第一次调用时初始化，不过需要单独引入 `sentinel-datasource-extension` 。当然我们也可以直接 `Spring` 提供的 `CommandLineRunner` 或 `ApplicationRunner` 在项目启动是从数据库中加载规则。

~~~java
package com.eelve.limiting.sentinel.config;

import com.alibaba.csp.sentinel.slots.block.RuleConstant;
import com.alibaba.csp.sentinel.slots.block.degrade.DegradeRule;
import com.alibaba.csp.sentinel.slots.block.degrade.DegradeRuleManager;
import com.alibaba.csp.sentinel.slots.block.degrade.circuitbreaker.CircuitBreakerStrategy;
import com.alibaba.csp.sentinel.slots.block.flow.FlowRule;
import com.alibaba.csp.sentinel.slots.block.flow.FlowRuleManager;
import com.alibaba.csp.sentinel.slots.system.SystemRule;
import com.alibaba.csp.sentinel.slots.system.SystemRuleManager;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * @author zhaozhilue
 */
@Component
public class RuleInitFunc implements ApplicationRunner {

    @Override
    public void run(ApplicationArguments args) throws Exception {
        initFlowQpsRule();

        initDegradeRule();

        initSystemProtectionRule();
    }

    /**
     * 初始化流量规则
     */
    private static void initFlowQpsRule() {
        List<FlowRule> rules = new ArrayList<>();
        FlowRule rule1 = new FlowRule();
        rule1.setResource("allInfos");
        // Set max qps to 2
        rule1.setCount(2);
        rule1.setGrade(RuleConstant.FLOW_GRADE_QPS);
        rule1.setLimitApp("default");
        rules.add(rule1);
        FlowRuleManager.loadRules(rules);
    }

    /**
     * 初始化熔断规则
     */
    private static void initDegradeRule() {
        List<DegradeRule> rules = new ArrayList<>();
        DegradeRule rule = new DegradeRule("allInfos")
        .setGrade(CircuitBreakerStrategy.ERROR_RATIO.getType())
        .setCount(0.7) // Threshold is 70% error ratio
        .setMinRequestAmount(100)
                .setStatIntervalMs(30000) // 30s
                .setTimeWindow(10);
        rules.add(rule);
        DegradeRuleManager.loadRules(rules);
    }

    /**
     * 初始化系统保护跪着
     */
    private void initSystemProtectionRule() {
        List<SystemRule> rules = new ArrayList<>();
        SystemRule rule = new SystemRule();
        rule.setHighestSystemLoad(10);
        rules.add(rule);
        SystemRuleManager.loadRules(rules);
    }
}
~~~

> 至此简单的 `Spring Boot` 单体应用接入 `Sentinel` 的熔断能力的后端开发就完成了。然后前端再开发相应的页面，就可以给用户真正的使用了。

---

【**后面的话**】以上的接口有一点缺陷就是需要用户填写具体的熔断资源名称，但是用户实际上是有可能填写错误，从而导致熔断规则不生效。为此这里给出的解决方案是，在应用启动过程中扫描所有添加 `@SentinelResource` 注解的资源，然后再开放接口提供给前端，然后用户再填写熔断资源名称的时候就可以通过下拉来选择具体的资源名称了。

~~~java
package com.eelve.limiting.sentinel.config;

import com.alibaba.csp.sentinel.annotation.SentinelResource;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.core.annotation.AnnotationUtils;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Controller;

import javax.annotation.PostConstruct;
import java.lang.reflect.Method;
import java.util.HashSet;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/**
 * @ClassName SentinelResourcetHolder
 * @Description 扫描资源
 * @Author zhao.zhilue
 * @Date 2021/1/30 9:45
 * @Version 1.0
 **/
@Component
public class SentinelResourcetHolder implements ApplicationContextAware {

    private static final Set<String> SENTINEL_RESOURCE = new HashSet();

    public static Set<String> getSentinelResource() {
        return SENTINEL_RESOURCE;
    }

    private static ApplicationContext applicationContext = null;

    @PostConstruct
    private void inintSentinelResourcetHolder(){
        Map<String, Object> objectMap =  applicationContext.getBeansWithAnnotation(Controller.class);
        objectMap.entrySet().forEach(o -> {
            Method[] methods = o.getValue().getClass().getDeclaredMethods();
            for (Method method : methods) {
                SentinelResource sentinelResource = AnnotationUtils.findAnnotation(method, SentinelResource.class);
                if (!Objects.isNull(sentinelResource)){
                    SENTINEL_RESOURCE.add(sentinelResource.value());
                }
            }
        });
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        SentinelResourcetHolder.applicationContext = applicationContext;
    }

}

~~~

~~~java
package com.eelve.limiting.sentinel.controller;

import com.eelve.limiting.sentinel.config.SentinelResourceFactory;
import com.eelve.limiting.sentinel.config.SentinelResourcetHolder;
import com.eelve.limiting.sentinel.vo.JsonResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @ClassName SentinelResourceControl
 * @Description TODO
 * @Author zhao.zhilue
 * @Date 2021/1/31 12:31
 * @Version 1.0
 **/
@RestController
@RequestMapping("/api/eelve/sentinel/resource")
public class SentinelResourceController {

    @GetMapping
    public JsonResult getAllSentinelResourceV2(){

        return JsonResult.ok().put(SentinelResourcetHolder.getSentinelResource());
    }
}
~~~

> 只有Controller层和Service层的直接第一层方法才能通过注解触发，如果是方法再调用普通方法需要勇SphO或者SphU原生写法

~~~java
private void extractedSphO(Integer num) {
        if (SphO.entry("extractedSphO")){
            try {
                //需要保护的逻辑
            }finally {
                //需要和SphO.entry成对出现
                SphO.exit();
            }
        }else {
            //熔断之后执行的方法
            log.info("something bad with blockException");
        }
    }

    private void extractedSphU(Integer num) {
        try (Entry entry = SphU.entry("extractedSphU")) {
            //需要保护的逻辑
        } catch (BlockException ex) {
            //熔断之后执行的方法
            log.info("something bad with blockException");
        }
    }
~~~

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
