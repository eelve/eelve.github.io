---
title: SpringBoot自定义Starter
date: 2020-04-05 12:01:17
tags: [java,springboot,]
categories: SpringBoot
---

【**前面的话**】在使用SpringBoot的日常开发过程中，我们不可避免的要封装一些自己的Starter，今天这篇文章就来讨论一下怎么自定义一个Starter，本文会封装一个短信发送能力的Starter,使用[云之讯](https://office.ucpaas.com/about/index.html)的SDK。

---

# 壹、命名规范

官方的约定主要有一个命名的约定：在maven中，groupId代表着姓氏，artifactId代表着名字。Spring Boot也是有一个命名的建议的。groupId不要用官方的org.springframework.boot而要用你自己独特的。对于artifactId的命名，Spring Boot官方建议非官方的Starter命名格式遵循 xxxx-spring-boot-starter ，例如 mybatis-spring-boot-starter 。官方starter会遵循spring-boot-starter-xxxx ,例如spring-boot-starter-web 。很多开源starter作者会忽略这种约定，显得不够“专业“。
    
# 贰、新建工程

新建一个**sms-spring-boot-starter**工程，pom依赖如下：

```xml
<dependencies>
    <!--封装Starter核心依赖  -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-autoconfigure</artifactId>
        <version>2.2.4.RELEASE</version>
    </dependency>
    <!--非必需,该依赖作用是在使用IDEA编写配置文件有代码提示-->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-configuration-processor</artifactId>
        <version>2.2.4.RELEASE</version>
    </dependency>
    <!-- lombok 插件  -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.18.6</version>
        <optional>true</optional>
    </dependency>
    <!-- 因为要使用RestTemplate和转换Json，所以引入这两个依赖 -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
        <version>2.2.4.RELEASE</version>
    </dependency>
    <dependency>
        <groupId>com.alibaba</groupId>
        <artifactId>fastjson</artifactId>
        <version>1.2.61</version>
    </dependency>
</dependencies>
```

# 叁、Properties配置

一般配置参数都是在Spring Boot 的application.yml中。我们会定义一个前缀标识来作为名称空间隔离各个组件的参数。对应的组件会定义一个XXXXProperties 来自动装配这些参数。自动装配的机制基于@ConfigurationProperties注解，请注意一定要显式声明你配置的前缀标识（prefix）。所以这里我们新建**SmsProperties**类，可以配置信息通过配置项名称映射成实体类

```java
@Data
@ConfigurationProperties(prefix = "ucpaassms-config")
public class SmsProperties {
    private String appid;
    private String accountSid;
    private String authToken;
}
```

在这里我们可以将配置文件中前缀为**ucpaassms-config**的配置，映射到**SmsProperties**类中。在将来使用时只需要在application.yml中加入上面对应SmsProperties的配置：

```yaml
ucpaassms-config:
  account-sid:  //这里填写平台获取的ID和KEY
  auth-token:   //这里填写平台获取的ID和KEY
  appid:        //这里填写平台获取的ID和KEY
```
    
# 肆、定义业务实现类

拿到配置后，接下来就是根据配置来初始化我们的功能接口。这里我们新建**SmsService**，用来提供具体业务逻辑处理能力

```java
public class SmsService {

    @Autowired
    private RestTemplate restTemplate;
    private String appid;
    private String accountSid;
    private String authToken;


    /**
     * 初始化
     */
    public SmsService(SmsProperties smsProperties) {
       this.appid = smsProperties.getAppid();
       this.accountSid = smsProperties.getAccountSid();
       this.authToken = smsProperties.getAuthToken();
    }

    /**
     * 单独发送
     */
    public String sendSMS(SendSMSDTO sendSMSDTO){
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("sid", accountSid);
        jsonObject.put("token", authToken);
        jsonObject.put("appid", appid);
        jsonObject.put("templateid", sendSMSDTO.getTemplateid());
        jsonObject.put("param", sendSMSDTO.getParam());
        jsonObject.put("mobile", sendSMSDTO.getMobile());
        if (sendSMSDTO.getUid()!=null){
            jsonObject.put("uid",sendSMSDTO.getUid());
        }else {
            jsonObject.put("uid","");
        }
        String json = JSONObject.toJSONString(jsonObject);
        //使用restTemplate进行访问远程Http服务
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON_UTF8);
        HttpEntity<String> httpEntity = new HttpEntity<String>(json, headers);
        String result = restTemplate.postForObject(ENUM_SMSAPI_URL.SENDSMS.getUrl(), httpEntity, String.class);
        return result;
    }

    /**
     * 群体发送
     */
    public String sendBatchSMS(SendSMSDTO sendSMSDTO){
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("sid", accountSid);
        jsonObject.put("token", authToken);
        jsonObject.put("appid", appid);
        jsonObject.put("templateid", sendSMSDTO.getTemplateid());
        jsonObject.put("param", sendSMSDTO.getParam());
        jsonObject.put("mobile", sendSMSDTO.getMobile());
        if (sendSMSDTO.getUid()!=null){
            jsonObject.put("uid",sendSMSDTO.getUid());
        }else {
            jsonObject.put("uid","");
        }
        String json = JSONObject.toJSONString(jsonObject);
        //使用restTemplate进行访问远程Http服务
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON_UTF8);
        HttpEntity<String> httpEntity = new HttpEntity<String>(json, headers);
        String result = restTemplate.postForObject(ENUM_SMSAPI_URL.SENDBATCHSMS.getUrl(), httpEntity, String.class);
        return result;
    }
}

```
  
# 伍、定义配置类

功能接口实现完后我们会编写一个自动配置类 SmsAutoConfiguration 。除了@Configuration注解外，@EnableConfigurationProperties会帮助我们将我们的配置类SmsProperties加载进来。然后将我们需要暴露的功能接口声明为Spring Bean暴露给Spring Boot应用。这里我们新建**SmsAutoConfiguration**类

```java
@Configuration  //注释使类成为bean的工厂
@EnableConfigurationProperties(SmsProperties.class) //使@ConfigurationProperties注解生效
public class SmsAutoConfiguration {
    @Bean
    public SmsService getBean(SmsProperties smsProperties){
        SmsService smsService = new SmsService(smsProperties);
        return smsService;
    }
}

```

# 陆、自动装配

这里会用到类似java的SPI机制。在资源包下新建META-INF/spring.factories写入SmsAutoConfiguration全限定名。这样在starter组件集成入Spring Boot应用时就可以被应用捕捉到。  

```
org.springframework.boot.autoconfigure.EnableAutoConfiguration=com.eelve.sms.starter.config.SmsAutoConfiguration
```

这里还有另外一种方式：

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Import(SmsAutoConfiguration.class)
public @interface EnableSMS {

}
//这样我们使用EnableSMS注解，就可以使用能力了
```

到这里我们的自定义配置就可以完成了，然后就可以上传仓库，提供给第三方使用了。

# 柒、测试

## 7.1 加入**sms-spring-boot-starter**短信依赖
## 7.2 编写配置

~~~yaml
ucpaassms-config:
  account-sid:  //这里填写平台获取的ID和KEY
  auth-token:   //这里填写平台获取的ID和KEY
  appid:        //这里填写平台获取的ID和KEY
~~~

## 7.3 编写测试类

~~~java
package com.eelve.ucpaassms.controller;

import com.eelve.sms.starter.SmsService;
import com.eelve.sms.starter.dto.SendSMSDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping("/sms")
public class TestController {

    @Autowired
    private SmsService smsService;

    @RequestMapping(value = "/sendsmsTest",method = RequestMethod.GET)
    public String sendsmsTest(){
        //创建传输类设置参数
        SendSMSDTO sendSMSDTO  = new SendSMSDTO();
        sendSMSDTO.setMobile("18888888888");     //手机号
        sendSMSDTO.setTemplateid("55555"); //模板
        sendSMSDTO.setParam("9999");      //参数
        return smsService.sendSMS(sendSMSDTO);
    }

}
~~~

然后运行就可以收到发送的短信了

```
【蔚然山庄】尊敬的用户，敬请关注我们的后续活动。
```

---

【**后面的话**】

在引入自己封装的Starter的时候,有的人会报错xxxx类的bean没有找到问题,是因为@SpringBootApplication扫描包的范围是启动类所在同级包和子包,但是不包括第三方的jar包.如果需要扫描maven依赖添加的Jar,我们就要单独使用@ComponentScan注解扫描包.
针对这种情况解决方式有两种:

第一种:是你封装的Starter项目下父级包名称和测试项目的父级包名一样,例如这两个项目包名都叫com.eelve,这样可以不使用@ComponentScan注解,很显然这样做有局限性,不推荐.

第二种:是可以单独使用@ComponentScan注解扫描第三方包,但是这里一定要注意@SpringBootApplication注解等价于默认属性使用@Configuration+@EnableAutoConfiguration+@ComponentScan,如果@SpringBootApplication和@ComponentScan注解同时存在，那么@SpringBootApplication注解中@ComponentScan的扫描范围会被覆盖,所以单独使用@ComponentScan的话,必须在该注解上配置项目需要扫描的包的所有范围,即项目包路径+依赖包路径.

~~~yaml
/**
 * @ComponentScan注解扫描多个包下示例
 */
@ComponentScan({"com.test","sms.test"})
~~~

另外具体实现可以参考我的项目：[ucpaas-spring-boot-starter](https://github.com/eelve/ucpaas-spring-boot-starter)
      
---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
