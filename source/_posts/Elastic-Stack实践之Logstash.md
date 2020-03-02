---
layout: elastic
title: Elastic Stack实践之Logstash
date: 2020-03-02 21:49:22
tags: [ELK,Logstash]
categories: Elastic Stack
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

启动命令：./logstash -e 'input { stdin { } } output { stdout {} }'

```shell script
[iio@192 bin]$ ./logstash -e 'input { stdin { } } output { stdout {} }'
Sending Logstash logs to /usr/elastic/logstash/logs which is now configured via log4j2.properties
[2020-03-01T18:00:48,316][WARN ][logstash.config.source.multilocal] Ignoring the 'pipelines.yml' file because modules or command line options are specified
[2020-03-01T18:00:48,495][INFO ][logstash.runner          ] Starting Logstash {"logstash.version"=>"7.6.0"}
[2020-03-01T18:00:50,395][INFO ][org.reflections.Reflections] Reflections took 48 ms to scan 1 urls, producing 20 keys and 40 values 
[2020-03-01T18:00:51,788][WARN ][org.logstash.instrument.metrics.gauge.LazyDelegatingGauge][main] A gauge metric of an unknown type (org.jruby.RubyArray) has been create for key: cluster_uuids. This may result in invalid serialization.  It is recommended to log an issue to the responsible developer/development team.
[2020-03-01T18:00:51,810][INFO ][logstash.javapipeline    ][main] Starting pipeline {:pipeline_id=>"main", "pipeline.workers"=>4, "pipeline.batch.size"=>125, "pipeline.batch.delay"=>50, "pipeline.max_inflight"=>500, "pipeline.sources"=>["config string"], :thread=>"#<Thread:0x3fa519f0 run>"}
[2020-03-01T18:00:52,795][INFO ][logstash.javapipeline    ][main] Pipeline started {"pipeline.id"=>"main"}
The stdin plugin is now waiting for input:
[2020-03-01T18:00:52,892][INFO ][logstash.agent           ] Pipelines running {:count=>1, :running_pipelines=>[:main], :non_running_pipelines=>[]}
[2020-03-01T18:00:53,277][INFO ][logstash.agent           ] Successfully started Logstash API endpoint {:port=>9600}


/usr/elastic/logstash/vendor/bundle/jruby/2.5.0/gems/awesome_print-1.7.0/lib/awesome_print/formatters/base_formatter.rb:31: warning: constant ::Fixnum is deprecated
{
          "host" => "192.168.237.11",
       "message" => "",
    "@timestamp" => 2020-03-01T10:01:05.128Z,
      "@version" => "1"
}

{
          "host" => "192.168.237.11",
       "message" => "",
    "@timestamp" => 2020-03-01T10:01:05.334Z,
      "@version" => "1"
}
{
          "host" => "192.168.237.11",
       "message" => "",
    "@timestamp" => 2020-03-01T10:01:05.523Z,
      "@version" => "1"
}
hello world
{
          "host" => "192.168.237.11",
       "message" => "hello world",
    "@timestamp" => 2020-03-01T10:01:20.320Z,
      "@version" => "1"
}

```

## 4.2 采集自定义日志

### 4.2.1 日志结构

```
2020-03-02 20:08:20|ERROR|数据库连接出错|参数：id=1002
```
可以看到，日志中的内容是使用“|”进行分割的，使用，我们在处理的时候，也需要对数据做分割处理。

### 4.2.2 编写配置

```shell script
[iio@192 bin]$ vi ../config/logstash-diy.yml 
```
```shell script
input {
    file {
        path => "/usr/elastic/logs/diy.log"
        start_position => "beginning"
    }
}
filter {
    mutate {
        split => {"message"=>"|"}
    }
}
output {
    stdout { codec => rubydebug }
}

```

### 4.2.3 启动测试

```shell script
[iio@192 bin]$ ./logstash -f ../config/logstash-diy.yml 
Sending Logstash logs to /usr/elastic/logstash/logs which is now configured via log4j2.properties
[2020-03-01T18:15:06,549][WARN ][logstash.config.source.multilocal] Ignoring the 'pipelines.yml' file because modules or command line options are specified
[2020-03-01T18:15:06,682][INFO ][logstash.runner          ] Starting Logstash {"logstash.version"=>"7.6.0"}
[2020-03-01T18:15:08,737][INFO ][org.reflections.Reflections] Reflections took 38 ms to scan 1 urls, producing 20 keys and 40 values 
[2020-03-01T18:15:10,140][WARN ][org.logstash.instrument.metrics.gauge.LazyDelegatingGauge][main] A gauge metric of an unknown type (org.jruby.RubyArray) has been create for key: cluster_uuids. This may result in invalid serialization.  It is recommended to log an issue to the responsible developer/development team.
[2020-03-01T18:15:10,167][INFO ][logstash.javapipeline    ][main] Starting pipeline {:pipeline_id=>"main", "pipeline.workers"=>4, "pipeline.batch.size"=>125, "pipeline.batch.delay"=>50, "pipeline.max_inflight"=>500, "pipeline.sources"=>["/usr/elastic/logstash/config/logstash-diy.yml"], :thread=>"#<Thread:0x26d10ea9 run>"}
[2020-03-01T18:15:11,223][INFO ][logstash.inputs.file     ][main] No sincedb_path set, generating one based on the "path" setting {:sincedb_path=>"/usr/elastic/logstash/data/plugins/inputs/file/.sincedb_b626b2bdb9f76816ac98ff32e97c96bf", :path=>["/usr/elastic/logs/diy.log"]}
[2020-03-01T18:15:11,266][INFO ][logstash.javapipeline    ][main] Pipeline started {"pipeline.id"=>"main"}
[2020-03-01T18:15:11,367][INFO ][filewatch.observingtail  ][main] START, creating Discoverer, Watch with file and sincedb collections
[2020-03-01T18:15:11,367][INFO ][logstash.agent           ] Pipelines running {:count=>1, :running_pipelines=>[:main], :non_running_pipelines=>[]}
[2020-03-01T18:15:11,703][INFO ][logstash.agent           ] Successfully started Logstash API endpoint {:port=>9600}
/usr/elastic/logstash/vendor/bundle/jruby/2.5.0/gems/awesome_print-1.7.0/lib/awesome_print/formatters/base_formatter.rb:31: warning: constant ::Fixnum is deprecated
{
          "path" => "/usr/elastic/logs/diy.log",
          "host" => "192.168.237.11",
    "@timestamp" => 2020-03-01T10:16:57.260Z,
       "message" => [
        [0] "2020-03-02 20:08:20",
        [1] "ERROR",
        [2] "数据库连接出错",
        [3] "参数：id=1002"
    ],
      "@version" => "1"
}
```

然后输出日志到diy.log文件中

```shell script
echo "20120-03-02 20:21:21|ERROR|读取数据出错|参数：id=1003" >> diy.log
```

```shell script
{
          "path" => "/usr/elastic/logs/diy.log",
          "host" => "192.168.237.11",
    "@timestamp" => 2020-03-01T10:17:11.442Z,
       "message" => [
        [0] "20120-03-02 20:21:21",
        [1] "ERROR",
        [2] "读取数据出错",
        [3] "参数：id=1003"
    ],
      "@version" => "1"
}
```
我们可以看到日志已经通过"|"被分割出来了。

## 4.3 输出到Elasticsearch

### 4.3.1 编写配置

```shell script
[iio@192 bin]$ vi ../config/logstash-elastic.yml 
```
```shell script
input {
    file {
        path => "/usr/elastic/logs/diy.log"
        start_position => "beginning"
    }
}
filter {
    mutate {
        split => {"message"=>"|"}
    }
}
output {
    stdout { codec => rubydebug }
    elasticsearch {
        hosts => ["192.168.237.11:9200"]
        index => "elastic-%{+YYYY.MM.dd}"
    }
}


```

### 4.3.2 启动测试

```shell script
[iio@192 bin]$ ./logstash -f ../config/logstash-elastic.yml 
Sending Logstash logs to /usr/elastic/logstash/logs which is now configured via log4j2.properties
[2020-03-01T18:26:42,445][WARN ][logstash.config.source.multilocal] Ignoring the 'pipelines.yml' file because modules or command line options are specified
[2020-03-01T18:26:42,638][INFO ][logstash.runner          ] Starting Logstash {"logstash.version"=>"7.6.0"}
[2020-03-01T18:26:45,170][INFO ][org.reflections.Reflections] Reflections took 46 ms to scan 1 urls, producing 20 keys and 40 values 
[2020-03-01T18:26:47,179][INFO ][logstash.outputs.elasticsearch][main] Elasticsearch pool URLs updated {:changes=>{:removed=>[], :added=>[http://192.168.237.11:9200/]}}
[2020-03-01T18:26:47,487][WARN ][logstash.outputs.elasticsearch][main] Restored connection to ES instance {:url=>"http://192.168.237.11:9200/"}
[2020-03-01T18:26:47,553][INFO ][logstash.outputs.elasticsearch][main] ES Output version determined {:es_version=>7}
[2020-03-01T18:26:47,561][WARN ][logstash.outputs.elasticsearch][main] Detected a 6.x and above cluster: the `type` event field won't be used to determine the document _type {:es_version=>7}
[2020-03-01T18:26:47,760][INFO ][logstash.outputs.elasticsearch][main] New Elasticsearch output {:class=>"LogStash::Outputs::ElasticSearch", :hosts=>["//192.168.237.11:9200"]}
[2020-03-01T18:26:47,855][INFO ][logstash.outputs.elasticsearch][main] Using default mapping template
[2020-03-01T18:26:47,900][WARN ][org.logstash.instrument.metrics.gauge.LazyDelegatingGauge][main] A gauge metric of an unknown type (org.jruby.specialized.RubyArrayOneObject) has been create for key: cluster_uuids. This may result in invalid serialization.  It is recommended to log an issue to the responsible developer/development team.
[2020-03-01T18:26:47,914][INFO ][logstash.javapipeline    ][main] Starting pipeline {:pipeline_id=>"main", "pipeline.workers"=>4, "pipeline.batch.size"=>125, "pipeline.batch.delay"=>50, "pipeline.max_inflight"=>500, "pipeline.sources"=>["/usr/elastic/logstash/config/logstash-elastic.yml"], :thread=>"#<Thread:0x77e7dd14 run>"}
[2020-03-01T18:26:48,011][INFO ][logstash.outputs.elasticsearch][main] Attempting to install template {:manage_template=>{"index_patterns"=>"logstash-*", "version"=>60001, "settings"=>{"index.refresh_interval"=>"5s", "number_of_shards"=>1}, "mappings"=>{"dynamic_templates"=>[{"message_field"=>{"path_match"=>"message", "match_mapping_type"=>"string", "mapping"=>{"type"=>"text", "norms"=>false}}}, {"string_fields"=>{"match"=>"*", "match_mapping_type"=>"string", "mapping"=>{"type"=>"text", "norms"=>false, "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}}}}], "properties"=>{"@timestamp"=>{"type"=>"date"}, "@version"=>{"type"=>"keyword"}, "geoip"=>{"dynamic"=>true, "properties"=>{"ip"=>{"type"=>"ip"}, "location"=>{"type"=>"geo_point"}, "latitude"=>{"type"=>"half_float"}, "longitude"=>{"type"=>"half_float"}}}}}}}
[2020-03-01T18:26:49,458][INFO ][logstash.inputs.file     ][main] No sincedb_path set, generating one based on the "path" setting {:sincedb_path=>"/usr/elastic/logstash/data/plugins/inputs/file/.sincedb_b626b2bdb9f76816ac98ff32e97c96bf", :path=>["/usr/elastic/logs/diy.log"]}
[2020-03-01T18:26:49,506][INFO ][logstash.javapipeline    ][main] Pipeline started {"pipeline.id"=>"main"}
[2020-03-01T18:26:49,600][INFO ][logstash.agent           ] Pipelines running {:count=>1, :running_pipelines=>[:main], :non_running_pipelines=>[]}
[2020-03-01T18:26:49,622][INFO ][filewatch.observingtail  ][main] START, creating Discoverer, Watch with file and sincedb collections
[2020-03-01T18:26:50,082][INFO ][logstash.agent           ] Successfully started Logstash API endpoint {:port=>9600}
/usr/elastic/logstash/vendor/bundle/jruby/2.5.0/gems/awesome_print-1.7.0/lib/awesome_print/formatters/base_formatter.rb:31: warning: constant ::Fixnum is deprecated
{
    "@timestamp" => 2020-03-01T10:27:13.467Z,
          "path" => "/usr/elastic/logs/diy.log",
      "@version" => "1",
       "message" => [
        [0] "20120-03-02 20:21:21",
        [1] "ERROR",
        [2] "读取数据出错",
        [3] "参数：id=1003"
    ],
          "host" => "192.168.237.11"
}

```

![2020030201](https://eelve.com/upload/2020/3/2020030201-c786b611e3664d718a8bc7a24d556d09.png)


## 4.3 停止服务

```shell script
[iio@192 logs]$ jps
7110 Logstash
6794 Elasticsearch
7183 Jps
[iio@192 logs]$ kill -9 7110
[iio@192 logs]$ kill -9 6794
[iio@192 logs]$ 

```

---

【**后面的话**】Logstash作为三大剑客，主要是采集和过滤，但是在现在采集公文部分被Beats家族取代，所以目前最重要的作用是过滤，但是也不是说不能采集了，只是相比于Beat来说效率更低而已。另外还有一点一个输入可以有多份输出,在4.3中也有应用,下面是主要的配置：

```
input { #输入
    stdin { ... } #标准输入
}
filter { #过滤，对数据进行分割、截取等处理
    ...
}
output { #输出1
    stdout { ... } #标准输出

    elasticsearch { #输出2
        hosts => [ "192.168.40.133:9200","192.168.40.134:9200","192.168.40.135:9200"]
    }
 }

```

---
![薏米笔记](https://eelve.com/upload/2019/8/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
