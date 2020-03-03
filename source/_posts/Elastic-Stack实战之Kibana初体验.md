---
layout: elastic
title: Elastic Stack实战之Kibana初体验
date: 2020-03-03 19:49:22
tags: [ELK,Kibana,Beats]
categories: Elastic Stack
notshow: true
---

【**前面的话**】在前面已经安装好了Elasticsearch和Logstash，今天就来[Kibana](https://www.elastic.co/cn/kibana)进行一下初步体验。。


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

# 肆、Kibana简单使用


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

【**后面的话**】利用Kibana我们可以做出炫酷的符合业务且满足客户可视化展示。

---

![薏米笔记](https://eelve.com/upload/2019/8/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
