---
title: SpringBoot打可执行war包
tags:
  - java
  - springboot
  - jar
categories: springboot
description: 最近做了一个Springboot项目，但是最后需要打成WAR包在容器中部署，下面就简单记录一下。
abbrlink: 4f6f7726
date: 2020-04-29 14:23:21
---

【**前情提要**】最近做了一个Springboot项目，但是最后需要打成WAR包在容器中部署，下面就简单记录一下。

-----

# 壹、修改pom文件

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.eelve</groupId>
  <artifactId>springboot-war</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  
  <!-- 打包方式 -->
  <packaging>war</packaging>
  
	<parent>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter-parent</artifactId>
		<version>2.2.6.RELEASE</version>
		<relativePath/> <!-- lookup parent from repository -->
	</parent>
	
	<dependencies>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-web</artifactId>
		</dependency>
		
		<!-- 嵌入式tomcat相关jar将被放入到WEB-INF\lib-provided下 -->
		<dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-tomcat</artifactId>
            <scope>provided</scope>
        </dependency>
	</dependencies>
	
	<build>
		<plugins>
            <!-- 打包插件 -->
			<plugin>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-maven-plugin</artifactId>
			</plugin>
		</plugins>
	</build>
</project>
```

# 贰、修改启动类

```java
package com.eelve.springboot.war;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.support.SpringBootServletInitializer;

@SpringBootApplication
public class SpringbootWarApplication extends SpringBootServletInitializer {

	@Override
	protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
		return application.sources(SpringbootWarApplication.class);
	}

	public static void main(String[] args) {
		SpringApplication.run(SpringbootWarApplication.class, args);
	}
}

```

---

【**后面的话**】使用maven打包(clean package)，生成的war包可以用于传统的部署方式（外部tomcat），也可以直接使用java -jar 的方式运行。

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
