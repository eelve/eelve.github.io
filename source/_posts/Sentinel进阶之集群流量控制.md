---
title: Sentinel进阶之集群流量控制
tags: sentinel
categories: sentinel
description: 在前面几篇文章中简单介绍了一下Sentinel的功能都是针对单机的，今天就来继续说一下Sentinel的集群流量控制。
abbrlink: 318cbe59
date: 2021-07-10 09:04:09
---

【**前面的话**】在前面几篇文章中简单介绍了一下`Sentinel`的功能都是针对单机的，今天就来继续说一下Sentinel的集群流量控制。

---

# 壹、集群流控介绍

## 1.1、介绍

为什么要使用集群流控呢？假设我们希望给某个用户限制调用某个 API 的总 QPS 为 50，但机器数可能很多（比如有 100 台）。这时候我们很自然地就想到，找一个 server 来专门来统计总的调用量，其它的实例都与这台 server 通信来判断是否可以调用。这就是最基础的集群流控的方式。

另外集群流控还可以解决流量不均匀导致总体限流效果不佳的问题。假设集群中有 10 台机器，我们给每台机器设置单机限流阈值为 10 QPS，理想情况下整个集群的限流阈值就为 100 QPS。不过实际情况下流量到每台机器可能会不均匀，会导致总量没有到的情况下某些机器就开始限流。因此仅靠单机维度去限制的话会无法精确地限制总体流量。而集群流控可以精确地控制整个集群的调用总量，结合单机限流兜底，可以更好地发挥流量控制的效果。

集群流控中共有两种身份：

- Token Client：集群流控客户端，用于向所属 Token Server 通信请求 token。集群限流服务端会返回给客户端结果，决定是否限流。
- Token Server：即集群流控服务端，处理来自 Token Client 的请求，根据配置的集群规则判断是否应该发放 token（是否允许通过）。

![结构示意图](https://image.eelve.com/eblog/2021071001.png)

## 1.2、模块结构

Sentinel 1.4.0 开始引入了集群流控模块，主要包含以下几部分：

- `sentinel-cluster-common-default`: 公共模块，包含公共接口和实体
- `sentinel-cluster-client-default`: 默认集群流控 client 模块，使用 Netty 进行通信，提供接口方便序列化协议扩展
- `sentinel-cluster-server-default`: 默认集群流控 server 模块，使用 Netty 进行通信，提供接口方便序列化协议扩展；同时提供扩展接口对接规则判断的具体实现（TokenService），默认实现是复用 sentinel-core 的相关逻辑

> 注意：集群流控模块要求 JDK 版本最低为 1.7。

# 贰、集群流控规则

`FlowRule`添加了两个字段用于集群限流相关配置：

```java
private boolean clusterMode; // 标识是否为集群限流配置
private ClusterFlowConfig clusterConfig; // 集群限流相关配置项
```

其中用一个专门的 `ClusterFlowConfig` 代表集群限流相关配置项，以与现有规则配置项分开：

```java
// 全局唯一的规则 ID，由集群限流管控端分配.
private Long flowId;

// 阈值模式，默认（0）为单机均摊，1 为全局阈值.
private int thresholdType = ClusterRuleConstant.FLOW_THRESHOLD_AVG_LOCAL;

private int strategy = ClusterRuleConstant.FLOW_CLUSTER_STRATEGY_NORMAL;

// 在 client 连接失败或通信失败时，是否退化到本地的限流模式
private boolean fallbackToLocalWhenFail = true;
```

- `flowId` 代表全局唯一的规则 `ID`，`Sentinel` 集群限流服务端通过此 `ID` 来区分各个规则，因此务必保持全局唯一。一般 `flowId` 由统一的管控端进行分配，或写入至 `DB` 时生成。
- `thresholdType` 代表集群限流阈值模式。其中单机均摊模式下配置的阈值等同于单机能够承受的限额，`token server` 会根据客户端对应的 `namespace`（默认为 `project.name` 定义的应用名）下的连接数来计算总的阈值（比如独立模式下有 3 个 client 连接到了 token server，然后配的单机均摊阈值为 10，则计算出的集群总量就为 30）；而全局模式下配置的阈值等同于整个集群的总阈值。

`ParamFlowRule` 热点参数限流相关的集群配置与 `FlowRule` 相似。

# 叁、集群流控配置

## 3.1、配置方式

> 在集群流控的场景下，推荐使用动态规则源来动态地管理规则。

对于客户端，按照原有的方式来向 FlowRuleManager 和 ParamFlowRuleManager 注册动态规则源，例如：

```java
ReadableDataSource<String, List<FlowRule>> flowRuleDataSource = new NacosDataSource<>(remoteAddress, groupId, dataId, parser);
FlowRuleManager.register2Property(flowRuleDataSource.getProperty());
```

对于集群流控 `token server`，由于集群限流服务端有作用域（namespace）的概念，因此我们需要注册一个自动根据 `namespace` 生成动态规则源的 `PropertySupplier`:

```java
// Supplier 类型：接受 namespace，返回生成的动态规则源，类型为 SentinelProperty<List<FlowRule>>
// ClusterFlowRuleManager 针对集群限流规则，ClusterParamFlowRuleManager 针对集群热点规则，配置方式类似
ClusterFlowRuleManager.setPropertySupplier(namespace -> {
    return new SomeDataSource(namespace).getProperty();
});
```

然后每当集群限流服务端 `namespace set` 产生变更时，`Sentinel` 会自动针对新加入的 `namespace` 生成动态规则源并进行自动监听，并删除旧的不需要的规则源。

## 3.2、集群限流服务端

要想使用集群限流服务端，必须引入集群限流 server 相关依赖：

```java
<dependency>
    <groupId>com.alibaba.csp</groupId>
    <artifactId>sentinel-cluster-server-default</artifactId>
    <version>1.7.1</version>
</dependency>
```

## 3.3、启动方式

`Sentinel` 集群限流服务端有两种启动方式：

- 独立模式（Alone），即作为独立的 `token server` 进程启动，独立部署，隔离性好，但是需要额外的部署操作。独立模式适合作为 `Global Rate Limiter` 给集群提供流控服务。

![独立模式](https://image.eelve.com/eblog/2021071002.png)

- 嵌入模式（Embedded），即作为内置的 `token server` 与服务在同一进程中启动。在此模式下，集群中各个实例都是对等的，`token server` 和 `client` 可以随时进行转变，因此无需单独部署，灵活性比较好。但是隔离性不佳，需要限制 `token server` 的总 `QPS`，防止影响应用本身。嵌入模式适合某个应用集群内部的流控。

![嵌入模式](https://image.eelve.com/eblog/2021071003.png)

我们可以使用 `API` 将在 `embedded` 模式下转换集群流控身份：

```
http://<ip>:<port>/setClusterMode?mode=<xxx>
```

其中 `mode` 为 `0` 代表 `client`，`1` 代表 `server`，`-1` 代表关闭。注意应用端需要引入集群限流客户端或服务端的相应依赖。

在独立模式下，我们可以直接创建对应的 `ClusterTokenServer` 实例并在 `main` 函数中通过 `start` 方法启动 `Token Server`。

## 3.4、属性配置

集群限流服务端注册动态配置源来动态地进行配置。配置类型有以下几种：

- `namespace set`: 集群限流服务端服务的作用域（命名空间），可以设置为自己服务的应用名。集群限流 `client` 在连接到 `token server` 后会上报自己的命名空间（默认为 `project.name` 配置的应用名），`token server` 会根据上报的命名空间名称统计连接数。
- `transport config`: 集群限流服务端通信相关配置，如 `server port`
- `flow config`: 集群限流服务端限流相关配置，如滑动窗口统计时长、格子数目、最大允许总 QPS等

我们可以通过 `ClusterServerConfigManager` 的各个 `registerXxxProperty` 方法来注册相关的配置源。

从 `1.4.1` 版本开始，`Sentinel` 支持给 `token server` 配置最大允许的总 `QPS（maxAllowedQps）`，来对 `token server` 的资源使用进行限制，防止在嵌入模式下影响应用本身。

下图是Token Server 分配配置的示意图：

![Token Server分配配置](https://image.eelve.com/eblog/2021071004.png)


# 肆、扩展接口

![整体扩展架构](https://image.eelve.com/eblog/2021071005.png)

## 4.1、通用扩展接口

以下通用接口位于 `sentinel-core` 中：

- TokenService: 集群限流功能接口，server / client 均可复用 
- ClusterTokenClient: 集群限流功能客户端
- ClusterTokenServer: 集群限流服务端接口
- EmbeddedClusterTokenServer: 集群限流服务端接口（embedded 模式）

以下通用接口位于 `sentinel-cluster-common-default`:

- EntityWriter
- EntityDecoder

## 4.2、Client 扩展接口

集群流控 `Client` 端通信相关扩展接口：

- ClusterTransportClient：集群限流通信客户端
- RequestEntityWriter
- ResponseEntityDecoder

## 4.3、Server 扩展接口

集群流控 `Server` 端通信相关扩展接口：

- ResponseEntityWriter
- RequestEntityDecoder

集群流控 `Server` 端请求处理扩展接口：

- RequestProcessor: 请求处理接口 (request -> response)


---

【**后面的话**】[最后是我自己实践的源码](https://github.com/eelve/awesomesentinel) ,包括流量控制和初始规则加载等等。

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)

