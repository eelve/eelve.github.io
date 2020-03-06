---
title: SpringCloud之Eureka
date: 2019-08-22 20:22:21
tags: Eureka
categories: SpringCloud
---

【**前面的话**】SpringCloud为开发人员提供了快速构建分布式系统的一些工具，包括配置管理、服务发现、断路器、路由、微代理、事件总线、全局锁、决策竞选、分布式会话等等。它配置简单，上手快，而且生态成熟，便于应用。但是它对SpringBoot有很强的依赖，需要有一定基础，但是SpringBoot俩小时就可以入门。另外对于“微服务架构” 不了解的话，可以通过搜索引擎搜索“微服务架构”了解下。另外这是SpringCloud的版本为**Greenwich.SR2**，JDK版本为**1.8**，SpringBoot的版本为**2.1.7.RELEASE**。

----
# 壹、新建父工程

- 新建一个Maven父工程lovincloud，便于版本管理，然后删除src文件夹
- 添加pom依赖和SpringCloud和SpringBoot的版本

~~~pom
<parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.7.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>

    <groupId>com.eelve.lovincloud</groupId>
    <artifactId>lovincloud</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>pom</packaging>

    <name>lovincloud</name>
    <url>http://maven.apache.org</url>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <spring-cloud.version>Greenwich.SR2</spring-cloud.version>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
~~~

# 贰、添加一个注册中心

在这里，我们需要用的的组件上Spring Cloud Netflix的Eureka ,eureka是一个服务注册和发现模块。

- 新建一个子工程**lovin-eureka-server**作为服务的注册中心

~~~pom
<parent>
        <artifactId>lovincloud</artifactId>
        <groupId>com.eelve.lovincloud</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>lovin-eureka-server</artifactId>
    <packaging>jar</packaging>
    <name>eurekaserver</name>
    <version>0.0.1</version>
    <description>eureka服务端</description>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
~~~

- 然后在启动类上添加@EnableEurekaServer注解：

~~~java
package com.eelve.lovin;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

/**
 * @ClassName LovinEurekaServerApplication
 * @Description TDO
 * @Author zhao.zhilue
 * @Date 2019/8/15 16:20
 * @Version 1.0
 **/
@EnableEurekaServer
@SpringBootApplication
public class LovinEurekaServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(LovinEurekaServerApplication.class,args);
    }
}
~~~

- eureka是一个高可用的组件，它没有后端缓存，每一个实例注册之后需要向注册中心发送心跳（因此可以在内存中完成），在默认情况下erureka server也是一个eureka client ,必须要指定一个 server。eureka server的配置文件appication.yml：

~~~yaml
spring:
  application:
    naem: lovineurkaserver  # 服务模块名称
server:
  port: 8881  # 设置的eureka端口号
eureka:
  instance:
    hostname: localhost   # 设置eureka的主机地址
  client:
    registerWithEureka: false  #表示是否将自己注册到Eureka Server，默认为true。由于当前应用就是Eureka Server，故而设置为false
    fetchRegistry: false  #表示是否从Eureka Server获取注册信息，默认为true。因为这是一个单点的Eureka Server，不需要同步其他的Eureka Server节点的数据，故而设置为false
    serviceUrl:
      defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/   #Eureka server地址，查询服务和注册服务都需要依赖这个地址，多个地址可用逗号（英文的）分割
~~~

# 叁、添加一个服务消费端

- 新建一个子工程**lovin-eureka-server**作为服务的注册中心

~~~pom
<parent>
        <artifactId>lovincloud</artifactId>
        <groupId>com.eelve.lovincloud</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>lovin-eureka-client</artifactId>
    <packaging>jar</packaging>
    <name>eurekaclient</name>
    <version>0.0.1</version>
    <description>eureka的一个消费端</description>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
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

- 然后在启动类上添加@EnableEurekaClient注解：

~~~java
package com.eelve.lovin;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

/**
 * @ClassName LovinEurekaClientApplication
 * @Description TDO
 * @Author zhao.zhilue
 * @Date 2019/8/15 16:37
 * @Version 1.0
 **/
@SpringBootApplication
@EnableEurekaClient
public class LovinEurekaClientApplication {
    public static void main(String[] args) {
        SpringApplication.run(LovinEurekaClientApplication.class,args);
    }
}
~~~

- 然后我们需要连接到服务端，具体配置如下

~~~yaml
server:
  port: 8801   # 服务端口号
spring:
  application:
    name: lovineurkaclient     # 服务名称
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8881/eureka/   # 注册到的eureka服务地址
~~~

- 新建一个Controller写一个测试接口

~~~java
package com.eelve.lovin.controller;

import com.eelve.lovin.config.ServerConfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @ClassName HelloController
 * @Description TDO应用默认访问接口
 * @Author zhao.zhilue
 * @Date 2019/8/15 16:45
 * @Version 1.0
 **/
@RestController
public class HelloController {

    @Autowired
    ServerConfig serverConfig;

    @RequestMapping("hello")
    public String hello(){
        return serverConfig.getUrl()+"###"+ HelloController.class.getName();
    }
}
~~~

# 肆、分别启动注册中心的服务端和客户端

访问localhost:8881查看结果

![注册中心](https://eelve.com/upload/2019/8/192201-a1bae0c08fdc4e848f41093d643ff0cb.png)

到这里我们可以已经看到已经成功将客户端注册到服务端了，然后我们访问测试接口

![192202](https://eelve.com/upload/2019/8/192202-b3bb342983db481f9ad86239e8859e41.png)

可以看到已经访问成功，至此Eureka的搭建已经完成。

# 伍、加入安全配置

在互联网中我们一般都会考虑安全性，尤其是管理服务的注册中心，所以我们可以用**spring-boot-starter-security**来做安全限制

- 给**lovin-eureka-server**添加**spring-boot-starter-security**的pom依赖

~~~pom
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
~~~

- 修改配置文件

~~~yaml
spring:
  application:
    naem: lovineurkaserver  # 服务模块名称
  security:
    basic:
      enabled: true
    user:
      name: lovin
      password: ${REGISTRY_SERVER_PASSWORD:lovin}
server:
  port: 8881  # 设置的eureka端口号
eureka:
  instance:
    hostname: localhost   # 设置eureka的主机地址
    metadata-map:
      user.name: ${security.user.name}
      user.password: ${security.user.password}
  client:
    registerWithEureka: false  #表示是否将自己注册到Eureka Server，默认为true。由于当前应用就是Eureka Server，故而设置为false
    fetchRegistry: false  #表示是否从Eureka Server获取注册信息，默认为true。因为这是一个单点的Eureka Server，不需要同步其他的Eureka Server节点的数据，故而设置为false
    serviceUrl:
      defaultZone: http://${spring.security.user.name}:${spring.security.user.password}@${eureka.instance.hostname}:${server.port}/eureka/   #Eureka server地址，查询服务和注册服务都需要依赖这个地址，多个地址可用逗号（英文的）分割
~~~

- 添加security配置

~~~java
package com.eelve.lovin.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

/**
 * @ClassName SecurityConfig
 * @Description TDO
 * @Author zhao.zhilue
 * @Date 2019/8/16 14:13
 * @Version 1.0
 **/
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.csrf().disable();
        http.authorizeRequests()
                .antMatchers("/css/**").permitAll()
                .anyRequest().authenticated()
                .and()
                .formLogin()
                .and()
                .httpBasic();
        super.configure(http);
    }
}
~~~

- 给**lovin-eureka-client**添加**spring-boot-starter-security**的pom依赖

~~~pom
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
~~~

- 修改yaml配置文件

~~~yaml
server:
  port: 8801   # 服务端口号
spring:
  application:
    name: lovineurkaclient     # 服务名称
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
  instance:
    leaseRenewalIntervalInSeconds: 10
    health-check-url-path: /actuator/health
    metadata-map:
      user.name: lovin
      user.password: lovin
~~~

- 添加security配置

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

- 另外为了测试多客服端注册，我们可以修改再给客户端新建一个配置文件，然后开启IDEA的多节点运行，如下图所示勾选**Allow parallel run**

![192203](https://eelve.com/upload/2019/8/192203-4b74b03a3b3647f5a2c607c61e3a089e.png)

- 然后为了区分是哪个节点的请求我们可以添加获取端口

~~~java
package com.eelve.lovin.config;

import org.springframework.boot.web.context.WebServerInitializedEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

import java.net.InetAddress;
import java.net.UnknownHostException;

/**
 * @ClassName ServerConfig
 * @Description TDO
 * @Author zhao.zhilue
 * @Date 2019/8/18 12:03
 * @Version 1.0
 **/
@Component
public class ServerConfig  implements ApplicationListener<WebServerInitializedEvent> {
    private int serverPort;

    public String getUrl() {
        InetAddress address = null;
        try {
            address = InetAddress.getLocalHost();
        } catch (UnknownHostException e) {
            e.printStackTrace();
        }
        return "http://"+address.getHostAddress() +":"+this.serverPort;
    }

    @Override
    public void onApplicationEvent(WebServerInitializedEvent event) {
        this.serverPort = event.getWebServer().getPort();
    }

}
~~~

- 然后我们一次重启服务端和两个客户端，这个时候我们访问
http://localhost:8881/

![192205](https://eelve.com/upload/2019/8/192205-5a91bb3e4bf5415e8e43817428f0c50c.png)

可以看到，这里已经让我们输入用户名和密码了，说明**spring-boot-starter-security**已经配置成功，这时我们输入配置的用户名:lovin和密码:lovin

![192204](https://eelve.com/upload/2019/8/192204-6274036a13d34d1a849bb78c95494349.png)
这里我们可以看到已经成功了，那么到这里Eureka的配置已经全部成功了。

* [最后的最后是本博客的源码,欢迎关注这一套SpringCloud的实践](https://github.com/lovinstudio/lovincloud)


---


![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
