---
title: Elastic Stack实战之环境准备
tags:
  - ELK
  - Linux
  - VM
categories: Elastic Stack
description: >-
  首先还是是简单说一下Elastic Stack技术栈吧。ELK = Elasticsearch, Logstash, Kibana
  是一套实时数据收集，存储，索引，检索，统计分析及可视化的解决方案。最新版本已经改名为Elastic Stack，并新增了Beats项目。
abbrlink: cdfa1d48
date: 2020-02-29 16:29:26
---

【**前面的话**】首先还是是简单说一下[Elastic Stack](https://www.elastic.co/)技术栈吧。ELK = Elasticsearch, Logstash, Kibana 是一套实时数据收集，存储，索引，检索，统计分析及可视化的解决方案。最新版本已经改名为Elastic Stack，并新增了Beats项目。

![2020030104](https://eelve.com/upload/2020/3/2020030104-b3bb574e37fd4c9a959c5b8ba383033c.png)
![2020030105](https://eelve.com/upload/2020/3/2020030105-8644c0540b6041d9a726b0fdf31845a0.png)

**Elasticsearch**

    Elasticsearch 基于java，是个开源分布式搜索引擎，它的特点有：分布式，零配置，自动发现，索引自动分片，索引
    副本机制，restful风格接口，多数据源，自动搜索负载等。


**Logstash**
    
    Logstash 基于java，是一个开源的用于收集,分析和存储日志的工具。
    
**Kibana**

    Kibana 基于nodejs，也是一个开源和免费的工具，Kibana可以为 Logstash 和 ElasticSearch 提供的日志分析友好的
    Web 界面，可以汇总、分析和搜索重要数据日志。

**Beats**

    Beats是elastic公司开源的一款采集系统监控数据的代理agent，是在被监控服务器上以客户端形式运行的数据收集
    器的统称，可以直接把数据发送给Elasticsearch或者通过Logstash发送给Elasticsearch，然后进行后续的数据分析活
    动。
    Beats由如下组成:
    Packetbeat：是一个网络数据包分析器，用于监控、收集网络流量信息，Packetbeat嗅探服务器之间的流量，
    解析应用层协议，并关联到消息的处理，其支 持ICMP (v4 and v6)、DNS、HTTP、Mysql、PostgreSQL、
    Redis、MongoDB、Memcache等协议；
    Filebeat：用于监控、收集服务器日志文件，其已取代 logstash forwarder；
    Metricbeat：可定期获取外部系统的监控指标信息，其可以监控、收集 Apache、HAProxy、MongoDB
    MySQL、Nginx、PostgreSQL、Redis、System、Zookeeper等服务；
    Winlogbeat：用于监控、收集Windows系统的日志信息；
    
但是很多用户还是用ELK来代替Elastic Stack，并且目前的最新版本已经来到了7.6.0，在后面的实践过程中如果没有特指的话，都会是基于最新版本的实践。下面来说一下我的环境，我本人的云服务器，性能不是很够，这边我的解决方案是用虚拟机来解决。所以在这篇文章中是主要介绍在VM中搭建linux服务器的，并且为了资源不浪费，我这边会做最小化安装。

---

# 壹、软件版本

```yaml
Centos：CentOS-7-x86_64-Minimal-1908
VM: 15.5.0 build-14665864
```

# 贰、主要步骤

    在网络中有很多安装的具体步骤，我子啊这里只是说一下容易出错的点。

## 2.1 VM创建虚拟机    

![2020022903](https://eelve.com/upload/2020/2/2020022903-e627be2203d040a8aae53c43c767e582.png)
![2020022903](https://eelve.com/upload/2020/2/2020022903-e627be2203d040a8aae53c43c767e582.png)
![2020022905](https://eelve.com/upload/2020/2/2020022905-baf50368479142869e6d506e899f6623.png)
![2020022906](https://eelve.com/upload/2020/2/2020022906-79511d7494064df9a76dbbb00a529757.png)
![2020022907](https://eelve.com/upload/2020/2/2020022907-d16b584e859c43c794badd92ed116ccc.png)
![2020022911](https://eelve.com/upload/2020/2/2020022911-e111cb9fe7d94935b0cd7b8613d6e278.png)

## 2.2 安装Centos7

![2020022913](https://eelve.com/upload/2020/2/2020022913-34b2a693fd0e4cfa9c6484063bc3a00c.png)
![2020022914](https://eelve.com/upload/2020/2/2020022914-8fb414bf521544518671a2da4fb142f1.png)
![2020022915](https://eelve.com/upload/2020/2/2020022915-d2e5d18a228448709a81391ce595bcff.png)
![2020022916](https://eelve.com/upload/2020/2/2020022916-1ca2096fd9c945a4bdc1da5ea0c6c898.png)
![2020022917](https://eelve.com/upload/2020/2/2020022917-10884dc7ec5348eebb35f8682e627281.png)

# 叁、注意事项
    以下几点是特别需要主要：静态网络映射，时钟同步，系统资源配置
## 3.1 静态网络映射
首先获取子网IP，子网掩码，和网关地址

![2020022918](https://eelve.com/upload/2020/2/2020022918-006bef024d834c50bef94d415e3b3e05.png)
![2020022919](https://eelve.com/upload/2020/2/2020022919-208c5c4049a847ff94be761f512e9dde.png)

在最小化安装的CentOS7中，ifconfig是不能使用的，查看网卡信息的命令是：

```shell script
ip addr
```

![2020022920](https://eelve.com/upload/2020/2/2020022920-57cff54e5cde4ddd96079ae6172070ae.png)

其中“ens33”为网卡名称，根据得到网关和子网ip等修改IP地址等信息

```shell script
vi /etc/sysconfig/network-scripts/ifcfg-ens33

TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=ens33
UUID=2cce262f-99d8-485e-aa8e-f2493405715a
DEVICE=ens33
ONBOOT=yes
IPADDR=192.168.237.11
GATEWAY=192.168.237.2
NETMASK=255.255.255.0
DNS1=192.168.237.2
DNS2=8.8.8.8

```

修改好后保存退出，并重启网络，测试网络是否连接正常：

```shell script
[root@192 ~]# service network restart
Restarting network (via systemctl):                        [  OK  ]
[root@192 ~]# ping www.eelve.com
PING www.eelve.com (47.98.209.166) 56(84) bytes of data.
64 bytes from 47.98.209.166 (47.98.209.166): icmp_seq=1 ttl=128 time=38.1 ms
64 bytes from 47.98.209.166 (47.98.209.166): icmp_seq=2 ttl=128 time=38.7 ms
64 bytes from 47.98.209.166 (47.98.209.166): icmp_seq=3 ttl=128 time=39.4 ms
64 bytes from 47.98.209.166 (47.98.209.166): icmp_seq=4 ttl=128 time=51.3 ms
64 bytes from 47.98.209.166 (47.98.209.166): icmp_seq=5 ttl=128 time=38.1 ms
64 bytes from 47.98.209.166 (47.98.209.166): icmp_seq=6 ttl=128 time=37.9 ms
64 bytes from 47.98.209.166 (47.98.209.166): icmp_seq=7 ttl=128 time=44.5 ms
64 bytes from 47.98.209.166 (47.98.209.166): icmp_seq=8 ttl=128 time=37.7 ms
64 bytes from 47.98.209.166 (47.98.209.166): icmp_seq=9 ttl=128 time=37.9 ms
^C
--- www.eelve.com ping statistics ---
9 packets transmitted, 9 received, 0% packet loss, time 9110ms
rtt min/avg/max/mdev = 37.753/40.435/51.388/4.365 ms

```

到了这里我们就可以使用XShell用配置的静态IP来连接服务器使用了

![2020022921](https://eelve.com/upload/2020/2/2020022921-0f8c6a976821406081e228e76f359236.png)

## 3.2 时钟同步

yum进行软件安装，软件安装过程中如遇到询问，一律选择y，ntp是时间同步命令

```shell script
yum -y install ntp
```

```shell script
ntpdate time1.aliyun.com
```
然后就可以成功同步时间，然后查看
```shell script
[root@192 ~]# date
Sat Feb 29 18:08:31 CST 2020

```
## 3.3 系统资源配置

系统资源的话，主要是虚拟机安装，都可以方便修改，这边后期要安装Elastic Stack，最好是稍微调大一点，内存至少为2G，因为Elasticsearch和Kibana都是需要用到Java虚拟机的，尤其是你准备把这两个服务都安装在一台机器上的话。

---
【**最后的话**】时钟同步，是一定要配置的，不然会造成之后Elastic Stack中的服务不可用，当然也不是真的不可用，你只是会在Kibana中看不到你的数据映射，因为默认Kibana的时间展示参数为最近15分钟，如果你的时间相差很远的话，就可能造成Elasticsearch中能采集数据，但是Kibana展示不出来，这个对于初学者来说会造成Kibana数据不能映射问题，这点在后面会做具体介绍的。

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
