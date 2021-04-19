---
title: Elastic Stack实战之Filebeat初体验
tags:
  - ELK
  - FileBeat
  - Beats
categories: Elastic Stack
description: 前文介绍了Elastic Stack的Beats家族，今天我们就来体验其中的专门用于采集文件的 Filebeat，走起。
abbrlink: 1d8b943d
date: 2020-03-07 17:49:22
---

【**前面的话**】[前文](https://eelve.com/archives/beats)介绍了Elastic Stack的Beats家族，今天我们就来体验其中的专门用于采集文件的[Filebeat](https://www.elastic.co/cn/beats/filebeat)，走起。


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

# 贰、Filebeat介绍

Filebeat是一种轻量型日志采集器，具有以下特点

- 汇总、“tail -f”和搜索：启动 Filebeat 后，打开 Logs UI，直接在 Kibana 中观看对您的文件进行 tail 操作的过程。通过搜索栏按照服务、应用程序、主机、数据中心或者其他条件进行筛选，以跟踪您的全部汇总日志中的异常行为。

![animated-gif-logs-ui-optimized](https://image.eelve.com/eblog/animated-gif-logs-ui-optimized-7bf3c88845c84ee3a0564f7a608726b5.gif)

- 性能稳健，不错过任何检测信号：无论在任何环境中，随时都潜伏着应用程序中断的风险。Filebeat 能够读取并转发日志行，如果出现中断，还会在一切恢复正常后，从中断前停止的位置继续开始。

- Filebeat 让简单的事情简单化：Filebeat 内置有多种模块（Apache、Cisco ASA、Microsoft Azure、NGINX、MySQL 等等），可针对常见格式的日志大大简化收集、解析和可视化过程，只需一条命令即可。之所以能实现这一点，是因为它将自动默认路径（因操作系统而异）与 Elasticsearch 采集节点管道的定义和 Kibana 仪表板组合在一起。不仅如此，数个 Filebeat 模块还包括预配置的 Machine Learning 任务。 

  - 系统
  
  ![filebeat-modules-system](https://image.eelve.com/eblog/filebeat-modules-system-1fcfe648ed244a3eb6981805e48eb805.jpg)
  
  - NGINX
  
  ![filebeat-modules-nginx](https://image.eelve.com/eblog/filebeat-modules-nginx-60aafcc8bf6e416e8489e30b85e84446.jpg)
  
  - MySQL
  
  ![filebeat-modules-mysql](https://image.eelve.com/eblog/filebeat-modules-mysql-532077e16cc3495291fbe4c7b15e7f36.jpg)
  
  - Auditd
  
  ![filebeat-modules-auditd](https://image.eelve.com/eblog/filebeat-modules-auditd-593f8272484b4aa4ac01bc3fcd596d43.jpg)


- 容器就绪和云端就绪：正在对所有内容进行容器化，或者正在云端环境中运行？通过 Elastic Stack，可以轻松地监测容器和云服务。在 Kubernetes、Docker 或云端部署中部署 Filebeat，即可获得所有的日志流：信息十分完整，包括日志流的 pod、容器、节点、VM、主机以及自动关联时用到的其他元数据。此外，Beats Autodiscover 功能可检测到新容器，并使用恰当的 Filebeat 模块对这些容器进行自适应监测。 

- 它不会导致您的管道过载：当将数据发送到 Logstash 或 Elasticsearch 时，Filebeat 使用背压敏感协议，以应对更多的数据量。如果 Logstash 正在忙于处理数据，则会告诉 Filebeat 减慢读取速度。一旦拥堵得到解决，Filebeat 就会恢复到原来的步伐并继续传输数据。 

![filebeat-diagram](https://image.eelve.com/eblog/filebeat-diagram-71397eba004043f3a0593620b0139364.svg)


- 输送至 Elasticsearch 或 Logstash。在 Kibana 中实现可视化。

  Filebeat 是 Elastic Stack 的一部分，因此能够与 Logstash、Elasticsearch 和 Kibana 无缝协作。无论您要使用 Logstash 转换或充实日志和文件，还是在 Elasticsearch 中随意处理一些数据分析，亦或在 Kibana 中构建和分享仪表板，Filebeat 都能轻松地将您的数据发送至最关键的地方。

# 叁 Filebeat安装

## 3.1 下载地址

[filebeat-7.6.0-linux-x86_64](https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.6.0-linux-x86_64.tar.gz)


## 3.2 解压filebeat-7.6.0-linux-x86_64

```shell script
tar -zvxf filebeat-7.6.0-linux-x86_64.tar.gz -C /usr/elastic
```

## 3.3 filebeat配置


我们可以针对不同的采集项自定义配置，同时方便测试和展示。

## 3.4 采集控制台日志

- 新建std.yml配置

```shell script
filebeat.inputs:
- type: stdin
  enabled: true
setup.template.settings:
  index.number_of_shards: 1
output.console:
  pretty: true
  enable: true
```

- 启动

```shell script
./filebeat  -e -c std.yml
```

- 结果

```shell script
hello
{
  "@timestamp": "2020-03-07T08:40:10.807Z",
  "@metadata": {
    "beat": "filebeat",
    "type": "_doc",
    "version": "7.6.0"
  },
  "agent": {
    "id": "4f346e18-c77b-4a8c-ae9a-f97b2007be60",
    "version": "7.6.0",
    "type": "filebeat",
    "ephemeral_id": "2b5dd30b-1a9a-454a-a9f1-0a428fd6c6da",
    "hostname": "192.168.237.11"
  },
  "ecs": {
    "version": "1.4.0"
  },
  "message": "hello",
  "log": {
    "offset": 0,
    "file": {
      "path": ""
    }
  },
  "input": {
    "type": "stdin"
  },
  "host": {
    "name": "192.168.237.11"
  }
}
```

## 3.5 采集nginx日志

- 启动nginx

  这里如果没有安装的话，可以自行安装配置，然后启动nginx
  
- 新建nginx.yml配置

```shell script
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /usr/local/nginx/logs/*.log
  tags: ["nginx"]
setup.template.settings:
  index.number_of_shards: 1
output.elasticsearch:
  hosts: ["http://192.168.237.11:9200"]

```

- 启动Elasticsearch

```shell script
[iio@192 bin]$ ./elasticsearch
```

- 启动Filebeat

```shell script
[iio@192 filebeat]$ ./filebeat  -e -c nginx.yml

2020-03-07T17:11:05.821+0800	INFO	instance/beat.go:298	Setup Beat: filebeat; Version: 7.6.0
2020-03-07T17:11:05.821+0800	INFO	[index-management]	idxmgmt/std.go:182	Set output.elasticsearch.index to 'filebeat-7.6.0' as ILM is enabled.
2020-03-07T17:11:05.821+0800	INFO	elasticsearch/client.go:174	Elasticsearch url: http://192.168.237.11:9200
2020-03-07T17:11:05.821+0800	INFO	[publisher]	pipeline/module.go:110	Beat name: 192.168.237.11
2020-03-07T17:11:05.822+0800	INFO	[monitoring]	log/log.go:118	Starting metrics logging every 30s
2020-03-07T17:11:05.822+0800	INFO	instance/beat.go:439	filebeat start running.
2020-03-07T17:11:05.822+0800	INFO	registrar/registrar.go:145	Loading registrar data from /usr/elastic/filebeat/data/registry/filebeat/data.json
2020-03-07T17:11:05.822+0800	INFO	registrar/registrar.go:152	States Loaded from registrar: 3
2020-03-07T17:11:05.822+0800	INFO	crawler/crawler.go:72	Loading Inputs: 1
2020-03-07T17:11:05.823+0800	INFO	log/input.go:152	Configured paths: [/usr/local/nginx/logs/*.log]
2020-03-07T17:11:05.823+0800	INFO	input/input.go:114	Starting input of type: log; ID: 11194696681404026286 
2020-03-07T17:11:05.823+0800	INFO	crawler/crawler.go:106	Loading and starting Inputs completed. Enabled inputs: 1
2020-03-07T17:11:15.826+0800	INFO	log/harvester.go:297	Harvester started for file: /usr/local/nginx/logs/access.log
2020-03-07T17:11:16.828+0800	INFO	pipeline/output.go:95	Connecting to backoff(elasticsearch(http://192.168.237.11:9200))
2020-03-07T17:11:16.831+0800	INFO	elasticsearch/client.go:757	Attempting to connect to Elasticsearch version 7.6.0
2020-03-07T17:11:16.859+0800	INFO	[license]	licenser/es_callback.go:50	Elasticsearch license: Basic
2020-03-07T17:11:16.891+0800	INFO	[index-management]	idxmgmt/std.go:258	Auto ILM enable success.
2020-03-07T17:11:16.892+0800	INFO	[index-management.ilm]	ilm/std.go:139	do not generate ilm policy: exists=true, overwrite=false
2020-03-07T17:11:16.893+0800	INFO	[index-management]	idxmgmt/std.go:271	ILM policy successfully loaded.
2020-03-07T17:11:16.893+0800	INFO	[index-management]	idxmgmt/std.go:410	Set setup.template.name to '{filebeat-7.6.0 {now/d}-000001}' as ILM is enabled.
2020-03-07T17:11:16.893+0800	INFO	[index-management]	idxmgmt/std.go:415	Set setup.template.pattern to 'filebeat-7.6.0-*' as ILM is enabled.
2020-03-07T17:11:16.893+0800	INFO	[index-management]	idxmgmt/std.go:449	Set settings.index.lifecycle.rollover_alias in template to {filebeat-7.6.0 {now/d}-000001} as ILM is enabled.
2020-03-07T17:11:16.893+0800	INFO	[index-management]	idxmgmt/std.go:453	Set settings.index.lifecycle.name in template to {filebeat {"policy":{"phases":{"hot":{"actions":{"rollover":{"max_age":"30d","max_size":"50gb"}}}}}}} as ILM is enabled.
2020-03-07T17:11:16.895+0800	INFO	template/load.go:89	Template filebeat-7.6.0 already exists and will not be overwritten.
2020-03-07T17:11:16.895+0800	INFO	[index-management]	idxmgmt/std.go:295	Loaded index template.
2020-03-07T17:11:17.097+0800	INFO	[index-management]	idxmgmt/std.go:306	Write alias successfully generated.
2020-03-07T17:11:17.097+0800	INFO	pipeline/output.go:105	Connection to backoff(elasticsearch(http://192.168.237.11:9200)) established
```
- 刷新页面观察结果

![2020030701](https://image.eelve.com/eblog/2020030701-f6f0c410456c47e7872c7719e1fe4205.png)
![2020030702](https://image.eelve.com/eblog/2020030702-c17fe51d42ca47a3b4c452fa14131e92.png)

我们可以看到采集已经成功，并且我们配置的tags也已经成功了

## 3.6 使用nginx module采集nginx日志

- 开启filebeat的nginx module

前面要想实现日志数据的读取以及处理都是自己手动配置的，其实，在Filebeat中，有大量的Module，可以简化我们的配置，直接就可以使用，如下：

```shell script
[iio@192 filebeat]$ ./filebeat modules list
Enabled:
nginx

Disabled:
activemq
apache
auditd
aws
azure
cef
cisco
coredns
elasticsearch
envoyproxy
googlecloud
haproxy
ibmmq
icinga
iis
iptables
kafka
kibana
logstash
misp
mongodb
mssql
mysql
nats
netflow
osquery
panw
postgresql
rabbitmq
redis
santa
suricata
system
traefik
zeek
```

可以看到我这里的nginx modules已经开启了，但是默认是没有开启的，如果需要启用需要进行enable操作：

```shell script
/filebeat modules enable nginx #启动
./filebeat modules disable nginx #禁用

```

- nginx module 配置

```shell script
[iio@192 filebeat]$ cd modules.d
[iio@192 modules.d]$ vi nginx.yml 

# Module: nginx
# Docs: https://www.elastic.co/guide/en/beats/filebeat/7.6/filebeat-module-nginx.html

- module: nginx
  # Access logs
  access:
    enabled: true
    var.paths: ["/usr/local/nginx/logs/access.log*"]
    # Set custom paths for the log files. If left empty,
    # Filebeat will choose the paths depending on your OS.
    #var.paths:

  # Error logs
  error:
    enabled: true
    var.paths: ["/usr/local/nginx/logs/error.log*"]

    # Set custom paths for the log files. If left empty,
    # Filebeat will choose the paths depending on your OS.
    #var.paths:

```

- 配置filebeat

```shell script
[iio@192 filebeat]$ vi nginxmodule.yml
filebeat.inputs:
#- type: log
#  enabled: true
#  paths:
#    - /usr/local/nginx/logs/*.log
#  tags: ["nginx"]
setup.template.settings:
  index.number_of_shards: 1
output.elasticsearch:
  hosts: ["http://192.168.237.11:9200"]
filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false

```

- 启动

```shell script
[iio@192 filebeat]$ ./filebeat  -e -c nginxmodule.yml
```

- 查看结果

![2020030703](https://image.eelve.com/eblog/2020030703-14356801335d4ea8a4256bce80a9bf5f.png)

```
{
	"msg": "2020-02-29 02:30:26,634 [myid:] - WARN  [NIOServerCxn.Factory:0.0.0.0\/0.0.0.0:2181:NIOServerCnxn@376] - Unable to read additional data from client sessionid 0x0, likely client has closed socket",
	"rawmsg": "2020-02-29 02:30:26,634 [myid:] - WARN  [NIOServerCxn.Factory:0.0.0.0\/0.0.0.0:2181:NIOServerCnxn@376] - Unable to read additional data from client sessionid 0x0, likely client has closed socket",
	"timereported": "2020-02-29T10:30:26.635186+08:00",
	"hostname": "izbp1a4b02uc2nj550yzs1z",
	"syslogtag": "journal:",
	"inputname": "imjournal",
	"fromhost": "izbp1a4b02uc2nj550yzs1z",
	"fromhost-ip": "127.0.0.1",
	"pri": "14",
	"syslogfacility": "1",
	"syslogseverity": "6",
	"timegenerated": "2020-02-29T10:30:26.635186+08:00",
	"programname": "journal",
	"protocol-version": "0",
	"structured-data": "-",
	"app-name": "journal",
	"procid": "-",
	"msgid": "-",
	"uuid": null,
	"$!": {
		"_UID": "0",
		"_GID": "0",
		"_CAP_EFFECTIVE": "1fffffffff",
		"_BOOT_ID": "1c6d86e336cc4dc7b733ea3c53351d65",
		"_MACHINE_ID": "f0f31005fb5a436d88e3c6cbf54e25aa",
		"_HOSTNAME": "izbp1a4b02uc2nj550yzs1z",
		"_SYSTEMD_SLICE": "system.slice",
		"PRIORITY": "6",
		"_TRANSPORT": "journal",
		"CONTAINER_ID_FULL": "bdc76f9b56dbeb3f5005ca110d72945c6b949178b6948345febf5bc657433703",
		"CONTAINER_NAME": "zookeeper",
		"CONTAINER_TAG": "bdc76f9b56db",
		"CONTAINER_ID": "bdc76f9b56db",
		"_PID": "16046",
		"_COMM": "dockerd-current",
		"_EXE": "\/usr\/bin\/dockerd-current",
		"_CMDLINE": "\/usr\/bin\/dockerd-current --add-runtime docker-runc=\/usr\/libexec\/docker\/docker-runc-current --default-runtime=docker-runc --exec-opt native.cgroupdriver=systemd --userland-proxy-path=\/usr\/libexec\/docker\/docker-proxy-current --init-path=\/usr\/libexec\/docker\/docker-init-current --seccomp-profile=\/etc\/docker\/seccomp.json --selinux-enabled --log-driver=journald --signature-verification=false --storage-driver overlay2",
		"_SYSTEMD_CGROUP": "\/system.slice\/docker.service",
		"_SYSTEMD_UNIT": "docker.service",
		"MESSAGE": "2020-02-29 02:30:26,634 [myid:] - WARN  [NIOServerCxn.Factory:0.0.0.0\/0.0.0.0:2181:NIOServerCnxn@376] - Unable to read additional data from client sessionid 0x0, likely client has closed socket",
		"_SOURCE_REALTIME_TIMESTAMP": "1582943426634852"
	}
} {
	"_index": "filebeat-7.6.0-2020.03.07-000001",
	"_type": "_doc",
	"_id": "hBtStHAB2wqxgggKYbTw",
	"_version": 1,
	"_score": 1,
	"_source": {
		"agent": {
			"hostname": "192.168.237.11",
			"id": "4f346e18-c77b-4a8c-ae9a-f97b2007be60",
			"ephemeral_id": "b9759c98-cfbe-4240-8c7d-1e64c1caeec3",
			"type": "filebeat",
			"version": "7.6.0"
		},
		"nginx": {
			"access": {
				"remote_ip_list": [
					"192.168.237.1"
				]
			}
		},
		"log": {
			"file": {
				"path": "/usr/local/nginx/logs/access.log"
			},
			"offset": 83567
		},
		"source": {
			"address": "192.168.237.1",
			"ip": "192.168.237.1"
		},
		"fileset": {
			"name": "access"
		},
		"url": {
			"original": "/"
		},
		"input": {
			"type": "log"
		},
		"@timestamp": "2020-03-07T09:27:40.000Z",
		"ecs": {
			"version": "1.4.0"
		},
		"service": {
			"type": "nginx"
		},
		"host": {
			"name": "192.168.237.11"
		},
		"http": {
			"request": {
				"referrer": "-",
				"method": "GET"
			},
			"response": {
				"status_code": 304,
				"body": {
					"bytes": 0
				}
			},
			"version": "1.1"
		},
		"event": {
			"timezone": "+08:00",
			"created": "2020-03-07T09:27:41.512Z",
			"module": "nginx",
			"dataset": "nginx.access"
		},
		"user": {
			"name": "-"
		},
		"user_agent": {
			"original": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36",
			"os": {
				"name": "Windows",
				"version": "10",
				"full": "Windows 10"
			},
			"name": "Chrome",
			"device": {
				"name": "Other"
			},
			"version": "80.0.3987.132"
		}
	}
}
```

我们开用使用filebeat提供的modules采集nginx日志也成功,而且可以看到展示的信息也更加完善了。可以看到filebeat提供的各种modules就是帮我们做了一些解析工作，其他modules的用法类似。


## 3.7 使用Kibana展示

- 修改filebeat配置

```shell script
[iio@192 filebeat]$ vi iio.yml 

filebeat.inputs:
#- type: log
#  enabled: true
#  paths:
#    - /usr/local/nginx/logs/*.log
#  tags: ["nginx"]
setup.template.settings:
  index.number_of_shards: 1
output.elasticsearch:
  hosts: ["http://192.168.237.11:9200"]
filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false
setup.kibana:
  host: "192.168.237.11:5601"
~   
```

- 启动Kibana

下面的安装仪表板依赖Kibana，也就是Kibana必须启动才能安装仪表盘

- 安装仪表盘

```
#安装仪表盘到Kibana
./metricbeat setup --dashboards
```
![2020030704](https://image.eelve.com/eblog/2020030704-84aabcd7f21a4af0ab1ccb694e2f5f47.png)

- 启动Filebeat

```shell script
./filebeat  -e -c iio.yml
```

- 观察结果

![2020030705](https://image.eelve.com/eblog/2020030705-77c1f59279aa40d4b8319560da4a6ae5.png)
![2020030706](https://image.eelve.com/eblog/2020030706-9f858efbcaba4dd898b07e54c2f42a0d.png)

可以看到Kibana内置的nginx的仪表盘的展示情况，展示相当仿佛，并且还可以随着时间变化而刷新

# 肆、Filebeat工作原理

Filebeat由两个主要组件组成：prospector 和 harvester。

- harvester：
  - 负责读取单个文件的内容。
  - 如果文件在读取时被删除或重命名，Filebeat将继续读取文件。
  
- prospector：
  - prospector 负责管理harvester并找到所有要读取的文件来源。
  - 如果输入类型为日志，则查找器将查找路径匹配的所有文件，并为每个文件启动一个harvester。
  - Filebeat目前支持两种prospector类型：log和stdin。
- Filebeat如何保持文件的状态
  - Filebeat 保存每个文件的状态并经常将状态刷新到磁盘上的注册文件中。
  - 该状态用于记住harvester正在读取的最后偏移量，并确保发送所有日志行。
  - 如果输出（例如Elasticsearch或Logstash）无法访问，Filebeat会跟踪最后发送的行，并在输出再次可用时继续读取文件。
  - 在Filebeat运行时，每个prospector内存中也会保存的文件状态信息，当重新启动Filebeat时，将使用注册
  - 文件的数据来重建文件状态，Filebeat将每个harvester在从保存的最后偏移量继续读取。
  - 文件状态记录在data/registry文件中。
  
```shell script
启动命令
./filebeat -e -c itcast.yml
./filebeat -e -c itcast.yml -d "publish"
#参数说明
-e: 输出到标准输出,默认输出到syslog和logs下
-c: 指定配置文件
-d: 输出debug信息

#测试： ./filebeat -e -c iio.yml -d "publish"

```  

---

【**后面的话**】在本文中我们全面的体验了一下filebeat，还和Kibana结合应用了，我们可以看到filebeat和elk三大剑客整合的非常好，特别是Kibana提供了丰富的仪表盘，大大的方便了我们展示。后面还有再结合一下Logstash，使用以下过滤功能。

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
