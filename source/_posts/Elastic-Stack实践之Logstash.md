---
layout: elastic
title: Elastic Stack实践之Logstash
date: 2020-03-02 21:49:22
tags: [ELK,Logstash]
categories: Elastic Stack
notshow: true
---

【**前面的话**】在前面已经安装好了Elasticsearch，今天就来安装和简单使用一下[Logstash](https://www.elastic.co/cn/logstash)。

---

# 壹、软件版本
```yaml
Centos：CentOS-7-x86_64-Minimal-1908
VM: 15.5.0 build-14665864
Java: 1.8.0_211
Elasticsearch: logstash-7.6.0
```

# 贰、Logstash介绍

![illustration-logstash-header](https://eelve.com/upload/2020/3/illustration-logstash-header-55d54f588c3b4ba89da489277ca709dc.png)

    Logstash 的主要作用是集中、转换和存储数据。是开源的服务器端数据处理管道，能够同时从多个来源采集数据，转换数据，然后将数据发送到您最喜欢的“存储库”中。
    
    Logstash 能够动态地采集、转换和传输数据，不受格式或复杂度的影响。利用 Grok 从非结构化数据中派生出结构，从 IP 地址解码出地理坐标，匿名化或排除敏感字段，并简化整体处理过程。
    
    Logstash 采集，还有更多输入、过滤器和输出

**输入：** 采集各种样式、大小和来源的数据

![diagram-logstash-inputs](https://eelve.com/upload/2020/3/diagram-logstash-inputs-2825f9dced964c4abae8dcd1f3012261.svg)

    数据往往以各种各样的形式，或分散或集中地存在于很多系统中。 Logstash 支持 各种输入选择 ，可以在同一时间从众多常用来源捕捉事件。能够以连续的流式传输方式，轻松地从您的日志、指标、Web 应用、数据存储以及各种 AWS 服务采集数据。 

**过滤器：** 实时解析和转换数据

![diagram-logstash-filters](https://eelve.com/upload/2020/3/diagram-logstash-filters-62adaf05398e48f688e1357503b43f81.svg)

    数据从源传输到存储库的过程中，Logstash 过滤器能够解析各个事件，识别已命名的字段以构建结构，并将它们转换成通用格式，以便更轻松、更快速地分析和实现商业价值。
    
        利用 Grok 从非结构化数据中派生出结构
        从 IP 地址破译出地理坐标
        将 PII 数据匿名化，完全排除敏感字段
        简化整体处理，不受数据源、格式或架构的影响 
    
    我们的过滤器库丰富多样，拥有无限可能。     

**输出：** 选择您的存储库，导出您的数据

![diagram-logstash-outputs](https://eelve.com/upload/2020/3/diagram-logstash-outputs-fe56db1595444ddfafe48d62d5623627.svg)

     尽管 Elasticsearch 是我们的首选输出方向，能够为我们的搜索和分析带来无限可能，但它并非唯一选择。
    
    Logstash 提供众多输出选择，您可以将数据发送到您要指定的地方，并且能够灵活地解锁众多下游用例。 


**可扩展：** 以自己的方式创建和配置管道

    Logstash 采用可插拔框架，拥有 200 多个插件。您可以将不同的输入选择、过滤器和输出选择混合搭配、精心安排，让它们在管道中和谐地运行。
    
    从自定义应用程序采集数据？没有看到所需的插件？Logstash 插件很容易构建。我们有一个极好的插件开发 API 和插件生成器，可帮助您开始创作并分享成果。


# 叁、Logstash安装

## 3.1 下载地址

[logstash-7.6.0.tar.gz](https://artifacts.elastic.co/downloads/logstash/logstash-7.6.0.tar.gz)

---

## 3.2 解压logstash-7.6.0.tar.gz

```shell script
tar -zvxf logstash-7.6.0.tar.gz -C /usr/elastic
```
## 3.3 elasticsearch配置说明

Logstash的配置有三部分，如下：
```
input { #输入
    stdin { ... } #标准输入
}
    filter { #过滤，对数据进行分割、截取等处理
...
}
output { #输出
    stdout { ... } #标准输出
}

```


# 肆、Logstash简单使用

## 4.1 采集控制台日志


## 4.2 采集自定义日志


## 4.3 采集自定义日志



---

【**后面的话**】Logstash作为三大剑客，主要是采集和过滤，但是在现在采集公文部分被Beats家族取代，所以目前最重要的作用是过滤，但是也不是说不能采集了，只是相比于Beat来说效率更低而已。另外还有一点一个输入可以有多份输出。

```
input { #输入
    stdin { ... } #标准输入
}
filter { #过滤，对数据进行分割、截取等处理
    ...
}
output { #输出1
     stdout { ... } #标准输出
 }
output { #输出2
    elasticsearch {
        hosts => [ "192.168.40.133:9200","192.168.40.134:9200","192.168.40.135:9200"]
    }
}


```

---
![薏米笔记](https://eelve.com/upload/2019/8/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
