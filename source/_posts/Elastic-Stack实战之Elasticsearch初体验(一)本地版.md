---
layout: elastic
title: Elastic Stack实战之Elasticsearch初体验(一)
date: 2020-03-01 12:34:22
tags: hide
categories: hide
---

【**前面的话**】前面已经准备好了服务器环境，今天就来开始安装[Elasticsearch](https://www.elastic.co/cn/elasticsearch)然后体验。

---

# 壹、软件版本
```yaml
Centos：CentOS-7-x86_64-Minimal-1908
VM: 15.5.0 build-14665864
Java: 1.8.0_211
Elasticsearch: elasticsearch-7.6.0
```
这里说一下，Elasticsearch是依赖Java环境的，elasticsearch-7.6.0要求至少为1.8，官方建议为11.如果你的机器上还没有Java环境的话，记得要先准备环境。当然安装也是非常简单：

1.下载linux版本的jdk

2.解压然后配置环境变量

```shell script
#java environment
export JAVA_HOME=/usr/jdk
export CLASSPATH=.:${JAVA_HOME}/jre/lib/rt.jar:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar
export PATH=$PATH:${JAVA_HOME}/bin
```

3.刷新环境变量，检查结果

```shell script
[root@192 ~]# source /etc/profile
```

```shell script
[root@192 ~]# java -version
java version "1.8.0_211"
Java(TM) SE Runtime Environment (build 1.8.0_211-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.211-b12, mixed mode)

```

# 贰、Elasticsearch安装

## 2.1 下载地址

[elasticsearch-7.6.0-linux-x86_64.tar.gz](https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.6.0-linux-x86_64.tar.gz)
---

## 2.2 解压elasticsearch-7.6.0-linux-x86_64.tar.gz

```shell script
tar -zvxf elasticsearch-7.6.0-linux-x86_64.tar.gz -C /usr/elastic
```
## 2.3 修改elasticsearch配置

```shell script
[root@192 elastic]# cd /usr/elastic/elasticsearch/config/
[root@192 config]# vi elasticsearch.yml

```
下面给出单机版安装最小配置
```yaml
node.name: node-1 #节点名字
network.host: 0.0.0.0 #生产配置为127.0.0.1，测试可以为其他地址
http.port: 9200 #端口
cluster.initial_master_nodes: ["node-1"] #初始化master节点
http.cors.enabled: true  #开启跨域
http.cors.allow-origin: "*" #开启跨域
```
## 2.4 后台启动
```shell script
[root@192 bin]# ./elasticsearch
[1] 1620
[root@192 bin]# future versions of Elasticsearch will require Java 11; your Java version from [/usr/jdk/jre] does not meet this requirement
[2020-03-01T11:55:38,871][ERROR][o.e.b.ElasticsearchUncaughtExceptionHandler] [node-1] uncaught exception in thread [main]
org.elasticsearch.bootstrap.StartupException: java.lang.RuntimeException: can not run elasticsearch as root
	at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:174) ~[elasticsearch-7.6.0.jar:7.6.0]
	at org.elasticsearch.bootstrap.Elasticsearch.execute(Elasticsearch.java:161) ~[elasticsearch-7.6.0.jar:7.6.0]
	at org.elasticsearch.cli.EnvironmentAwareCommand.execute(EnvironmentAwareCommand.java:86) ~[elasticsearch-7.6.0.jar:7.6.0]
	at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:125) ~[elasticsearch-cli-7.6.0.jar:7.6.0]
	at org.elasticsearch.cli.Command.main(Command.java:90) ~[elasticsearch-cli-7.6.0.jar:7.6.0]
	at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:126) ~[elasticsearch-7.6.0.jar:7.6.0]
	at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:92) ~[elasticsearch-7.6.0.jar:7.6.0]
Caused by: java.lang.RuntimeException: can not run elasticsearch as root
	at org.elasticsearch.bootstrap.Bootstrap.initializeNatives(Bootstrap.java:105) ~[elasticsearch-7.6.0.jar:7.6.0]
	at org.elasticsearch.bootstrap.Bootstrap.setup(Bootstrap.java:172) ~[elasticsearch-7.6.0.jar:7.6.0]
	at org.elasticsearch.bootstrap.Bootstrap.init(Bootstrap.java:349) ~[elasticsearch-7.6.0.jar:7.6.0]
	at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:170) ~[elasticsearch-7.6.0.jar:7.6.0]
	... 6 more
uncaught exception in thread [main]
java.lang.RuntimeException: can not run elasticsearch as root
	at org.elasticsearch.bootstrap.Bootstrap.initializeNatives(Bootstrap.java:105)
	at org.elasticsearch.bootstrap.Bootstrap.setup(Bootstrap.java:172)
	at org.elasticsearch.bootstrap.Bootstrap.init(Bootstrap.java:349)
	at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:170)
	at org.elasticsearch.bootstrap.Elasticsearch.execute(Elasticsearch.java:161)
	at org.elasticsearch.cli.EnvironmentAwareCommand.execute(EnvironmentAwareCommand.java:86)
	at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:125)
	at org.elasticsearch.cli.Command.main(Command.java:90)
	at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:126)
	at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:92)
For complete error details, refer to the log at /usr/elastic/elasticsearch/logs/eelve.log

```
这里说的是elasticsearch不能用root用户启动，这里就需要添加一个用户，然后重新启动

```shell script
[root@192 bin]# adduser iio
[root@192 bin]# passwd iio
Changing password for user iio.
New password: 
Retype new password: 
passwd: all authentication tokens updated successfully.

```
然后更改elasticsearch用户组
```shell script
[root@192 bin]# chown -R iio:iio /usr/elastic/elasticsearch/
```

然后就可以启动成功了

```shell script
[root@192 bin]# su iio
[iio@192 bin]$ ./elasticsearch
future versions of Elasticsearch will require Java 11; your Java version from [/usr/jdk/jre] does not meet this requirement
[2020-03-01T12:03:32,970][INFO ][o.e.e.NodeEnvironment    ] [node-1] using [1] data paths, mounts [[/ (rootfs)]], net usable_space [20.9gb], net total_space [25.9gb], types [rootfs]
[2020-03-01T12:03:32,972][INFO ][o.e.e.NodeEnvironment    ] [node-1] heap size [990.7mb], compressed ordinary object pointers [true]
[2020-03-01T12:03:33,103][INFO ][o.e.n.Node               ] [node-1] node name [node-1], node ID [2IBvVjP0QbeA-FDLFoLFFg], cluster name [eelve]
[2020-03-01T12:03:33,103][INFO ][o.e.n.Node               ] [node-1] version[7.6.0], pid[1952], build[default/tar/7f634e9f44834fbc12724506cc1da681b0c3b1e3/2020-02-06T00:09:00.449973Z], OS[Linux/3.10.0-1062.el7.x86_64/amd64], JVM[Oracle Corporation/Java HotSpot(TM) 64-Bit Server VM/1.8.0_211/25.211-b12]
[2020-03-01T12:03:33,103][INFO ][o.e.n.Node               ] [node-1] JVM home [/usr/jdk/jre]
[2020-03-01T12:03:33,104][INFO ][o.e.n.Node               ] [node-1] JVM arguments [-Des.networkaddress.cache.ttl=60, -Des.networkaddress.cache.negative.ttl=10, -XX:+AlwaysPreTouch, -Xss1m, -Djava.awt.headless=true, -Dfile.encoding=UTF-8, -Djna.nosys=true, -XX:-OmitStackTraceInFastThrow, -Dio.netty.noUnsafe=true, -Dio.netty.noKeySetOptimization=true, -Dio.netty.recycler.maxCapacityPerThread=0, -Dio.netty.allocator.numDirectArenas=0, -Dlog4j.shutdownHookEnabled=false, -Dlog4j2.disable.jmx=true, -Djava.locale.providers=COMPAT, -Xms1g, -Xmx1g, -XX:+UseConcMarkSweepGC, -XX:CMSInitiatingOccupancyFraction=75, -XX:+UseCMSInitiatingOccupancyOnly, -Djava.io.tmpdir=/tmp/elasticsearch-5828849950285366888, -XX:+HeapDumpOnOutOfMemoryError, -XX:HeapDumpPath=data, -XX:ErrorFile=logs/hs_err_pid%p.log, -XX:+PrintGCDetails, -XX:+PrintGCDateStamps, -XX:+PrintTenuringDistribution, -XX:+PrintGCApplicationStoppedTime, -Xloggc:logs/gc.log, -XX:+UseGCLogFileRotation, -XX:NumberOfGCLogFiles=32, -XX:GCLogFileSize=64m, -XX:MaxDirectMemorySize=536870912, -Des.path.home=/usr/elastic/elasticsearch, -Des.path.conf=/usr/elastic/elasticsearch/config, -Des.distribution.flavor=default, -Des.distribution.type=tar, -Des.bundled_jdk=true]
[2020-03-01T12:03:34,656][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [aggs-matrix-stats]
[2020-03-01T12:03:34,656][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [analysis-common]
[2020-03-01T12:03:34,656][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [flattened]
[2020-03-01T12:03:34,657][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [frozen-indices]
[2020-03-01T12:03:34,657][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [ingest-common]
[2020-03-01T12:03:34,657][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [ingest-geoip]
[2020-03-01T12:03:34,657][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [ingest-user-agent]
[2020-03-01T12:03:34,657][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [lang-expression]
[2020-03-01T12:03:34,658][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [lang-mustache]
[2020-03-01T12:03:34,658][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [lang-painless]
[2020-03-01T12:03:34,658][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [mapper-extras]
[2020-03-01T12:03:34,658][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [parent-join]
[2020-03-01T12:03:34,658][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [percolator]
[2020-03-01T12:03:34,658][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [rank-eval]
[2020-03-01T12:03:34,659][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [reindex]
[2020-03-01T12:03:34,659][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [repository-url]
[2020-03-01T12:03:34,659][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [search-business-rules]
[2020-03-01T12:03:34,659][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [spatial]
[2020-03-01T12:03:34,659][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [transform]
[2020-03-01T12:03:34,659][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [transport-netty4]
[2020-03-01T12:03:34,659][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [vectors]
[2020-03-01T12:03:34,660][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [x-pack-analytics]
[2020-03-01T12:03:34,660][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [x-pack-ccr]
[2020-03-01T12:03:34,660][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [x-pack-core]
[2020-03-01T12:03:34,660][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [x-pack-deprecation]
[2020-03-01T12:03:34,660][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [x-pack-enrich]
[2020-03-01T12:03:34,660][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [x-pack-graph]
[2020-03-01T12:03:34,661][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [x-pack-ilm]
[2020-03-01T12:03:34,661][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [x-pack-logstash]
[2020-03-01T12:03:34,661][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [x-pack-ml]
[2020-03-01T12:03:34,661][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [x-pack-monitoring]
[2020-03-01T12:03:34,661][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [x-pack-rollup]
[2020-03-01T12:03:34,661][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [x-pack-security]
[2020-03-01T12:03:34,662][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [x-pack-sql]
[2020-03-01T12:03:34,662][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [x-pack-voting-only-node]
[2020-03-01T12:03:34,662][INFO ][o.e.p.PluginsService     ] [node-1] loaded module [x-pack-watcher]
[2020-03-01T12:03:34,662][INFO ][o.e.p.PluginsService     ] [node-1] no plugins loaded
[2020-03-01T12:03:37,968][INFO ][o.e.x.s.a.s.FileRolesStore] [node-1] parsed [0] roles from file [/usr/elastic/elasticsearch/config/roles.yml]
[2020-03-01T12:03:38,382][INFO ][o.e.x.m.p.l.CppLogMessageHandler] [node-1] [controller/2044] [Main.cc@110] controller (64 bit): Version 7.6.0 (Build 1c8cca13fa9631) Copyright (c) 2020 Elasticsearch BV
[2020-03-01T12:03:38,870][DEBUG][o.e.a.ActionModule       ] [node-1] Using REST wrapper from plugin org.elasticsearch.xpack.security.Security
[2020-03-01T12:03:38,999][INFO ][o.e.d.DiscoveryModule    ] [node-1] using discovery type [zen] and seed hosts providers [settings]
[2020-03-01T12:03:39,805][INFO ][o.e.n.Node               ] [node-1] initialized
[2020-03-01T12:03:39,805][INFO ][o.e.n.Node               ] [node-1] starting ...
[2020-03-01T12:03:39,954][INFO ][o.e.t.TransportService   ] [node-1] publish_address {192.168.237.11:9300}, bound_addresses {[::]:9300}
[2020-03-01T12:03:40,352][INFO ][o.e.b.BootstrapChecks    ] [node-1] bound or publishing to a non-loopback address, enforcing bootstrap checks
[2020-03-01T12:03:40,380][INFO ][o.e.c.c.Coordinator      ] [node-1] cluster UUID [PKv57dWOS5OAazrBgqoLcQ]
[2020-03-01T12:03:40,565][INFO ][o.e.c.s.MasterService    ] [node-1] elected-as-master ([1] nodes joined)[{node-1}{2IBvVjP0QbeA-FDLFoLFFg}{kGzTwK3ZRLGujF_9zhpR9A}{192.168.237.11}{192.168.237.11:9300}{dilm}{ml.machine_memory=3954036736, xpack.installed=true, ml.max_open_jobs=20} elect leader, _BECOME_MASTER_TASK_, _FINISH_ELECTION_], term: 9, version: 279, delta: master node changed {previous [], current [{node-1}{2IBvVjP0QbeA-FDLFoLFFg}{kGzTwK3ZRLGujF_9zhpR9A}{192.168.237.11}{192.168.237.11:9300}{dilm}{ml.machine_memory=3954036736, xpack.installed=true, ml.max_open_jobs=20}]}
[2020-03-01T12:03:40,674][INFO ][o.e.c.s.ClusterApplierService] [node-1] master node changed {previous [], current [{node-1}{2IBvVjP0QbeA-FDLFoLFFg}{kGzTwK3ZRLGujF_9zhpR9A}{192.168.237.11}{192.168.237.11:9300}{dilm}{ml.machine_memory=3954036736, xpack.installed=true, ml.max_open_jobs=20}]}, term: 9, version: 279, reason: Publication{term=9, version=279}
[2020-03-01T12:03:40,741][INFO ][o.e.h.AbstractHttpServerTransport] [node-1] publish_address {192.168.237.11:9200}, bound_addresses {[::]:9200}
[2020-03-01T12:03:40,741][INFO ][o.e.n.Node               ] [node-1] started
[2020-03-01T12:03:41,213][INFO ][o.e.l.LicenseService     ] [node-1] license [b7ab8f1c-3e13-45f0-a4d2-6f5f31a554a1] mode [basic] - valid
[2020-03-01T12:03:41,214][INFO ][o.e.x.s.s.SecurityStatusChangeListener] [node-1] Active license is now [BASIC]; Security is disabled
[2020-03-01T12:03:41,220][INFO ][o.e.g.GatewayService     ] [node-1] recovered [9] indices into cluster_state
[2020-03-01T12:03:42,116][INFO ][o.e.c.r.a.AllocationService] [node-1] Cluster health status changed from [RED] to [YELLOW] (reason: [shards started [[metricbeat-7.6.0][0]]]).

```

这里说明一下，有可能会碰到内存不足，因为elasticsearch的**jvm.options**中配置的内存参数为1g，如果你的虚拟机给的内存不够就会出问题
修改**jvm.options**中的虚拟机参数为合适的参数，然后就可以启动成功了

```yaml
-Xms1g
-Xmx1g
```
这里还需要修改liunx的环境配置参数，避免重新启动的时候报错：
vi 编辑 /etc/security/limits.conf，在末尾加上：

```yaml
* soft nofile 65536
* hard nofile 65536
* soft nproc 32000
* hard nproc 32000
* hard memlock unlimited
* soft memlock unlimited
```
vi 编辑 /etc/sysctl.conf，在末尾加上：

```yaml
vm.max_map_count=655360
```

然后刷新配置

```yaml
[root@192 bin]# sysctl -p
kernel.printk = 5
vm.max_map_count = 655360
[root@192 bin]#

```
再次启动，然后检查

![2020010301](https://eelve.com/upload/2020/3/2020010301-5b565f99650d4acbb3ba464408dca641.png)
![2020030102](https://eelve.com/upload/2020/3/2020030102-ff4ef388edeb4bb1b88ddf45df96543f.png)
---
【**后面的话**】
后台启动

```shell script
[iio@192 bin]$ ./elasticsearch -d
```

查看进程,这里的常用的命令可能不好使，我们可以使用下面的命令查找进程

```shell script
[iio@192 bin]$ jps
2294 Jps
2135 Elasticsearch
[iio@192 bin]$ kill -9 2135
```


---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
