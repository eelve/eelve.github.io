---
title: Tomcat中URI不支持特殊字符解决方案
date: 2020-06-30 12:17:57
tags: [tomcat,springboot,java]
categories: java
description: 最近开发过程中遇到一个Tomcat中IllegalArgumentException的报错，所以在这里记录一下。
---
【**前情提要**】最近开发过程中遇到一个`Tomcat`中`IllegalArgumentException`的报错，所以在这里记录一下。

# 壹、错误现象

在用Get请求是当URL中包含特殊字符，比如：`<`、`>`、`(`、`)`、`{`、`}`、`|`等时，Tomcat会报出以下错误：

```
java.lang.IllegalArgumentException: Invalid character found in the request target. The valid characters are defined in RFC 7230 and RFC 3986
    at org.apache.coyote.http11.Http11InputBuffer.parseRequestLine(Http11InputBuffer.java:476) ~[tomcat-embed-core-8.5.28.jar:8.5.28]
    at org.apache.coyote.http11.Http11Processor.service(Http11Processor.java:687) ~[tomcat-embed-core-8.5.28.jar:8.5.28]
    at org.apache.coyote.AbstractProcessorLight.process(AbstractProcessorLight.java:66) [tomcat-embed-core-8.5.28.jar:8.5.28]
    at org.apache.coyote.AbstractProtocol$ConnectionHandler.process(AbstractProtocol.java:790) [tomcat-embed-core-8.5.28.jar:8.5.28]
    at org.apache.tomcat.util.net.NioEndpoint$SocketProcessor.doRun(NioEndpoint.java:1459) [tomcat-embed-core-8.5.28.jar:8.5.28]
    at org.apache.tomcat.util.net.SocketProcessorBase.run(SocketProcessorBase.java:49) [tomcat-embed-core-8.5.28.jar:8.5.28]
    at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149) [na:1.8.0_161]
    at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624) [na:1.8.0_161]
    at org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run(TaskThread.java:61) [tomcat-embed-core-8.5.28.jar:8.5.28]
    at java.lang.Thread.run(Thread.java:748) [na:1.8.0_161]
```

# 贰、故障原因

因为Tomcat严格按照 RFC 3986规范进行访问解析，而 RFC 3986规范定义了Url中只允许包含英文字母（a-zA-Z）、数字（0-9）、-_.~4个特殊字符以及所有保留字符(RFC3986中指定了以下字符为保留字符：! * ’ ( ) ; : @ & = + $ , / ? # [ ])。传入的参数中有"{"不在RFC3986中的保留字段中，所以会报参数异常错。而且这个错误你在应用中处理不到，因为根本都还没有进入应用，在Tomcat中就已经报错了，而且就连你在Tomcat中配置错误页面也没有用。

# 叁、解决方案

## 3.1、定义requestTargetAllow属性

Tomcat 7.0.76, 8.0.42, 8.5.12 这些版本之后可以定义requestTargetAllow 属性来允许禁止的字符。在tomcat的 catalina.properties文件中添加这一句：

```properties
tomcat.util.http.parser.HttpParser.requestTargetAllow=|{}
```

## 3.2、修复server.xml配置文件

如果某些版本的Tomcat已经参照`3.1`中的方法修改之后，还是不生效的话。从官网的文档中我们可以查看到如下提示：tomcat.util.http.parser.HttpParser. requestTargetAllow(This system property is deprecated. Use the relaxedPathChars and relaxedQueryChars attributes of the Connector instead)

所有我们在Tomcat配置文件中：$CATALINA_HOME/conf/server.xml添加`relaxedQueryChars`属性添加到Connector元素：

```xml
<Connector port="8080" protocol="HTTP/1.1" connectionTimeout="20000" URIEncoding="UTF-8" relaxedQueryChars="[]|{}^&#x5c;&#x60;&quot;&lt;&gt;" redirectPort="8443" />
```

## 3.3、Springboot修改方法

在SpringBootApplication的的main方法中增加

```java
System.setProperty("tomcat.util.http.parser.HttpParser.requestTargetAllow","|{}");
```

另外在Springboot 2.0 之后的版本，可以自定义`WebServerFactoryCustomizer`，添加特殊字符的支持：

```java
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.stereotype.Component;

/**
 * Created on 2019/2/18 17:41.
 *
 * @author Ethan
 * <p>
 * java.lang.IllegalArgumentException:
 *  Invalid character found in the request target. The valid characters are defined in RFC 7230 and RFC 3986.
 * </p>
 */
@Component
public class PortalTomcatWebServerCustomizer implements WebServerFactoryCustomizer<TomcatServletWebServerFactory> {

    @Override
    public void customize(TomcatServletWebServerFactory factory) {
        factory.addConnectorCustomizers(connector -> connector.setAttribute("relaxedQueryChars", "{}[]|"));
    }
}
```

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
