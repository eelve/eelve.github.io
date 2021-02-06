---
layout: elastic
title: Elastic Stack实战之Kibana初体验
date: 2020-03-03 19:49:22
tags: hide
categories: hide
description: 在前面已经安装好了Elasticsearch和Logstash，今天就来Kibana进行一下初步体验。
---

---
layout: elastic
title: Elastic Stack实战之Kibana初体验
date: 2020-03-03 19:49:22
tags: [ELK,Kibana]
categories: Elastic Stack
---

【**前面的话**】在前面已经安装好了Elasticsearch和Logstash，今天就来[Kibana](https://www.elastic.co/cn/kibana)进行一下初步体验。


---

# 壹、软件版本

```yaml
Centos：CentOS-7-x86_64-Minimal-1908
VM: 15.5.0 build-14665864
Java: 1.8.0_211
Elasticsearch: elasticsearch-7.6.0
Logstash: logstash-7.6.0
Kibana: kibana-7.6.0
```

# 贰、Kibana介绍

![illustrated-screenshot-hero-kibana](https://eelve.com/upload/2020/3/illustrated-screenshot-hero-kibana-ab9ac4d9e6e748fda40fbdff14591bc6.png)

    Kibana是了解 Elastic Stack 的窗口。
    
    通过 Kibana，您可以对自己的 Elasticsearch 进行可视化，还可以在 Elastic Stack 中进行导航，这样您便可以进行各种操作了，从跟踪查询负载，到理解请求如何流经您的整个应用，都能轻松完成。 

**可视化和分析：** Kibana 让您能够自由地选择如何呈现自己的数据，一张图片胜过千万行日志，可以用下面几个特点来阐述：

![animated-gif-lens-drag-and-drop](https://eelve.com/upload/2020/3/animated-gif-lens-drag-and-drop-150ecdc9e8314ff798ae5958edac5963.gif)

- **基本内容：** Kibana 核心产品搭载了一批经典功能：柱状图、线状图、饼图、旭日图，等等。当然啦，您还可以搜索自己的所有文档。            
 
 ![kibana-basics-with-vega](https://eelve.com/upload/2020/3/kibana-basics-with-vega-87818e2dc2df4800bd116de2eb8ecf39.jpg)
 
- **位置分析：** 借助 Elastic Maps，探索位置数据，还可以获得创意并对定制图层和矢量形状进行可视化。            

![geo](https://eelve.com/upload/2020/3/geo-101256c64dc24b04abede3b0088ef4b8.jpg)

- **时间序列：** 借助精选的时序数据 UI，对您 Elasticsearch 中的数据执行高级时间序列分析。您可以利用功能强大、简单易学的表达式来描述查询、转换和可视化。

![kibana-timeseries](https://eelve.com/upload/2020/3/kibana-timeseries-9cdce1ca946f44da9279e8c7577709e0.jpg)

- **Machine Learning：** 借助非监督型 Machine Learning 功能来检测隐藏在您 Elasticsearch 数据中的异常情况并探索那些对它们有显著影响的属性。 

![kibana-machine-learning](https://eelve.com/upload/2020/3/kibana-machine-learning-5148691b6084492fb47558ebbee177e1.jpg)

- **图表和网络：** 凭借搜索引擎的相关性功能，结合 Graph 关联分析，揭示您 Elasticsearch 数据中极其常见的关系。 

![kibana-graph](https://eelve.com/upload/2020/3/kibana-graph-e0e161ba7f3a4d6bb3c0640701e49a30.jpg)


# 叁、Kibana安装

## 3.1 下载地址

[kibana-7.6.0-linux-x86_64.tar.gz](https://artifacts.elastic.co/downloads/kibana/kibana-7.6.0-linux-x86_64.tar.gz)

---

## 3.2 解压kibana-7.6.0-linux-x86_64.tar.gz

```shell script
tar -zvxf kibana-7.6.0-linux-x86_64.tar.gz -C /usr/elastic
```
## 3.3 kibana配置说明

默认配置配置不需要改，下面给出一个最小的配置

```shell script
server.port: 5601 #浏览器访问端口
server.host: "192.168.237.11"  #对外的服务地址
elasticsearch.hosts: ["http://192.168.237.11:9200"] #这里为你的elasticsearch集群的地址
```

# 肆、Kibana简单使用

## 4.1 启动Elasticsearch

首先我门要启动Elasticsearch，不然Kibana没有数据来源。同时检查是否启动成功，如下图

![2020030301](https://eelve.com/upload/2020/3/2020030301-00f0ff22c74c4275be3690daa471cfa2.jpg)

## 4.2 启动Kibana

```shell script
[iio@192 bin]$ ./kibana

```

然后观察日志

```shell script
  log   [13:27:27.338] [info][plugins-service] Plugin "case" is disabled.
  log   [13:27:33.648] [info][plugins-system] Setting up [37] plugins: [licensing,taskManager,siem,code,infra,encryptedSavedObjects,usageCollection,metrics,canvas,timelion,features,security,apm_oss,translations,reporting,uiActions,data,navigation,newsfeed,share,status_page,home,spaces,cloud,apm,graph,bfetch,kibana_legacy,management,dev_tools,eui_utils,inspector,expressions,visualizations,embeddable,advancedUiActions,dashboard_embeddable_container]
  log   [13:27:33.650] [info][licensing][plugins] Setting up plugin
  log   [13:27:33.652] [info][plugins][taskManager] Setting up plugin
  log   [13:27:33.667] [info][plugins][siem] Setting up plugin
  log   [13:27:33.667] [info][code][plugins] Setting up plugin
  log   [13:27:33.668] [info][infra][plugins] Setting up plugin
  log   [13:27:33.670] [info][encryptedSavedObjects][plugins] Setting up plugin
  log   [13:27:33.671] [warning][config][encryptedSavedObjects][plugins] Generating a random key for xpack.encryptedSavedObjects.encryptionKey. To be able to decrypt encrypted saved objects attributes after restart, please set xpack.encryptedSavedObjects.encryptionKey in kibana.yml
  log   [13:27:33.677] [info][plugins][usageCollection] Setting up plugin
  log   [13:27:33.679] [info][metrics][plugins] Setting up plugin
  log   [13:27:33.680] [info][canvas][plugins] Setting up plugin
  log   [13:27:33.687] [info][plugins][timelion] Setting up plugin
  log   [13:27:33.689] [info][features][plugins] Setting up plugin
  log   [13:27:33.690] [info][plugins][security] Setting up plugin
  log   [13:27:33.691] [warning][config][plugins][security] Generating a random key for xpack.security.encryptionKey. To prevent sessions from being invalidated on restart, please set xpack.security.encryptionKey in kibana.yml
  log   [13:27:33.691] [warning][config][plugins][security] Session cookies will be transmitted over insecure connections. This is not recommended.
  log   [13:27:33.714] [info][apm_oss][plugins] Setting up plugin
  log   [13:27:33.715] [info][plugins][translations] Setting up plugin
  log   [13:27:33.715] [info][data][plugins] Setting up plugin
  log   [13:27:33.722] [info][plugins][share] Setting up plugin
  log   [13:27:33.724] [info][home][plugins] Setting up plugin
  log   [13:27:33.730] [info][plugins][spaces] Setting up plugin
  log   [13:27:33.736] [info][cloud][plugins] Setting up plugin
  log   [13:27:33.738] [info][apm][plugins] Setting up plugin
  log   [13:27:33.915] [info][graph][plugins] Setting up plugin
  log   [13:27:33.921] [info][bfetch][plugins] Setting up plugin
  log   [13:27:33.933] [info][savedobjects-service] Waiting until all Elasticsearch nodes are compatible with Kibana before starting saved objects migrations...
  log   [13:27:33.933] [info][savedobjects-service] Starting saved objects migrations
  log   [13:27:34.115] [info][plugins-system] Starting [22] plugins: [licensing,taskManager,siem,code,infra,encryptedSavedObjects,usageCollection,metrics,canvas,timelion,features,security,apm_oss,translations,data,share,home,spaces,cloud,apm,graph,bfetch]
  log   [13:27:40.328] [info][status][plugin:kibana@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:40.346] [info][status][plugin:elasticsearch@7.6.0] Status changed from uninitialized to yellow - Waiting for Elasticsearch
  log   [13:27:40.348] [info][status][plugin:elasticsearch@7.6.0] Status changed from yellow to green - Ready
  log   [13:27:40.358] [info][status][plugin:xpack_main@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:40.392] [info][status][plugin:graph@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:40.426] [info][kibana-monitoring][monitoring] Starting monitoring stats collection
  log   [13:27:40.430] [info][status][plugin:monitoring@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:40.471] [info][status][plugin:spaces@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:40.507] [info][status][plugin:security@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:40.543] [info][status][plugin:searchprofiler@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:40.557] [info][status][plugin:ml@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:40.807] [info][status][plugin:tilemap@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:40.812] [info][status][plugin:watcher@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:40.836] [info][status][plugin:grokdebugger@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:40.856] [info][status][plugin:dashboard_mode@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:40.863] [info][status][plugin:logstash@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:40.891] [info][status][plugin:beats_management@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:40.958] [info][status][plugin:apm_oss@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.000] [info][status][plugin:apm@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.071] [info][status][plugin:maps@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.083] [info][status][plugin:interpreter@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.122] [info][status][plugin:canvas@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.130] [info][status][plugin:license_management@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.141] [info][status][plugin:index_management@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.228] [info][status][plugin:console@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.238] [info][status][plugin:console_extensions@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.245] [info][status][plugin:index_lifecycle_management@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.286] [info][status][plugin:kuery_autocomplete@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.304] [info][status][plugin:metrics@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.425] [info][status][plugin:infra@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.437] [info][plugins][taskManager][taskManager] TaskManager is identified by the Kibana UUID: ce42b997-a913-4d58-be46-bb1937feedd6
  log   [13:27:41.441] [info][status][plugin:task_manager@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.448] [info][status][plugin:rollup@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.547] [info][status][plugin:transform@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.555] [info][status][plugin:encryptedSavedObjects@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.605] [info][status][plugin:actions@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.677] [info][status][plugin:alerting@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.853] [info][status][plugin:siem@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.868] [info][status][plugin:remote_clusters@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.876] [info][status][plugin:cross_cluster_replication@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.937] [info][status][plugin:upgrade_assistant@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:41.994] [info][status][plugin:uptime@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.006] [info][status][plugin:oss_telemetry@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.022] [info][status][plugin:file_upload@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.032] [info][status][plugin:data@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.067] [info][status][plugin:lens@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.136] [info][status][plugin:snapshot_restore@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.151] [info][status][plugin:input_control_vis@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.164] [info][status][plugin:navigation@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.169] [info][status][plugin:management@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.174] [info][status][plugin:kibana_react@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.178] [info][status][plugin:region_map@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.217] [info][status][plugin:telemetry@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.226] [info][status][plugin:metric_vis@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.230] [info][status][plugin:markdown_vis@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.399] [info][status][plugin:timelion@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.403] [info][status][plugin:ui_metric@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.406] [info][status][plugin:tagcloud@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.410] [info][status][plugin:table_vis@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.414] [info][status][plugin:vega@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:42.421] [warning][browser-driver][reporting] Enabling the Chromium sandbox provides an additional layer of protection.
  log   [13:27:44.878] [warning][reporting] Generating a random key for xpack.reporting.encryptionKey. To prevent pending reports from failing on restart, please set xpack.reporting.encryptionKey in kibana.yml
  log   [13:27:44.888] [info][status][plugin:reporting@7.6.0] Status changed from uninitialized to green - Ready
  log   [13:27:44.970] [info][listening] Server running at http://192.168.237.11:5601
  log   [13:27:45.502] [info][server][Kibana][http] http server running at http://192.168.237.11:5601
  log   [13:27:45.549] [error][reporting] The Reporting plugin encountered issues launching Chromium in a self-test. You may have trouble generating reports.
  log   [13:27:45.549] [error][reporting] ErrorEvent {
  target:
   WebSocket {
     _events:
      [Object: null prototype] { open: [Function], error: [Function] },
     _eventsCount: 2,
     _maxListeners: undefined,
     readyState: 3,
     protocol: '',
     _binaryType: 'nodebuffer',
     _closeFrameReceived: false,
     _closeFrameSent: false,
     _closeMessage: '',
     _closeTimer: null,
     _closeCode: 1006,
     _extensions: {},
     _receiver: null,
     _sender: null,
     _socket: null,
     _isServer: false,
     _redirects: 0,
     url:
      'ws://127.0.0.1:44598/devtools/browser/cde91cb8-faad-4730-9d12-57c1e8ffd49a',
     _req: null },
  type: 'error',
  message: 'connect ECONNREFUSED 127.0.0.1:44598',
  error:
   { Error: connect ECONNREFUSED 127.0.0.1:44598
       at TCPConnectWrap.afterConnect [as oncomplete] (net.js:1107:14)
     errno: 'ECONNREFUSED',
     code: 'ECONNREFUSED',
     syscall: 'connect',
     address: '127.0.0.1',
     port: 44598 } }
  log   [13:27:45.557] [warning][reporting] See Chromium's log output at "/usr/elastic/kibana/data/headless_shell-linux/chrome_debug.log"
  log   [13:27:45.559] [warning][reporting] Reporting plugin self-check generated a warning: Error: Could not close browser client handle!
```

## 4.3 浏览器访问

![2020030302](https://eelve.com/upload/2020/3/2020030302-e7c518603e69473a8438fb32a9454154.png)

下面我们继续操作，利用搭建Elasticsearch的时候添加的数据做一个可视化图表出来

![2020030306](https://eelve.com/upload/2020/3/2020030306-5f167cf3142041ad944de9b7b0ff0eb9.png)
![2020030303](https://eelve.com/upload/2020/3/2020030303-9787af1aceb148ef8b2f6a49015630c4.png)
![2020030304](https://eelve.com/upload/2020/3/2020030304-a74acb31fabc4f4da44e96e0c7a28610.png)
![2020030305](https://eelve.com/upload/2020/3/2020030305-c4f00a780a704435b28eb34f360857da.png)
![2020030308](https://eelve.com/upload/2020/3/2020030308-53cd70f082074829afb4ee887948b24a.png)
![2020030311](https://eelve.com/upload/2020/3/2020030311-d8de4d9839d34d38b731ba0ce0be2336.png)

我们可以看到已经利用数据做出了一个柱饼图了，下面就再美化以下，得到最终结果

![2020030312](https://eelve.com/upload/2020/3/2020030312-452f0ac1954844cab0ea2955bd43dfa2.png)

另外我们还可以保存分享

![2020030313](https://eelve.com/upload/2020/3/2020030313-425f770de5064b06b8951748d6a0d01b.png)

然后我们还可以使用一下Kibana的开发工具，给**eelve**新加一条数据

![2020030314](https://eelve.com/upload/2020/3/2020030314-1689d96967794fc38f042ea3807dfc1d.png)
![2020030315](https://eelve.com/upload/2020/3/2020030315-68061267b1ac4b13a7844b873aa06c6b.png)

然后再刷新图表，可以看到数据会产生相应的变化

![2020030316](https://eelve.com/upload/2020/3/2020030316-bb66b6f0ba19419abc0ea3b674703f1b.png)

也就是说如果数据是实时变化的话，这边的图表也会跟着变化。

# 伍、Kibana特性


- 强大的定制功能：根据业务通过Kibana中的Canvas，发挥无限创意自由定制

    - 日志分析
    
    ![screenshot-canvas-log-analysis](https://eelve.com/upload/2020/3/screenshot-canvas-log-analysis-e24abcc3311841c886dbc36c8ca8dc05.png)
    
    - 基础设施监测
    
    ![screenshot-canvas-infrastructure](https://eelve.com/upload/2020/3/screenshot-canvas-infrastructure-706070724cb94eabbe6c37f1c82ce66d.png)
    
    - APM
    
    ![screenshot-canvas-apm](https://eelve.com/upload/2020/3/screenshot-canvas-apm-d007b95db41646a8832f1b1e35734c14.png)
    
    - 安全运营
    
    ![screenshot-canvas-security-operations](https://eelve.com/upload/2020/3/screenshot-canvas-security-operations-dd4a909ca4164efa93a30fc9e4c7b7e3.png)
    
    - 业务分析
    
    ![screenshot-canvas-business-analytics](https://eelve.com/upload/2020/3/screenshot-canvas-business-analytics-76b7f80430664be09ca4a2798ffb7faa.png)
    
    
- 把制作好的图表分享，让每个人都感受到 Kibana 的便利：只需选择适合您的分享选项，即可轻松地把 Kibana 可视化分享给您选择的任何人：您的团队成员、您的老板、老板的老板、您的客户、合规经理或承包商。嵌入仪表板，分享链接，或者导出为 PDF、PNG 或 CSV 文件并作为附件发送给别人。

![reporting_no_zoom-optimized](https://eelve.com/upload/2020/3/reporting_no_zoom-optimized-1144e12a2f5e4e308fb9aee150ea7629.gif)

- 良好的控制访问权限：通过 Kibana Spaces 整理您的仪表板和可视化。通过基于角色的访问控制，邀请用户访问某些空间（但不允许访问其他空间），让他们能够查看特定内容并使用特定功能。

![security-login.gif](https://i.loli.net/2020/03/03/SlqFLG8AMNZiQXp.gif)

- 管理：用于数据采集等操作的堆栈管理，有了 Kibana，命令行不再是管理安全设置、监测堆栈、采集和汇总数据或配置其他 Elastic Stack 功能的唯一途径。与此同时，得益于我们出色的 API，用户可以通过可视化 UI 轻松地管理 Elastic Stack 并确保其安全性，这种方式更加直观，也能让更多的人上手使用。

    - 添加数据
    
    ![kibana-homepage](https://eelve.com/upload/2020/3/kibana-homepage-ca50d6a5d73b4e5e981724528a492eca.jpg)
     
    - 确保访问的安全性
    
    ![kibana-management-security](https://eelve.com/upload/2020/3/kibana-management-security-2be33e4e888845ea87d6537b2eeaeb7f.jpg)

    - 管理管道
    
    ![kibana-management-logstash](https://eelve.com/upload/2020/3/kibana-management-logstash-f9dbc5faf2ed484f9643ead95ef57e02.jpg)

    - 汇总
    
    ![screenshot-rollups-management-ui](https://eelve.com/upload/2020/3/screenshot-rollups-management-ui-ec0be7dea0374a21a95bd18a048c094f.jpg)

    - 开发工具
    
    ![5.5-console-80pct-generic-rgb](https://eelve.com/upload/2020/3/5.5-console-80pct-generic-rgb-360a6e4bbf484353b27151e27de93b2e.jpg)
 
- 可直接应用于用例

有时您只想对某个文件进行 tail 操作。您可能希望跟踪自己网站的运行状态。或者您可能希望查看分布式痕迹。通过 Kibana 内置应用，例如 Logs、Infrastructure、APM、Uptime 以及其他应用，无需离开 Kibana，便能轻松完成这一切。    

![image4-2](https://eelve.com/upload/2020/3/image4-2-d9d1a61d020f4af7b934c3e6fa424208.png)

---

【**后面的话**】利用Kibana我们可以做出炫酷的符合业务且满足客户可视化展示。并且Kibana本身都提供相当多数量的各种图标模板，通过各种图标的组合可以轻松的开发一个属于我们自己的大屏。另外我们需要注意的是，我们应该根据我们的数据的特点选择合适的图表进行展示，这样可以是我们的图表显得更美观。今天只是体验了Kibana的部分功能，后续的其他功能，将配合Beats进行体验。

---

![薏米笔记](https://eelve.com/upload/2019/8/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
