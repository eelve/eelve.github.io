---
layout: elastic
title: Elastic Stack实战之应用日志监控
date: 2020-03-14 21:49:22
tags: hide
categories: hide
---

【**前面的话**】在前面我们已经介绍了[Elasticsearch](https://eelve.com/archives/elasticsearchinstall)、[Logstash](https://eelve.com/archives/logstash)、[Kibana](https://eelve.com/archives/kibana)和[Beats](https://eelve.com/archives/beats)，并且都对各个组件进行了初步体验。今天我们就来模拟一把日常使用，来收集一个我们自己的应用的日志，并使用Kibana展示。

---

# 壹、软件版本

```yaml
Centos：CentOS-7-x86_64-Minimal-1908
VM: 15.5.0 build-14665864
Java: 1.8.0_211
Elasticsearch: elasticsearch-7.6.0
Logstash: logstash-7.6.0
Kibana: kibana-7.6.0
Filebeat：filebeat-7.6.0
```
# 贰、自定义采集应用

我们这里来模拟一个现在购物网站的使用，主要代码如下

- 核心代码


```java
package com.eelve.elk.dashboardgenerate;

import org.apache.commons.lang3.RandomUtils;
import org.joda.time.DateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DashboardGenerateApplication {

    private static final Logger LOGGER = LoggerFactory.getLogger(DashboardGenerateApplication.class);

    public static final String[] VISIT = new String[]{"浏览页面", "评论商品", "加入收藏", "加入购物车", "提交订单", "使用优惠券", "领取优惠券", "搜索", "查看订单"};

    public static void main(String[] args) throws Exception {
        while(true){
            Long sleep = RandomUtils.nextLong(200, 1000 * 5);
            Thread.sleep(sleep);
            Long maxUserId = 9999L;
            Long userId = RandomUtils.nextLong(1, maxUserId);
            String visit = VISIT[RandomUtils.nextInt(0, VISIT.length)];
            DateTime now = new DateTime();
            int maxHour = now.getHourOfDay();
            int maxMillis = now.getMinuteOfHour();
            int maxSeconds = now.getSecondOfMinute();
            String date = now.plusHours(-(RandomUtils.nextInt(0, maxHour)))
                    .plusMinutes(-(RandomUtils.nextInt(0, maxMillis)))
                    .plusSeconds(-(RandomUtils.nextInt(0, maxSeconds)))
                    .toString("yyyy-MM-dd HH:mm:ss");

            String result = "IIO|" + userId + "|" + visit + "|" + date;
            LOGGER.info(result);
        }

    }
}

```


- 日志配置文件


```properties
log4j.rootLogger=DEBUG,A1,A2

log4j.appender.A1=org.apache.log4j.ConsoleAppender
log4j.appender.A1.layout=org.apache.log4j.PatternLayout
log4j.appender.A1.layout.ConversionPattern=[%p] %-d{yyyy-MM-dd HH:mm:ss} [%c] - %m%n

log4j.appender.A2 = org.apache.log4j.DailyRollingFileAppender
log4j.appender.A2.File = /iio/logs/app.log
log4j.appender.A2.Append = true
log4j.appender.A2.Threshold = INFO
log4j.appender.A2.layout = org.apache.log4j.PatternLayout
log4j.appender.A2.layout.ConversionPattern =[%p] %-d{yyyy-MM-dd HH:mm:ss} [%c] - %m%n

```

- 运行结果

```shell script
"C:\Program Files\Java\jdk1.8.0_221\bin\java.exe" -XX:TieredStopAtLevel=1 -noverify -Dspring.output.ansi.enabled=always -Dcom.sun.management.jmxremote -Dspring.jmx.enabled=true -Dspring.liveBeansView.mbeanDomain -Dspring.application.admin.enabled=true "-javaagent:C:\Program Files\JetBrains\IntelliJ IDEA 2019.1\lib\idea_rt.jar=6396:C:\Program Files\JetBrains\IntelliJ IDEA 2019.1\bin" -Dfile.encoding=UTF-8 -classpath "C:\Program Files\Java\jdk1.8.0_221\jre\lib\charsets.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\deploy.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\ext\access-bridge-64.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\ext\cldrdata.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\ext\dnsns.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\ext\jaccess.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\ext\jfxrt.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\ext\localedata.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\ext\nashorn.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\ext\sunec.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\ext\sunjce_provider.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\ext\sunmscapi.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\ext\sunpkcs11.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\ext\zipfs.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\javaws.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\jce.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\jfr.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\jfxswt.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\jsse.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\management-agent.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\plugin.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\resources.jar;C:\Program Files\Java\jdk1.8.0_221\jre\lib\rt.jar;D:\iio\dashboard-generate\target\classes;C:\Users\Chirius\.m2\repository\org\springframework\boot\spring-boot-starter\2.2.5.RELEASE\spring-boot-starter-2.2.5.RELEASE.jar;C:\Users\Chirius\.m2\repository\org\springframework\boot\spring-boot\2.2.5.RELEASE\spring-boot-2.2.5.RELEASE.jar;C:\Users\Chirius\.m2\repository\org\springframework\spring-context\5.2.4.RELEASE\spring-context-5.2.4.RELEASE.jar;C:\Users\Chirius\.m2\repository\org\springframework\spring-aop\5.2.4.RELEASE\spring-aop-5.2.4.RELEASE.jar;C:\Users\Chirius\.m2\repository\org\springframework\spring-beans\5.2.4.RELEASE\spring-beans-5.2.4.RELEASE.jar;C:\Users\Chirius\.m2\repository\org\springframework\spring-expression\5.2.4.RELEASE\spring-expression-5.2.4.RELEASE.jar;C:\Users\Chirius\.m2\repository\org\springframework\boot\spring-boot-autoconfigure\2.2.5.RELEASE\spring-boot-autoconfigure-2.2.5.RELEASE.jar;C:\Users\Chirius\.m2\repository\org\springframework\boot\spring-boot-starter-logging\2.2.5.RELEASE\spring-boot-starter-logging-2.2.5.RELEASE.jar;C:\Users\Chirius\.m2\repository\org\apache\logging\log4j\log4j-to-slf4j\2.12.1\log4j-to-slf4j-2.12.1.jar;C:\Users\Chirius\.m2\repository\org\apache\logging\log4j\log4j-api\2.12.1\log4j-api-2.12.1.jar;C:\Users\Chirius\.m2\repository\org\slf4j\jul-to-slf4j\1.7.30\jul-to-slf4j-1.7.30.jar;C:\Users\Chirius\.m2\repository\jakarta\annotation\jakarta.annotation-api\1.3.5\jakarta.annotation-api-1.3.5.jar;C:\Users\Chirius\.m2\repository\org\springframework\spring-core\5.2.4.RELEASE\spring-core-5.2.4.RELEASE.jar;C:\Users\Chirius\.m2\repository\org\springframework\spring-jcl\5.2.4.RELEASE\spring-jcl-5.2.4.RELEASE.jar;C:\Users\Chirius\.m2\repository\org\yaml\snakeyaml\1.25\snakeyaml-1.25.jar;C:\Users\Chirius\.m2\repository\org\apache\commons\commons-lang3\3.3.2\commons-lang3-3.3.2.jar;C:\Users\Chirius\.m2\repository\joda-time\joda-time\2.9.9\joda-time-2.9.9.jar;C:\Users\Chirius\.m2\repository\org\slf4j\slf4j-log4j12\1.7.26\slf4j-log4j12-1.7.26.jar;C:\Users\Chirius\.m2\repository\org\slf4j\slf4j-api\1.7.30\slf4j-api-1.7.30.jar;C:\Users\Chirius\.m2\repository\log4j\log4j\1.2.17\log4j-1.2.17.jar" com.eelve.elk.dashboardgenerate.DashboardGenerateApplication
[INFO] 2020-03-14 21:06:09 [com.eelve.elk.dashboardgenerate.DashboardGenerateApplication] - IIO|4234|加入收藏|2020-03-14 04:04:03
[INFO] 2020-03-14 21:06:11 [com.eelve.elk.dashboardgenerate.DashboardGenerateApplication] - IIO|6502|领取优惠券|2020-03-14 14:05:07
[INFO] 2020-03-14 21:06:12 [com.eelve.elk.dashboardgenerate.DashboardGenerateApplication] - IIO|3694|加入购物车|2020-03-14 20:03:09
[INFO] 2020-03-14 21:06:14 [com.eelve.elk.dashboardgenerate.DashboardGenerateApplication] - IIO|8112|使用优惠券|2020-03-14 12:06:02
[INFO] 2020-03-14 21:06:14 [com.eelve.elk.dashboardgenerate.DashboardGenerateApplication] - IIO|3391|加入收藏|2020-03-14 02:01:05
[INFO] 2020-03-14 21:06:17 [com.eelve.elk.dashboardgenerate.DashboardGenerateApplication] - IIO|3696|搜索|2020-03-14 04:06:05
[INFO] 2020-03-14 21:06:18 [com.eelve.elk.dashboardgenerate.DashboardGenerateApplication] - IIO|6670|使用优惠券|2020-03-14 17:04:17
[INFO] 2020-03-14 21:06:21 [com.eelve.elk.dashboardgenerate.DashboardGenerateApplication] - IIO|6646|搜索|2020-03-14 11:06:05
[INFO] 2020-03-14 21:06:24 [com.eelve.elk.dashboardgenerate.DashboardGenerateApplication] - IIO|8227|使用优惠券|2020-03-14 12:06:24

Process finished with exit code -1

```

我们这里模拟了用户的操作，并记录到/iio/logs/app.log文件中。主要的业务流程为：APP->filebeat->logstash->elasticsearch->kibanan->User

![2020031400](https://eelve.com/upload/2020/3/2020031400-c4c762ac3d134548bea4fb19e64088a6.png)

# 叁、准备过程

## 3.1 编写filebeat配置

```shell script
[iio@192 filebeat]$ vi dashboard.yml 
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /iio/logs/*.log
output.logstash:
  hosts: ["192.168.237.11:5044"]

```

## 3.2 编写logstash配置

```shell script
[iio@192 config]$ vi logstash-dashboard.yml 
input {
  beats {
    port => "5044"
  }
}
filter {
  mutate {
    split => {"message"=>"|"}
  }
  mutate {
    add_field => {
       "userId" => "%{[message][1]}"
       "visit" => "%{[message][2]}"
       "date" => "%{[message][3]}"
    }
  }
  mutate {
    convert => {
        "userId" => "integer"
        "visit" => "string"
        "date" => "string"
    }
  }
}

output {
    elasticsearch {
        hosts => ["192.168.237.11:9200"]
    }
}
```

## 3.3 启动应用

```shell script
[root@192 home]# java -jar dashboard-generate-0.0.1-SNAPSHOT.jar &
```

## 3.4 启动elasticsearch

```shell script
[iio@192 bin]$ ./elasticsearch
```

## 3.5 启动kibana

```shell script
[iio@192 bin]$ ./kibana
```

## 3.6 启动logstash

```shell script
[iio@192 bin]$ ./logstash -f /usr/elastic/logstash/config/logstash-dashboard.yml
```

## 3.7 启动filebeat

```shell script
[iio@192 filebeat]$ ./filebeat  -e -c dashboard.yml
```

## 3.8 查看采集的数据

![2020031401](https://eelve.com/upload/2020/3/2020031401-66d588f9d78f4bf4b34b3d9d0f82001d.png)

## 3.9 开始制作大屏

![2020031402](https://eelve.com/upload/2020/3/2020031402-28114b868ca3470497782f558737d25e.png)
![2020031403](https://eelve.com/upload/2020/3/2020031403-7b2ffa7f424b478781543ffb2b1b4207.png)
![2020031404](https://eelve.com/upload/2020/3/2020031404-41d668eff3e247e7aa942d850e7775fa.png)
![2020031405](https://eelve.com/upload/2020/3/2020031405-2aba46902b5f4495bfae81991385b60d.png)
![2020031406](https://eelve.com/upload/2020/3/2020031406-8dbfc5fc883e46298da14ceb8e14348c.png)
![2020031407](https://eelve.com/upload/2020/3/2020031407-cd57f9cb79b64ca6acaa2ba604e78511.png)

到这里我们可以看到就已经完成了对我们自定义数据的监控，然后还利用了Kibana做了图表化展示。


---

【**后面的话**】在我们日常应用中，我们的日志需要按照某种跪着产生，方便我们使用logstash进行过滤，然后做一些处理。也就是说我们在开发之前就应该想好日志生成的格式，然后设计好日志的处理方式。

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
