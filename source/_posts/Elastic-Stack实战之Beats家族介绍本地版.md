---
title: Elastic Stack实战之Beats家族介绍本地版
tags: hide
categories: hide
description: >-
  前面我们已经体验过了Elasticsearch、Logstash和Kibanan，也是就是ELK三大剑客。记得在前文 Elastic
  Stack实战之Logstash初体验 中提到过Elastic Stack大家族中增加了一个新的高效率的采集组件，那就是Beats家族，那今天就来了解一下。
abbrlink: 89ab2246
date: 2020-03-05 20:30:10
---

【**前面的话**】前面我们已经体验过了Elasticsearch、Logstash和Kibanan，也是就是ELK三大剑客。记得在前文[Elastic Stack实战之Logstash初体验](https://eelve.com/posts/e05eadb0.html)中提到过Elastic Stack大家族中增加了一个新的高效率的采集组件，那就是Beats家族，那今天就来了解一下。

---

# 壹、什么是Beats

![illustration-beats-header-overflow](https://eelve.com/upload/2020/3/illustration-beats-header-overflow-1ba7ff649dbf41598d71ed24d1ade8da.png)

**Beats**是轻量型数据采集器。

**Beats**平台集合了多种单一用途数据采集器。它们从成百上千或成千上万台机器和系统向 Logstash 或 Elasticsearch 发送数据。 


# 贰、Beats系列简介

全品类采集器，搞定所有数据类型。

- [Filebeat](https://www.elastic.co/beats/filebeat)：用于采集日志文件

- [Metricbeat](https://www.elastic.co/beats/metricbeat): 用于采集指标数据

- [Packetbeat](https://www.elastic.co/beats/packetbeat): 用于采集网络数据

- [Winlogbeat](https://www.elastic.co/beats/winlogbeat): 用于采集Windows事件

- [Auditbeat](https://www.elastic.co/beats/auditbeat): 用于采集审计数据

- [Heartbeat](https://www.elastic.co/beats/heartbeat): 用于采集运行时间监控

- [Functionbeat](https://www.elastic.co/beats/functionbeat): 是一个无需服务器的采集器


# 叁、Beats特点

- 轻量型：Beats 是数据采集的得力工具。将Beats和您的容器一起置于服务器上，或者将Beats作为功能加以部署，然后便可在 Elasticsearch中集中处理数据。Beats能够采集符合 Elastic Common Schema(ECS)要求的数据，如果您希望拥有更加强大的处理能力，Beats能够将数据转发至Logstash进行转换和解析。 

![illustration-beats-lightweight](https://eelve.com/upload/2020/3/illustration-beats-lightweight-d6ee1493b6a64579a71fb63e2e95b4ac.svg)

- 即插即用：借助模块加速数据可视化体验。Filebeat 和 Metricbeat 中包含的一些模块能够简化从关键数据源（例如云平台、容器和系统，以及网络技术）采集、解析和可视化信息的过程。只需运行一行命令，即可开始探索。 

![screenshot-beats-modules](https://eelve.com/upload/2020/3/screenshot-beats-modules-8dec132b351e4c6a9835d806e24e520e.jpg)

- 从环境中获得洞见：Beats 从您的专属环境中收集日志和指标，然后通过来自主机、诸如 Docker 和 Kubernetes 等容器平台以及云服务提供商的必要元数据对这些内容进行记录，然后再传输到 Elastic Stack 中。从监测容器到从无需服务器的架构传输数据，我们确保您拥有所需的上下文。 

![screenshot-infrastructure-ui](https://eelve.com/upload/2020/3/screenshot-infrastructure-ui-368a637d105b42a4b87d0df2b2158275.png)

- 可扩展：缺少某种采集器？别着急。您可以自行构建并分享。每款开源 Beat 都以 libbeat（转发数据时所用的通用库）为基石。需要监控某个专用协议？自行构建。我们将为您提供所需的构建基块。

![illustration-beats-exstensible-555-white-bg](https://eelve.com/upload/2020/3/illustration-beats-exstensible-555-white-bg-1767d533ca824a5290360eb027eed811.svg)

- 托管式：Beats 同样能向 Elastic Cloud 输送数据

![illustration-beats-elasticsearch-service](https://eelve.com/upload/2020/3/illustration-beats-elasticsearch-service-e783d59f07bc406c95c0942484f91c22.svg)

---

【**后面的话**】本文只是Beats家族的一个介绍，后面还有相关文章进行体验。Beats采集数据之后可以直接给Elasticsearch，也可以经过Logstash过滤处理之后再由Logstash存入Elasticsearch。在后面的文章会做相应的演示的。


---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
