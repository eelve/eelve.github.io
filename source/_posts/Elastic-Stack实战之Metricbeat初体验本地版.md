---
title: Elastic Stack实战之Metricbeat初体验
tags: hide
categories: hide
description: 前面介绍了Elastic Stack的Beats家族，并且 体验了Filebeat，接下来我们就继续来体验一下
abbrlink: ea2474f9
date: 2020-03-07 21:36:20
---


【**前面的话**】[前面介绍了Elastic Stack的Beats家族](https://eelve.com/archives/beats)，并且[体验了Filebeat](https://eelve.com/archives/filebeat)，接下来我们就继续来体验一下


---


# 壹、软件版本

```yaml
Centos：CentOS-7-x86_64-Minimal-1908
VM: 15.5.0 build-14665864
Java: 1.8.0_211
Elasticsearch: elasticsearch-7.6.0
Logstash: logstash-7.6.0
Kibana: kibana-7.6.0
MetricBeat：filebeat-7.6.0
```

# 贰、MetricBeat介绍

MetricBeat是一种轻量型指标采集器，用于从系统和服务收集指标。Metricbeat 能够以一种轻量型的方式，输送各种系统和服务统计数据，从 CPU 到内存，从 Redis 到 Nginx，不一而足。

- 系统级监控，更简洁

![screenshot-infrastructure-ui](https://eelve.com/upload/2020/3/screenshot-infrastructure-ui-d2c3e13f47f74d82a6f0f6c2799d94f8.png)

- 单个二进制文件提供多种模块

  Metricbeat 提供多种内部模块，这些模块可从多项服务（诸如 Apache、Jolokia、NGINX、MongoDB、MySQL、PostgreSQL、Prometheus 等等）中收集指标。安装简单，完全零依赖性。只需在配置文件中启用您所需的模块即可。

  而且，如果您没有看到要找的模块，还可以自己构建。以 Go 语言编写 Metricbeat 模块，过程十分简单。 

  - 系统
  
  ![metricbeat-modules-system](https://eelve.com/upload/2020/3/metricbeat-modules-system-7f76e2200cfb40089bb112f50aae710e.jpg)
  
  - Docker
  
  ![container-monitoring-screenshot-carousel-docker](https://eelve.com/upload/2020/3/container-monitoring-screenshot-carousel-docker-908943a547964d11996a9775855235f0.jpg)
  
  - MongoDB
  
  ![metricbeat-modules-mongo](https://eelve.com/upload/2020/3/metricbeat-modules-mongo-d5d719649a7a4e2a9bf9f1a984528efc.jpg)
  
  - Kubernetes
  
  ![container-monitoring-screenshot-carousel-kubernetes](https://eelve.com/upload/2020/3/container-monitoring-screenshot-carousel-kubernetes-0ee5a1fdacf74c3b82d12c81c5c14af1.jpg)

- 容器就绪 

  近来是不是所有工作都转移到了 Docker 中？通过 Elastic Stack，您能够轻松地监测容器。将 Metricbeat 部署到同一台主机上的一个单独容器后，它将收集与主机上运行的其他每一个容器相关的统计数据。在收集统计数据时，它直接从 proc 文件系统读取 cgroup 信息，这就意味着它无需特权即可访问 Docker API，并且同样适用于其他 Runtime。针对 Docker 的 Autodiscovery 让事情进一步简化，您只需指定一个条件即可开启 Metricbeat 模块。 

- 不错过任何检测信号

  将指标通过假脱机传输方式输送至磁盘，这样您的数据管道再也不会错过任何一个数据点，即使发生中断（例如网络问题），也勿需担心。Metricbeat 会保留传入的数据，并在重新上线后将这些指标输送至 Elasticsearch 或 Logstash。 


- 输送至 Elasticsearch 或 Logstash。在 Kibana 中实现可视化。

  Metricbeat 是 Elastic Stack 的一部分，因此能够与 Logstash、Elasticsearch 和 Kibana 无缝协作。无论您要使用 Logstash 转换或充实指标，还是在 Elasticsearch 中随意处理一些数据分析，亦或在 Kibana 中构建和分享仪表板，Metricbeat 都能轻松地将您的数据发送至最关键的地方。

# 叁 MetricBeat安装

## 3.1 下载地址

[metricBeat-7.6.0-linux-x86_64](https://artifacts.elastic.co/downloads/beats/filebeat/metricBeat-7.6.0-linux-x86_64.tar.gz)


## 3.2 解压metricBeat-7.6.0-linux-x86_64

```shell script
tar -zvxf metricBeat-7.6.0-linux-x86_64.tar.gz -C /usr/elastic
```

## 3.3 使用Kibana展示Metricbeat系统指标

- 修改Metricbeat配置

```shell script
output.elasticsearch:
  # Array of hosts to connect to.
  hosts: ["http://192.168.237.11:9200"]
```

- 启动

```shell script
[iio@192 metricbeat]$ ./metricbeat -e
```
- 在Elasticsearch中查看采集的数据

![2020030707](https://eelve.com/upload/2020/3/2020030707-906f151d4ab34f7c8bbcfea65d83f8e9.png)

- 修改Metricbeat配置

```shell script
setup.kibana:
  host: "192.168.237.11:5601"
```

- 安装仪表盘

```shell script
./metricbeat setup --dashboards
```

- 重启服务查看效果

![2020030708](https://eelve.com/upload/2020/3/2020030708-ba77ee4e36c6478c8b816a314d730f80.png)
![2020030709](https://eelve.com/upload/2020/3/2020030709-a40f0d5711fc4707a416e2c39bbbcb79.png)

到这里我们就监控了我们系统的指标，并且利用Kibana提供的仪表板做了图形化展示。


## 3.4 使用Kibana展示Metricbeat采集nginx指标

- 开启nginx的状态查询

  在nginx中，需要开启状态查询，才能查询到指标数据。
  
  ```shell script
  #重新编译nginx
  ./configure --prefix=/usr/local/nginx --with-http_stub_status_module
  make
  make install
  
  ./nginx -V #查询版本信息
  nginx version: nginx/1.12.0
  built by gcc 4.8.5 20150623 (Red Hat 4.8.5-39) (GCC) 
  configure arguments: --prefix=/usr/local/nginx/ --with-http_stub_status_module

  
  #配置nginx
  vi nginx.conf
  location /nginx-status {
      stub_status on;
      access_log off;
  }
  ```
  
  ![2020030710](https://eelve.com/upload/2020/3/2020030710-267475b4b77648ccb8d57c0fece62055.png)
  
  结果说明：
  
    - Active connections：正在处理的活动连接数
    - server accepts handled requests
      - 第一个 server 表示Nginx启动到现在共处理了22个连接
      - 第二个 accepts 表示Nginx启动到现在共成功创建 22 次握手
      - 第三个 handled requests 表示总共处理了 193 次请求
      - 请求丢失数 = 握手数 - 连接数 ，可以看出目前为止没有丢失请求
    - Reading: 0 Writing: 1 Waiting: 2
      - Reading：Nginx 读取到客户端的 Header 信息数
      - Writing：Nginx 返回给客户端 Header 信息数
      - Waiting：Nginx 已经处理完正在等候下一次请求指令的驻留链接（开启keep-alive的情况下，这个值等于 Active - (Reading+Writing)）


- 配置Nginx Module

  默认Metricbeat之开启了system modules，所以我们这里要手动启用nginx modules
  
  ```shell script
  ./metricbeat modules enable nginx
  ```
  ```shell script
  [iio@192 metricbeat]$ ./metricbeat modules list
  Enabled:
  nginx
  system
  
  Disabled:
  activemq
  aerospike
  apache
  appsearch
  aws
  azure
  beat
  beat-xpack
  ceph
  cockroachdb
  consul
  coredns
  couchbase
  couchdb
  docker
  dropwizard
  elasticsearch
  elasticsearch-xpack
  envoyproxy
  etcd
  golang
  googlecloud
  graphite
  haproxy
  http
  jolokia
  kafka
  kibana
  kibana-xpack
  kubernetes
  kvm
  logstash
  logstash-xpack
  memcached
  mongodb
  mssql
  munin
  mysql
  nats
  oracle
  php_fpm
  postgresql
  prometheus
  rabbitmq
  redis
  sql
  stan
  statsd
  tomcat
  traefik
  uwsgi
  vsphere
  windows
  zookeeper
  ```
  
- 修改nginx modules的配置

  ```shell script
  [iio@192 modules.d]$ vi nginx.yml 
  
  # Module: nginx
  # Docs: https://www.elastic.co/guide/en/beats/metricbeat/7.6/metricbeat-module-nginx.html
  
  - module: nginx
    #metricsets:
    #  - stubstatus
    period: 10s
  
    # Nginx hosts
    hosts: ["http://192.168.237.11"]
  
    # Path to server status. Default server-status
    server_status_path: "nginx-status" #配置的nginx状态访问地址
  
    #username: "user"
    #password: "secret"

  ```

- 启动测试

![2020030711](https://eelve.com/upload/2020/3/2020030711-c1217270b05241ca96fa42f063ba8d9f.png)
![2020030712](https://eelve.com/upload/2020/3/2020030712-8ae5730e5301448b974d67545ff98e7a.png)

到这里我们采集的nginx的指标数据，并且利用Kibana安装的Metricbeatd的nginx仪表盘做了图形化展示。

# 肆、Metricbeat组成

Metricbeat有2部分组成，一部分是Module，另一部分为Metricset。

- Module
  
  收集的对象，如：mysql、redis、nginx、操作系统等；
  
- Metricset

  收集指标的集合，如：cpu、memory、network等；  


---


【**后面的话**】在本文中我们利用Metricbeat监控了系统和nginx的系统指标，并且做了图标化的展示。其他module的使用也类似，他们都是利用Metricbeat给被监控的机器放松状态指令，然后采集数据，再做图形化的展示。同时我们也看到Merticbeat也内置了很多的module，足够了我们日工作需要了。

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
