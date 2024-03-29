---
title: Sentinel进阶之基本原理
tags: sentinel
categories: sentinel
description: 在前文Sentinel入门指北中简单介绍了一下Sentinel，今天就来具体说一下Sentinel的基本原理。
abbrlink: 950c5430
date: 2021-05-30 13:01:11
---

【**前面的话**】在前文 [Sentinel入门指北](https://eelve.com/posts/d2ca763d.html) 中简单介绍了一下`Sentinel`，今天就来具体说一下`Sentinel`的基本原理。

---

# 壹、概述

在 `Sentinel` 里面，所有的资源都对应一个资源名称以及一个 `Entry`。`Entry` 可以通过对主流框架的适配自动创建，也可以通过注解的方式或调用 `API` 显式创建；每一个 `Entry` 创建的时候，同时也会创建一系列功能插槽（slot chain）。这些插槽有不同的职责，例如:

- `NodeSelectorSlot` 负责收集资源的路径，并将这些资源的调用路径，以树状结构存储起来，用于根据调用路径来限流降级； 
- `ClusterBuilderSlot` 则用于存储资源的统计信息以及调用者信息，例如该资源的 `RT`, `QPS`, `thread count` 等等，这些信息将用作为多维度限流，降级的依据；
- `StatisticSlot` 则用于记录、统计不同纬度的 `runtime` 指标监控信息；
- `FlowSlot` 则用于根据预设的限流规则以及前面 `slot` 统计的状态，来进行流量控制；
- `AuthoritySlot` 则根据配置的黑白名单和调用来源信息，来做黑白名单控制；
- `DegradeSlot` 则通过统计信息以及预设的规则，来做熔断降级；
- `SystemSlot` 则通过系统的状态，例如 `load1` 等，来控制总的入口流量；

总体的框架如下:

![总体框架图](https://image.eelve.com/eblog/2021053001.png)

`Sentinel` 将 `ProcessorSlot` 作为 `SPI` 接口进行扩展（1.7.2 版本以前 `SlotChainBuilder` 作为 `SPI`），使得 `Slot Chain` 具备了扩展的能力。您可以自行加入自定义的 `slot` 并编排 `slot` 间的顺序，从而可以给 `Sentinel` 添加自定义的功能。

![自定义处理流程](https://image.eelve.com/eblog/2021053002.png)

下面介绍一下各个 `slot` 的功能。

## 1.1、NodeSelectorSlot

这个 `slot` 主要负责收集资源的路径，并将这些资源的调用路径，以树状结构存储起来，用于根据调用路径来限流降级。

```java
 ContextUtil.enter("entrance1", "appA");
 Entry nodeA = SphU.entry("nodeA");
 if (nodeA != null) {
    nodeA.exit();
 }
 ContextUtil.exit();
```

上述代码通过 `ContextUtil.enter()` 创建了一个名为 `entrance1` 的上下文，同时指定调用发起者为 `appA`；接着通过 `SphU.entry()`请求一个 `token`，如果该方法顺利执行没有抛 `BlockException`，表明 `token` 请求成功。

以上代码将在内存中生成以下结构：

~~~
 	     machine-root
                 /     
                /
         EntranceNode1
              /
             /   
      DefaultNode(nodeA)
~~~

> 注意：每个 `DefaultNode` 由资源 `ID` 和输入名称来标识。换句话说，一个资源 `ID` 可以有多个不同入口的 `DefaultNode`。

```java
  ContextUtil.enter("entrance1", "appA");
  Entry nodeA = SphU.entry("nodeA");
  if (nodeA != null) {
    nodeA.exit();
  }
  ContextUtil.exit();

  ContextUtil.enter("entrance2", "appA");
  nodeA = SphU.entry("nodeA");
  if (nodeA != null) {
    nodeA.exit();
  }
  ContextUtil.exit();
```

以上代码将在内存中生成以下结构：

```
                   machine-root
                   /         \
                  /           \
          EntranceNode1   EntranceNode2
                /               \
               /                 \
       DefaultNode(nodeA)   DefaultNode(nodeA)
```

上面的结构可以通过调用 `curl http://localhost:8719/tree?type=root` 来显示：

```
EntranceNode: machine-root(t:0 pq:1 bq:0 tq:1 rt:0 prq:1 1mp:0 1mb:0 1mt:0)
-EntranceNode1: Entrance1(t:0 pq:1 bq:0 tq:1 rt:0 prq:1 1mp:0 1mb:0 1mt:0)
--nodeA(t:0 pq:1 bq:0 tq:1 rt:0 prq:1 1mp:0 1mb:0 1mt:0)
-EntranceNode2: Entrance1(t:0 pq:1 bq:0 tq:1 rt:0 prq:1 1mp:0 1mb:0 1mt:0)
--nodeA(t:0 pq:1 bq:0 tq:1 rt:0 prq:1 1mp:0 1mb:0 1mt:0)

t:threadNum  pq:passQps  bq:blockedQps  tq:totalQps  rt:averageRt  prq: passRequestQps 1mp:1m-passed 1mb:1m-blocked 1mt:1m-total
```

## 1.2、ClusterBuilderSlot

此插槽用于构建资源的 `ClusterNode` 以及调用来源节点。`ClusterNode` 保持资源运行统计信息（响应时间、QPS、block 数目、线程数、异常数等）以及原始调用者统计信息列表。来源调用者的名字由 `ContextUtil.enter(contextName，origin)` 中的 `origin` 标记。可通过如下命令查看某个资源不同调用者的访问情况：`curl http://localhost:8719/origin?id=caller`：

```
id: nodeA
idx origin  threadNum passedQps blockedQps totalQps aRt   1m-passed 1m-blocked 1m-total 
1   caller1 0         0         0          0        0     0         0          0        
2   caller2 0         0         0          0        0     0         0          0      
```

## 1.3、StatisticSlot

`StatisticSlot` 是 `Sentinel` 的核心功能插槽之一，用于统计实时的调用数据。

- `clusterNode`：资源唯一标识的 `ClusterNode` 的 `runtime` 统计 
- `origin`：根据来自不同调用者的统计信息
- `defaultnode`: 根据上下文条目名称和资源 `ID` 的 `runtime` 统计
- 入口的统计

`Sentinel` 底层采用高性能的滑动窗口数据结构 `LeapArray` 来统计实时的秒级指标数据，可以很好地支撑写多于读的高并发场景。

![滑动窗口](https://image.eelve.com/eblog/2021053003.png)

## 1.4、FlowSlot

这个 `slot` 主要根据预设的资源的统计信息，按照固定的次序，依次生效。如果一个资源对应两条或者多条流控规则，则会根据如下次序依次检验，直到全部通过或者有一个规则生效为止:

- 指定应用生效的规则，即针对调用方限流的；
- 调用方为 other 的规则；
- 调用方为 default 的规则。

## 1.5、DegradeSlot

这个 `slot` 主要针对资源的平均响应时间（RT）以及异常比率，来决定资源是否在接下来的时间被自动熔断掉。

## 1.6、SystemSlot

这个 `slot` 会根据对于当前系统的整体情况，对入口资源的调用进行动态调配。其原理是让入口的流量和当前系统的预计容量达到一个动态平衡。

注意系统规则只对入口流量起作用（调用类型为 `EntryType.IN`），对出口流量无效。可通过 `SphU.entry(res, entryType)` 指定调用类型，如果不指定，默认是`EntryType.OUT`。

# 贰、 核心类解析

## 2.1、ProcessorSlotChain

`Sentinel` 的核心骨架，将不同的 `Slot` 按照顺序串在一起（责任链模式），从而将不同的功能（限流、降级、系统保护）组合在一起。`slot chain` 其实可以分为两部分：统计数据构建部分（statistic）和判断部分（rule checking）。核心结构：

![总体框架图](https://image.eelve.com/eblog/2021053001.png)

目前的设计是 `one slot chain per resource`，因为某些 `slot` 是 `per resource` 的（比如 `NodeSelectorSlot`）。

## 2.2、Context

`Context` 代表调用链路上下文，贯穿一次调用链路中的所有 `Entry`。`Context` 维持着入口节点（entranceNode）、本次调用链路的 `curNode`、调用来源（origin）等信息。`Context` 名称即为调用链路入口名称。

`Context` 维持的方式：通过 `ThreadLocal` 传递，只有在入口 `enter` 的时候生效。由于 `Context` 是通过 `ThreadLocal` 传递的，因此对于异步调用链路，线程切换的时候会丢掉 `Context`，因此需要手动通过 `ContextUtil.runOnContext(context, f)` 来变换 `context`。

## 2.3、Entry

每一次资源调用都会创建一个 `Entry`。`Entry` 包含了资源名、curNode（当前统计节点）、originNode（来源统计节点）等信息。

`CtEntry` 为普通的 `Entry`，在调用 `SphU.entry(xxx)` 的时候创建。特性：`Linked entry within current context（内部维护着 parent 和 child）`

需要注意的一点：`CtEntry` 构造函数中会做调用链的变换，即将当前 `Entry` 接到传入 `Context` 的调用链路上（setUpEntryFor）。

资源调用结束时需要 `entry.exit()`。`exit` 操作会过一遍 `slot chain exit`，恢复调用栈，`exit context` 然后清空 `entry` 中的 `context` 防止重复调用。

## 2.4、Node

`Sentinel` 里面的各种种类的统计节点：

- `StatisticNode`：最为基础的统计节点，包含秒级和分钟级两个滑动窗口结构。
- `DefaultNode`：链路节点，用于统计调用链路上某个资源的数据，维持树状结构。
- `ClusterNode`：簇点，用于统计每个资源全局的数据（不区分调用链路），以及存放该资源的按来源区分的调用数据（类型为 `StatisticNode`）。特别地，`Constants.ENTRY_NODE` 节点用于统计全局的入口资源数据。
- `EntranceNode`：入口节点，特殊的链路节点，对应某个 `Context` 入口的所有调用数据。`Constants.ROOT` 节点也是入口节点。

构建的时机：

- `EntranceNode`：在 `ContextUtil.enter(xxx)` 的时候就创建了，然后塞到 `Context` 里面。
- `NodeSelectorSlot`：根据 `context` 创建 `DefaultNode`，然后 `set curNode to context`。
- `ClusterBuilderSlot`：首先根据 `resourceName` 创建 `ClusterNode`，并且 `set clusterNode to defaultNode`；然后再根据 `origin` 创建来源节点（类型为 `StatisticNode`），并且 `set originNode to curEntry`。

几种 `Node` 的维度（数目）：

- `ClusterNode` 的维度是 `resource`
- `DefaultNode` 的维度是 `resource * context`，存在每个 `NodeSelectorSlot` 的 `map` 里面
- `EntranceNode` 的维度是 `context`，存在 `ContextUtil` 类的 `contextNameNodeMap` 里面
- 来源节点（类型为 `StatisticNode`）的维度是 `resource * origin`，存在每个 `ClusterNode` 的 `originCountMap` 里面

## 2.5、StatisticSlot

`StatisticSlot` 是 `Sentinel` 最为重要的类之一，用于根据规则判断结果进行相应的统计操作。

`entry` 的时候：依次执行后面的判断 `slot`。每个 `slot` 触发流控的话会抛出异常（`BlockException` 的子类）。若有 BlockException 抛出，则记录 block 数据；若无异常抛出则算作可通过（pass），记录 pass 数据。

`exit` 的时候：若无 `error（无论是业务异常还是流控异常）`，记录 `complete（success）`以及 `RT`，线程数`-1`。

记录数据的维度：线程数`+1`、记录当前 `DefaultNode` 数据、记录对应的 `originNode` 数据（若存在 `origin`）、累计 `IN` 统计数据（若流量类型为 `IN`）。


---

【**后面的话**】[最后是我自己实践自定义调用链的源码](https://github.com/eelve/awesomesentinel) 。

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
