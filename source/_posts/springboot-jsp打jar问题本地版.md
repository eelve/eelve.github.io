---
title: springboot+jsp打jar问题
date: 2019-08-09 17:11:29
tags: hide
categories: hide
description: 最近做了一个项目，项目是springboot+jsp结构的，但是在发布生产环境的时候又需要用maven打成jar包，但是一开始的默认配置都不成功。下面的文章就是具体的解决过程。
---
【**前情提要**】最近做了一个项目，项目是springboot+jsp结构的，但是在发布生产环境的时候又需要用maven打成jar包，但是一开始的默认配置都不成功。下面的文章就是具体的解决过程。

-----
# 壹、项目结构

![项目结构](https://eelve.com/upload/2019/7/O$VVNDUD1GCU8FT%5DQH5Z@TM-23f04197a92d4a5db24b6e3fb656b7c1.png)

# 贰、异常现象
使用的JDK为1.8，springboot版本为：
```xml
<parent>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-parent</artifactId>
	<version>1.5.6.RELEASE</version>
	<relativePath/> 
</parent>

<properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <java.version>1.8</java.version>
</properties>
```
打成的jar只包含class文件，没有见资源文件引入。
![没有包含resourse的编译结果](https://eelve.com/upload/2019/7/20190713-90f9d3c88e4940de8c8faaa0b2d4ec7c.png)
# 叁、解决办法
## 1. 添加资源路径的映射
```xml
<resources>
            <resource>
                <directory>src/main/resources</directory>
                <includes>
                    <include>**/**</include>
                </includes>
                <!-- 开启过滤，用指定的参数替换directory下的文件中的参数 -->
                <filtering>false</filtering>
            </resource>

            <resource>
                <directory>src/main/webapp</directory>
                <targetPath>META-INF/resources</targetPath>
                <includes>
                    <include>**/**</include>
                </includes>
            </resource>

            <resource>
                <directory>src/main/java</directory>
                <excludes>
                    <exclude>
                        **/*.java
                    </exclude>
                </excludes>
            </resource>

        </resources>
```
## 2. 修改maven编译版本为1.4.2

只有使用这个版本打jar包才能解析jsp

## 3. 设置mainClass
```xml
<plugins>
            <plugin>
                <!-- maven插件 -->
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <version>1.4.2.RELEASE</version>
                <configuration>
                    <mainClass>com.gt.LaysshApplication</mainClass>
                </configuration>
            </plugin>
        </plugins>
```
## 4. 添加视图配置（可选）

```xml
spring.mvc.view.prefix=/WEB-INF/jsp/

spring.mvc.view.suffix=.jsp
```
下面给出一个比较完整的maven编译配置
```xml
<build>
        <resources>
            <resource>
                <directory>src/main/resources</directory>
                <includes>
                    <include>**/**</include>
                </includes>
                <!-- 开启过滤，用指定的参数替换directory下的文件中的参数 -->
                <filtering>false</filtering>
            </resource>

            <resource>
                <directory>src/main/webapp</directory>
                <targetPath>META-INF/resources</targetPath>
                <includes>
                    <include>**/**</include>
                </includes>
            </resource>

            <resource>
                <directory>src/main/java</directory>
                <excludes>
                    <exclude>
                        **/*.java
                    </exclude>
                </excludes>
            </resource>

        </resources>
        <plugins>
            <plugin>
                <!-- maven插件 -->
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <version>1.4.2.RELEASE</version>
                <configuration>
                    <mainClass>com.gt.MyApplication</mainClass>
                </configuration>
            </plugin>
        </plugins>
    </build>
```

下面就是修改编译配置之后的结果

![正确的结果](https://eelve.com/upload/2019/7/201907192-13a348f78e4c4d1cb0b6485cf535dfbe.png)

----


【写在后面的话】现代的模板解析引擎已经有了这么多了，为什么不试一下**thymeleaf**，但是在最近的项目中碰到了th:src标签不解析的问题，目前还不清楚具体原因，而且相同的写法在其他页面都生效，真是怪异啊。鉴于目前还是又很多人使用springboot+jsp来进行开发，但是因为使用IDEA工具创建的SpringBoot项目本身是没有webapp目录的。如果我们想要添加webapp目录的话，可以手动添加。下面就简单的来说一下配置过程。

-----

## 1.点开项目结构管理，点击IDEA右上角的Project Structure


![Project Structure](https://eelve.com/upload/2019/7/201907193-7d050c6d01c1449f999bb49a5c11fda8.png)

## 2.先点击下图中的+号，再点击Web

![2019071904](https://eelve.com/upload/2019/7/2019071904-f795ae6044024bafbd02136c86fbfbda.png)

## 3.修改配置
下图是修改配置前的默认配置
![修改前的配置](https://eelve.com/upload/2019/7/20190705-bb62a58b15d24b098aa2db949d18de32.png)
下面将webapp配置到传统的main目录下
![修改后的配置](https://eelve.com/upload/2019/7/2019071906-d580c788cbd94ff7ba7cb43d70fb5ebb.png)
![配置Artifacts](https://eelve.com/upload/2019/7/2019071906-4c565cc7039a4ed7b0dff2044d3e1bae.png)
![最后的配置成功的结果](https://eelve.com/upload/2019/7/2019071907-1a3c18ec66514327b6f5b635dfde0f67.png)


---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
