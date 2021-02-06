---
title: 安装yarn实况
date: 2019-08-09 17:12:12
tags: yarn
categories: node
description: 最近在gayhub上面得到一个开源项目，遂准备研究一下源码，当然第一步就是要把项目运行起来。然后看了一下技术栈，发现包管理工具是使用yarn，以前也听说过yarn但是也没有具体使用过，只知道是facebook发布的包管理程序。
---
【**前情提要**】最近在gayhub上面得到一个开源项目，遂准备研究一下源码，当然第一步就是要把项目运行起来。然后看了一下技术栈，发现包管理工具是使用yarn，以前也听说过yarn但是也没有具体使用过，只知道是facebook发布的包管理程序。

# 壹、安装

1.下载node.js，使用npm安装 
```shell script
npm install -g yarn 
查看版本：yarn --version
```

2.安装node.js,下载yarn的安装程序: 

[ 提供一个.msi文件，在运行时将引导您在Windows上安装Yarn](https://yarnpkg.com/en/docs/install#windows-stable)

3.Yarn 淘宝源安装，分别复制粘贴以下代码行到黑窗口运行即可 
```shell script
yarn config set registry https://registry.npm.taobao.org -g 
yarn config set sass_binary_site http://cdn.npm.taobao.org/dist/node-sass -g

```
# 贰、踩坑时刻
1.yarn使用时候报错信息：
```shell script
    Error: Could not create the Java Virtual Machine.
    Error: A fatal exception has occurred. Program will exit.
```
2.检测yarn版本 yarn version
```shell script
D:\Seven\ways\hadoop-2.7.3>yarn version  ok
Hadoop 2.7.3
Subversion https://git-wip-us.apache.org/repos/asf/hadoop.git -r b3fe56402d908019d99af1f1f4fc65cb1d1436a2
Compiled by jdu on 2017-12-05T03:43Z
Compiled with protoc 2.5.0
From source with checksum 9ff4856d824e983fa510d3f843e3f19d
This command was run using /D:/Seven/ways/hadoop-2.7.3/share/hadoop/common/hadoop-common-2.7.3.jar
```
3.检测yarn版本 yarn --version 报错
```shell script
D:\Seven\ways\hadoop-2.7.3>yarn --version
Unrecognized option: --version
Error: Could not create the Java Virtual Machine.
Error: A fatal exception has occurred. Program will exit.
```
4.安装依赖包  报错
```shell script
D:\Seven\ways\hadoop-2.7.3>yarn install
错误: 找不到或无法加载主类 install
```
5.最后没办法重新下载windows安装包[ 提供一个.msi文件，在运行时将引导您在Windows上安装Yarn](https://yarnpkg.com/en/docs/install#windows-stable)

安装 -> 测试 -> 报错 -> 检测原因 -> 没有配置环境变量 -> 继续报错,检测原因 -> java安装环境中有默认的yarn -> 环境变量配置在它前面

6.测试
```shell script
Microsoft Windows [版本 10.0.18362.239]
(c) 2019 Microsoft Corporation。保留所有权利。

C:\Users\Chirius>yarn --version
1.17.3

C:\Users\Chirius>
```



---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
