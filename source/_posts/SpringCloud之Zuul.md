---
title: SpringCloud之Zuul
tags: Zuul
categories: SpringCloud
description: >-
  书接上文，前面已经讲过了SpringCloud的注册中心Eureka、Ribbon和Feign等等，如果有不清楚的也可以去看看我的微服务系列文章。这篇文章我要说的是微服务中的网关。
abbrlink: 1adb8023
date: 2019-08-31 13:36:49
---

【**前面的话**】书接上文，前面已经讲过了SpringCloud的注册中心Eureka、Ribbon和Feign等等，如果有不清楚的也可以去看看我的[微服务系列文章](https://eelve.com/tags/springcloud#blog)。这篇文章我要说的是微服务中的网关。

---

# 壹、Zuul的简介
Zuul的主要功能是路由转发和过滤器。路由功能是微服务的一部分，比如／api/user转发到到user服务，/api/shop转发到到shop服务。zuul默认和Ribbon结合实现了负载均衡的功能。

zuul有以下功能：

    Authentication
    Insights
    Stress Testing
    Canary Testing
    Dynamic Routing
    Service Migration
    Load Shedding
    Security
    Static Response handling
    Active/Active traffic management


# 贰、准备工作
新建一个feign子工程**lovin-cloud-zuul**，用于后面的操作。下面是主要的pom依赖:

~~~pom
<parent>
        <artifactId>lovincloud</artifactId>
        <groupId>com.eelve.lovincloud</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>lovin-cloud-zuul</artifactId>
    <packaging>jar</packaging>
    <name>lovincloudzuul</name>
    <version>0.0.1</version>
    <description>zuul</description>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zuul</artifactId>
            <version>1.4.7.RELEASE</version>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-config</artifactId>
            <version>2.1.3.RELEASE</version>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
~~~

- 这里为了安全，我这里还是添加**spring-boot-starter-security**，同时配置路由规则发送/api-ribbon/打头开始的服务转发到lovinribbonclient而发送/api-feign/打头的服务转发到lovinfeignclient，可以看出这里是配置相应的路由规则。

~~~yaml
server:
  port: 8882   # 服务端口号
spring:
  application:
    name: lovincloudzuul     # 服务名称
  security:
    basic:
      enabled: true
    user:
      name: lovin
      password: ${REGISTRY_SERVER_PASSWORD:lovin}
zuul:
  routes:
    api-ribbon:
      path: /api-ribbon/**
      serviceId: lovinribbonclient
    api-feign:
      path: /api-feign/**
      serviceId: lovinfeignclient
eureka:
  client:
    serviceUrl:
      defaultZone: http://lovin:lovin@localhost:8881/eureka/   # 注册到的eureka服务地址
  instance:
    leaseRenewalIntervalInSeconds: 10
    health-check-url-path: /actuator/health
    metadata-map:
      user.name: lovin
      user.password: lovin
~~~

- 配置**spring-boot-starter-security**，这里为了方便我这里放开所有请求

~~~java
package com.eelve.lovin.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

/**
 * @ClassName WebSecurityConfig
 * @Description TDO
 * @Author zhao.zhilue
 * @Date 2019/8/18 12:17
 * @Version 1.0
 **/
@Configuration
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests().anyRequest().permitAll()
                .and().csrf().disable();
    }
}
~~~

- 在主类上添加**@EnableZuulProxy** ，当然也需要注册到注册中心：

~~~java
package com.eelve.lovin;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
import org.springframework.cloud.netflix.zuul.EnableZuulProxy;

/**
 * @ClassName LovinEurekaClientApplication
 * @Description TDO
 * @Author zhao.zhilue
 * @Date 2019/8/15 16:37
 * @Version 1.0
 **/
@EnableZuulProxy
@EnableEurekaClient
@SpringBootApplication
public class LovinCloudZuulApplication {
    public static void main(String[] args) {
        SpringApplication.run(LovinCloudZuulApplication.class,args);
    }
}
~~~

- 这里为了方便测试，这里配置相应的过滤规则：

~~~java
package com.eelve.lovin.filter;

import com.netflix.zuul.ZuulFilter;
import com.netflix.zuul.context.RequestContext;
import com.netflix.zuul.exception.ZuulException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;

/**
 * @ClassName MyFilter
 * @Description TDO
 * @Author zhao.zhilue
 * @Date 2019/8/18 12:44
 * @Version 1.0
 **/
@Component
@RefreshScope // 使用该注解的类，会在接到SpringCloud配置中心配置刷新的时候，自动将新的配置更新到该类对应的字段中。
@Slf4j
public class MyFilter extends ZuulFilter {

    @Override
    public String filterType() {
        return "pre";
    }

    @Override
    public int filterOrder() {
        return 0;
    }

    @Override
    public boolean shouldFilter() {
        return true;
    }

    @Override
    public Object run() throws ZuulException {
        RequestContext ctx = RequestContext.getCurrentContext();
        HttpServletRequest request = ctx.getRequest();
        log.info(String.format("%s >>> %s", request.getMethod(), request.getRequestURL().toString()));
        Object accessToken = request.getParameter("token");
        if(accessToken == null) {
            log.warn("token is empty");
            ctx.setSendZuulResponse(false);
            ctx.setResponseStatusCode(401);
            try {
                ctx.getResponse().getWriter().write("token is empty");
            }catch (Exception e){}

            return null;
        }else if(!accessToken.equals("lovin")){
            log.warn("token is not correct");
            ctx.setSendZuulResponse(false);
            ctx.setResponseStatusCode(403);
            try {
                ctx.getResponse().getWriter().write("token is not correct");
            }catch (Exception e){}

            return null;
        }
        log.info("ok");
        return null;
    }
}
~~~

~~~
    filterType：返回一个字符串代表过滤器的类型，在zuul中定义了四种不同生命周期的过滤器类型，具体如下：
        pre：路由之前
        routing：路由之时
        post： 路由之后
        error：发送错误调用
    filterOrder：过滤的顺序
    shouldFilter：这里可以写逻辑判断，是否要过滤，本文true,永远过滤。
    run：过滤器的具体逻辑。可用很复杂，包括查sql，nosql去判断该请求到底有没有权限访问。
~~~

# 叁、启动测试

- 依次启动eureka的服务端和两个客户端和lovin-feign-client、lovin-ribbon-client，以及新建的lovin-cloud-zuul

- 然后访问http://localhost:8882/api-feign/getHello和http://localhost:8882/api-ribbon/hello，然后我们可以带上token访问来验证过滤器

![zuul网关转发结果](https://i.loli.net/2019/08/29/469cLCIQ5bqBYW3.png)
![zuul网关转发结果](https://i.loli.net/2019/08/29/RH3YL1d4AErNkmD.png)
![zuul网关转发结果](https://i.loli.net/2019/08/29/DcRArv7pPim2Un8.png)
![zuul网关转发结果](https://i.loli.net/2019/08/29/PGxQ2aNMTrwBSp4.png)
![zuul网关转发结果](https://i.loli.net/2019/08/29/Aiwtnp2hmP54TBk.png)
![zuul网关转发结果](https://i.loli.net/2019/08/29/KPVOL8F1fQ62Dbc.png)
![zuul网关转发结果](https://i.loli.net/2019/08/29/vPWgiHhFTkY42Nw.png)
![zuul网关转发结果](https://i.loli.net/2019/08/29/4HB1qdz3YpQiAcj.png)

# 肆、网络架构

- 我们可以看到我们调用的服务不再是像再上一篇文章中的直接访问对应的服务，而是通过feign的Ribbon的负载均衡的去调用的，而且这里说明一点，Ribbon的默认机制是轮询。
![目前的网络架构](https://i.loli.net/2019/08/29/8TRhYSej5afF9Cs.png)


---

* [最后的最后是本博客的源码,欢迎关注这一套SpringCloud的实践](https://github.com/lovinstudio/lovincloud)



---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
