---
title: Hyper-V和IDEA运行端口占用问题
tags:
  - yper-V
  - IDEA
categories: Hyper-V
description: >-
  因为安装Windows版本的Docker环境，开启了Hyper-V。其结果是导致了IDEA在运行Tomcat的时候提示1099端口占用，经过探索之后成功找到了解决方案。
abbrlink: ba44fc9d
date: 2020-04-11 12:56:30
---

【**前面的话**】因为安装Windows版本的Docker环境，开启了Hyper-V。其结果是导致了IDEA在运行Tomcat的时候提示1099端口占用，经过探索之后成功找到了解决方案。

# 壹、原因分析

首先我们可以查看一下我们系统默认的端口占用范围；

>netsh int ipv4 show dynamicport tcp

```bash
Microsoft Windows [版本 10.0.18363.752]
(c) 2019 Microsoft Corporation。保留所有权利。

C:\Users\Chirius>netsh int ipv4 show dynamicport tcp

协议 tcp 动态端口范围
---------------------------------
启动端口        : 1024
端口数          : 13977
```
我们可以看到Windows系统默认的tcp 动态端口范围为：1024~13977。当我们开启Hyper-V后，系统默认会分配给一些保留端口供Hyper-V使用：

>netsh interface ipv4 show excludedportrange protocol=tcp

```bash
C:\Users\Chirius>netsh interface ipv4 show excludedportrange protocol=tcp
协议 tcp 端口排除范围
 
开始端口    结束端口
----------    --------
      1026        1125
      1226        1325
      1326        1425
      1426        1525
      1526        1625
      2180        2279
```
我们可以看到IDEA运行Tomcat需要JMX的**1099**端口刚好在端口排除范围中，这样就导致了IDEA需要使用1099端口是会被占用，这样你当然就不能运行了。


# 贰、解决方法

使用管理员身份运行cmd，重置端口，然后重启

```bash
C:\Users\Chirius>netsh winsock reset
```

这样你的tcp端口排除范围可能刚好不包含**1099**端口，这样你当然就可以用你的IDEA运行Tomcat应用了。但是你啥时候会出现就不得而知了。

# 叁、终极解决

## 3.1 关闭Hyper-V

```bash
Microsoft Windows [版本 10.0.18363.752]
(c) 2019 Microsoft Corporation。保留所有权利。

C:\WINDOWS\system32>dism.exe /Online /Disable-Feature:Microsoft-Hyper-V
```

或者采用传统方式，在控制面板的“程序和功能”中，找到“Windows功能”，取消Hyper-V的勾选。这两种方法都会要求重启。

## 3.2 修改动态端口范围

使用管理员身份运行cmd

```bash
C:\WINDOWS\system32>netsh int ipv4 set dynamicport tcp start=49152 num=16383
确定。


C:\WINDOWS\system32>netsh int ipv4 set dynamicport udp start=49152 num=16383
确定。
```

然后检查结果

```bash
C:\Users\Chirius>netsh int ipv4 show dynamicport tcp

协议 tcp 动态端口范围
---------------------------------
启动端口        : 49152
端口数          : 16383
```

```bash
Microsoft Windows [版本 10.0.18363.752]
(c) 2019 Microsoft Corporation。保留所有权利。

C:\Users\Chirius>netsh interface ipv4 show excludedportrange protocol=tcp

协议 tcp 端口排除范围

开始端口    结束端口
----------    --------
      5357        5357
     49702       49801
     49802       49901
     49902       50001
     50051       50051     *
     50052       50151
     50152       50251
     50252       50351
     50352       50451
     50465       50564
     50911       51010

* - 管理的端口排除。


C:\Users\Chirius>
```

## 3.3 开启Hyper-V

```bash
C:\WINDOWS\system32>dism.exe /Online /Enable-Feature:Microsoft-Hyper-V /All

部署映像服务和管理工具
版本: 10.0.18362.1

映像版本: 10.0.18363.752

启用一个或多个功能
[==========================100.0%==========================]
操作成功完成。
重新启动 Windows 以完成该操作。
是否立即重新启动计算机? (Y/N)

```

![开启Hyper-V](https://image.eelve.com/eblog/2020041101-3b9aed15aec84b7e9a0bd3d122c54170.png)

或者采用传统方式，在控制面板的“程序和功能”中，找到“Windows功能”，取消Hyper-V的勾选。这两种方法都会要求重启。

【**后面的话**】使用终极解决方案解决之后，你会发现你的IDEA又可以正常运行了。另外这里说一个单独排除端口的命令，后面可能会用到：

```bash
netsh int ipv4 add excludedportrange protocol=tcp startport=50051 numberofports=1
```

使用上面的命令之后我们就可以单独排除某个端口了，保障改端口不会被其他应用占用。

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
