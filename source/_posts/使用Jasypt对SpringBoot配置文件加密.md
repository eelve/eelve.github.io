---
title: 使用Jasypt对SpringBoot配置文件加密
date: 2019-08-09 17:14:23
tags: [java,springboot,jasypt]
categories: springboot
---
# **前言**
在日前安全形势越来越严重的情况下，让我意识到在项目中存在一个我们经常忽略的漏洞，那就是我们的项目的配置文件中配置信息的安全，尤其是数据库连接的用户名和密码的安全。所以这里我们就需要对数据库的用户名和密码进行加密，这也是本文的由来。本文采用Jasypt对Spring Boot配置文件加密的相关方法，其实呢，也还有其他方案，具体的会在后面的相关文章中说明。

# **引入jasypt**
```xml
<dependency>
    <groupId>com.github.ulisesbocchio</groupId>
    <artifactId>jasypt-spring-boot-starter</artifactId>
    <version>2.0.0</version>
</dependency>
```

# **1.生成要加密的字符串**
## 1.1 将数据库的用户名和密码进行加密
```java
@Test
    public void contextLoads() {
        BasicTextEncryptor textEncryptor = new BasicTextEncryptor();
        //加密所需的salt(盐)
        textEncryptor.setPassword("1Qaz0oKm");
        //要加密的数据（数据库的用户名或密码）
        String username = textEncryptor.encrypt("root");
        String password = textEncryptor.encrypt("root");
        System.out.println("username:"+username);
        System.out.println("password:"+password);
    }
```

**输出信息**

```shell script
username:NZmLHOOHX0SEjc285iG9YQ==
password:1JByM5wu5o+9H1Ba2o++Pg==
2019-06-14 14:55:49.863  INFO 8904 --- [       Thread-3] o.s.s.concurrent.ThreadPoolTaskExecutor  : Shutting down ExecutorService 'applicationTaskExecutor'
2019-06-14 14:55:49.863  INFO 8904 --- [       Thread-3] j.LocalContainerEntityManagerFactoryBean : Closing JPA EntityManagerFactory for persistence unit 'default'
2019-06-14 14:55:49.863  INFO 8904 --- [       Thread-3] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown initiated...
2019-06-14 14:55:49.878  INFO 8904 --- [       Thread-3] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown completed.
```
## 1.2. 或者使用Maven下载好的jar包加密\Maven\org\jasypt\jasypt\2.0.0\jasypt-2.0.0.jar
```shell script
java -cp jasypt-1.9.2.jar org.jasypt.intf.cli.JasyptPBEStringEncryptionCLI password=1Qaz0oKm algorithm=PBEWithMD5AndDES input=root
```
**输出信息**
```shell script
----ENVIRONMENT-----------------
Runtime: Oracle Corporation Java HotSpot(TM) 64-Bit Server VM 25.171-b11

----ARGUMENTS-------------------
input: root
algorithm: PBEWithMD5AndDES
password: 1Qaz0oKm 

----OUTPUT----------------------
NZmLHOOHX0SEjc285iG9YQ==
```
拷贝-OUTPUT-下的结果即可
# **2.配置properties文件**
将生成的加密串配置ENC(加密串)到application.properties中
```yaml
server:
  port: 8080
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/test?serverTimezone=UTC&useUnicode=true&characterEncoding=utf-8&useSSL=true
    username: ENC(GHK23XVFNHoQQ97vIW523Q==)
    password: ENC(aTKef0XcG05Cfzao92EqqQ==)
    data-username: com.mysql.cj.jdbc.Driver
  jpa:
    show-sql: true
    database-platform: org.hibernate.dialect.MySQL5InnoDBDialect
    database: MYSQL
    hibernate:
      ddl-auto: update
jasypt:
  encryptor:
    password: 1Qaz0oKm #加密所需的salt(盐)
    #algorithm: PBEWithMD5AndDES   # 默认加密方式PBEWithMD5AndDES,可以更改为PBEWithMD5AndTripleDES
```
**加密方式对应的类为BasicTextEncryptor和StrongTextEncryptor**
```java
private final StandardPBEStringEncryptor encryptor = new StandardPBEStringEncryptor();

    public BasicTextEncryptor() {
        this.encryptor.setAlgorithm("PBEWithMD5AndDES");
    }
```
```java
private final StandardPBEStringEncryptor encryptor = new StandardPBEStringEncryptor();

    public StrongTextEncryptor() {
        this.encryptor.setAlgorithm("PBEWithMD5AndTripleDES");
    }
```
![图片.png](https://eelve.com/upload/2019/6/springbootjasypydiagrams-3a7616cc841c4f7583fc7173e32aaab4.png)
# **3.部署时配置salt(盐)值**
**1. 为了防止salt(盐)泄露,反解出密码.可以在项目部署的时候使用命令传入salt(盐)值**
```shell script
java -jar -Djasypt.encryptor.password=1Qaz0oKm xxx.jar
```
**2. 或者在服务器的环境变量里配置,进一步提高安全性**
```shell script
打开/etc/profile文件
vim /etc/profile

文件末尾插入
export JASYPT_PASSWORD = G0CvDz7oJn6

编译 
source /etc/profile

运行 
java -jar -Djasypt.encryptor.password=${JASYPT_PASSWORD} xxx.jar
```

[下面是一个我自己的具体实现：https://github.com/eelve/jasypt，使用Jasypt对数据库用信息加密后，可以成功连接上数据库](https://github.com/eelve/jasypt)
![图片.png](https://eelve.com/upload/2019/6/springbootjasypyresult-5f2ef70fe5124f5595a48b341807f2c3.png)

[官方地址：https://github.com/ulisesbocchio/jasypt-spring-boot](https://github.com/ulisesbocchio/jasypt-spring-boot)



---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
