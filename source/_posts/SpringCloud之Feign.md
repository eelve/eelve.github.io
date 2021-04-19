---
title: SpringCloud之Feign
tags: Feign
categories: SpringCloud
description: >-
  书接上文，本文的某些知识依赖我的第一篇SpringCLoud的文章：SpringCloud之Eureka，如果没有看过可以先移步去看一下。另外在微服务架构中，业务都会被拆分成一个个独立的服务，服务与服务的通讯是基于http
  restful的。Spring
  cloud有两种服务调用方式，一种是ribbon+restTemplate，另一种是feign。上一篇文章已经讲过ribbon+rest这种方式了，这一片博文主要讲feign的应用。
abbrlink: d9b4a7e3
date: 2019-08-24 17:26:17
---

【**前面的话**】书接上文，本文的某些知识依赖我的第一篇SpringCLoud的文章：[SpringCloud之Eureka](https://eelve.com/archives/SpringCloudEureka)，如果没有看过可以先移步去看一下。另外在微服务架构中，业务都会被拆分成一个个独立的服务，服务与服务的通讯是基于http restful的。Spring cloud有两种服务调用方式，一种是ribbon+restTemplate，另一种是feign。上一篇文章已经讲过[ribbon+rest](https://eelve.com/archives/SpringCloudRibbon)这种方式了，这一片博文主要讲feign的应用。

---
# 壹、Feign的简介
Feign是一个声明式的伪Http客户端，它使得写Http客户端变得更简单。使用Feign，只需要创建一个接口并注解。它具有可插拔的注解特性，可使用Feign 注解和JAX-RS注解。Feign支持可插拔的编码器和解码器。Feign默认集成了Ribbon，并和Eureka结合，默认实现了负载均衡的效果。

简而言之：
- Feign 采用的是基于接口的注解
- Feign 整合了ribbon

# 贰、准备工作
新建一个feign子工程**lovin-feign-client**，用于后面的操作。下面是主要的pom依赖:
~~~pom
<parent>
        <artifactId>lovincloud</artifactId>
        <groupId>com.eelve.lovincloud</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>lovin-feign-client</artifactId>
    <version>0.0.1</version>
    <name>lovinfeignclient</name>
    <description>feignclient测试</description>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-hystrix</artifactId>
            <version>1.4.7.RELEASE</version>
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
- 这里为了安全，我这里还是添加**spring-boot-starter-security**
~~~yaml
server:
  port: 8806   # 服务端口号
spring:
  application:
    name: lovinfeignclient     # 服务名称
  security:
    basic:
      enabled: true
    user:
      name: lovin
      password: ${REGISTRY_SERVER_PASSWORD:lovin}
eureka:
  client:
    serviceUrl:
      defaultZone: http://lovin:lovin@localhost:8881/eureka/   # 注册到的eureka服务地址
feign:
  hystrix:
    enabled: true
~~~
- 配置**spring-boot-starter-security**，这里为了方便我这里放开所有请求
~~~java
package com.eelve.lovin.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

/**
 * @ClassName SecurityConfig
 * @Description TDO
 * @Author zhao.zhilue
 * @Date 2019/8/16 14:13
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
- 在主类上添加**@EnableFeignClients**和**@EnableHystrix** ，当然也需要注册到注册中心：
~~~java
package com.eelve.lovin;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.netflix.hystrix.EnableHystrix;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * @ClassName LovinFeignClientApplication
 * @Description TDO
 * @Author zhao.zhilue
 * @Date 2019/8/15 17:17
 * @Version 1.0
 **/
@SpringBootApplication
@EnableFeignClients
@EnableDiscoveryClient
@EnableHystrix
public class LovinFeignClientApplication {
    public static void main(String[] args) {
        SpringApplication.run(LovinFeignClientApplication.class,args);
    }
}
~~~
- 添加一个远程调用的服务端**FeignRemoteService**，并且配置feign调用信息：
~~~java
package com.eelve.lovin.service;

import com.eelve.lovin.hystrix.FeignRemoteServiceImpl;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

/**
 * @ClassName FeignRemoteService
 * @Description TDO
 * @Author zhao.zhilue
 * @Date 2019/8/15 17:18
 * @Version 1.0
 **/
@FeignClient(value = "lovineurkaclient",fallback = FeignRemoteServiceImpl.class)
public interface FeignRemoteService {

    @RequestMapping(value = "/hello",method = RequestMethod.GET)
    public String hello();
}
~~~
- 添加熔断器调用方法：新建**FeignRemoteServiceImpl**实现**FeignRemoteService**接口：
~~~java
package com.eelve.lovin.hystrix;

import com.eelve.lovin.service.FeignRemoteService;
import org.springframework.stereotype.Component;

/**
 * @ClassName FeignRemoteServiceImpl
 * @Description TDO
 * @Author zhao.zhilue
 * @Date 2019/8/15 17:31
 * @Version 1.0
 **/
@Component
public class FeignRemoteServiceImpl implements FeignRemoteService {
    @Override
    public String hello() {
        return "hystrix起作用了";
    }
}
~~~
- 最后新建**FeignController**，来消费服务：
~~~java
package com.eelve.lovin.controller;

import com.eelve.lovin.service.FeignRemoteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * @ClassName FeignController
 * @Description TDO
 * @Author zhao.zhilue
 * @Date 2019/8/15 17:21
 * @Version 1.0
 **/
@RestController
public class FeignController {

    @Autowired
    FeignRemoteService feignRemoteService;

    @GetMapping(value = "/getHello")
    public String getHello() {
        return feignRemoteService.hello();
    }
}
~~~
# 叁、启动测试
- 依次启动eureka的服务端和两个客户端，以及新建的lovin-feign-client
![我们可以看到服务已经全部启动成功](https://i.loli.net/2019/08/23/oJn64HIfmOiVgEP.png)
我们可以看到服务已经全部启动成功
- 然后访问http://localhost:8806/getHello
![我们可以看到已经可以通过feign调到我们建立的eureka客户端了](https://i.loli.net/2019/08/23/4bcgtQXkzpM8Pa5.png)
我们可以看到已经可以通过feign调到我们建立的eureka客户端了
- 再次请求接口观察返回
![我们可以看到我们调到了通过feign调用ribbon负载的另外一个接口](https://i.loli.net/2019/08/23/2XluV6WkwLZFhMp.png)
我们可以看到我们调到了通过feign调用ribbon负载的另外一个接口了，到这里我们就已经弄好了一个简单的ribbon负载。

# 肆、添加Hystrix Dashboard断路器监控
- 添加需要的pom依赖
~~~pom
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-hystrix-dashboard</artifactId>
    <version>2.1.2.RELEASE</version>
</dependency>
~~~
- 在主类上添加**@EnableHystrixDashboard**，开启断路器监控，并且配置**HystrixMetricsStreamServlet**
~~~java
package com.eelve.lovin;

import com.netflix.hystrix.contrib.metrics.eventstream.HystrixMetricsStreamServlet;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.netflix.hystrix.EnableHystrix;
import org.springframework.cloud.netflix.hystrix.dashboard.EnableHystrixDashboard;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.Bean;

/**
 * @ClassName LovinFeignClientApplication
 * @Description TDO
 * @Author zhao.zhilue
 * @Date 2019/8/15 17:17
 * @Version 1.0
 **/
@SpringBootApplication
@EnableFeignClients
@EnableDiscoveryClient
@EnableHystrix
@EnableHystrixDashboard
public class LovinFeignClientApplication {
    public static void main(String[] args) {
        SpringApplication.run(LovinFeignClientApplication.class,args);
    }

    @Bean
    public ServletRegistrationBean getServlet(){
        HystrixMetricsStreamServlet streamServlet = new HystrixMetricsStreamServlet();
        ServletRegistrationBean registrationBean = new ServletRegistrationBean(streamServlet);
        registrationBean.setLoadOnStartup(1);
        registrationBean.addUrlMappings("/actuator/hystrix.stream");
        registrationBean.setName("HystrixMetricsStreamServlet");
        return registrationBean;
    }
}
~~~
- 访问http://localhost:8806/hystrix
![首页](https://i.loli.net/2019/08/23/eNHrkInUTGaA9jy.png)
这里我们通过首页可以看到：
~~~
默认的集群监控：通过URL http://turbine-hostname:port/turbine.stream开启，实现对默认集群的监控。
指定的集群监控：通过URL http://turbine-hostname:port/turbine.stream?cluster=[clusterName]开启，实现对clusterName的监控。
单体应用监控：通过URL http://hystrix-app:port/hystrix.stream开启，实现对某个具体的服务监控
~~~
- 添加监控模式查看详情，这里选择第三个单体应用

![添加监控接口](https://i.loli.net/2019/08/23/MF4lAGB7p8EXuOm.png)
![监控详情](https://i.loli.net/2019/08/23/y1IqLFz2DbjZUNo.png)
这样我们就完成了熔断器的监控，当然具体含义有待下一步深究。
# 伍、网络架构
- 我们可以看到我们调用的服务不再是像再上一篇文章中的直接访问对应的服务，而是通过feign的Ribbon的负载均衡的去调用的，而且这里说明一点，Ribbon的默认机制是轮询。
![目前的网络架构](https://i.loli.net/2019/08/23/7oVYzxTwDEvWfPg.png)

---

* [最后的最后是本博客的源码,欢迎关注这一套SpringCloud的实践](https://github.com/lovinstudio/lovincloud)



---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
