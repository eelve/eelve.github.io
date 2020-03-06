---
title: hadoop安装解决之道
date: 2019-08-09 17:12:58
tags: hadoop
categories: hadoop
---
# 壹、故障现象
```shell script
Microsoft Windows [版本 10.0.18362.239]
(c) 2019 Microsoft Corporation。保留所有权利。

C:\Users\Chirius>hadoop version
系统找不到指定的路径。
Error: JAVA_HOME is incorrectly set.
       Please update C:\dhc_hlk\hadoop-2.8.5\etc\hadoop\hadoop-env.cmd
'-Xmx512m' 不是内部或外部命令，也不是可运行的程序
或批处理文件。
 
C:\Users\Chirius>

```

# 贰、尝试解决
首先，本人遇见上述错的先决条件是：在安装jdk时，使用的是jdk的默认安装路径 C:\Program Files\Java\jdk1.xxxx ，然后在Windows电脑上解压安装本地hadoop，正确配置hadoop的系统环境变量$HADOOP_HOME及$HADOOP_HOME/etc/hadoop/hadoop-env.cmd文件的java安装路径前提下，报了上图中的这个错

报错分析：

在Windows中安装jdk时，如果是安装在C:\Program Files\Java\jdk1.8.0_161路径下，如果需要在其他组件中配置java的环境时，因为C:\Program Files是Windows系统的系统盘，可能在某些场合下访问的时候，必须以Windows管理员的身份去访问，例如：我们在Windows中解压安装了hadoop，那么需要在$HADOOP_HOME/etc/hadoop/hadoop-env.cmd文件中手动修改java的安装路径，即：set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_161

![hadop01](https://eelve.com/upload/2019/7/hadop01-636e38ae52254d1aacef36d96b72de8c.png)

而我们的jdk安装在jdk的默认安装路径下，所以该文件路径有可能需要管理员访问权限才可以访问，所以如果像上图中这样配置会导致hadoop安装失败，失败的原因则是未检测到jdk环境，才会报**Error: JAVA_HOME is incorrectly set.**

# 叁、解决方法
将$HADOOP_HOME/etc/hadoop/hadoop-env.cmd文件中的 set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_161 修改为 set JAVA_HOME=C:\PROGRA~1\Java\jdk1.8.0_161 保存，然后重新在cmd窗口输入 hadoop version 命令，即可成功！
![hadoop02](https://eelve.com/upload/2019/7/hadoop02-67b5b5e127a046e69b18eab65b062949.png)

注意：在$HADOOP_HOME/etc/hadoop/hadoop-env.cmd文件中的这一行 set JAVA_HOME=C:\PROGRA~1\Java\jdk1.8.0_161 中不能有空格！

```shell script
Microsoft Windows [版本 10.0.18362.239]
(c) 2019 Microsoft Corporation。保留所有权利。

C:\Users\Chirius>hadoop version
Hadoop 2.7.3
Subversion https://git-wip-us.apache.org/repos/asf/hadoop.git -r baa91f7c6bc9cb92be5982de4719c1c8af91ccff
Compiled by root on 2016-08-18T01:41Z
Compiled with protoc 2.5.0
From source with checksum 2e4ce5f957ea4db193bce3734ff29ff4
This command was run using /D:/Seven/ways/hadoop-2.7.3/share/hadoop/common/hadoop-common-2.7.3.jar

C:\Users\Chirius>
```

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
