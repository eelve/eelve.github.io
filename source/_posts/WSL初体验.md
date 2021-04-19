---
title: WSL初体验
tags: WSL，Windows
categories: WSL
description: WSL是Windows Subsystem for Linux的缩写，今天就来体验一把。
abbrlink: f42ecfec
date: 2020-04-11 13:29:55
---

【**前面的话**】WSL是Windows Subsystem for Linux的缩写，今天就来体验一把。

---

# 壹、安装WSL

## 1.1 启用或关闭Windows功能

在搜索栏中搜索并打开“启用或关闭Windows功能”，勾选“适用于Linux的Windows子系统”项。只有开启这项设置才能正常安装WSL。然后按照提示稍后重启。

## 1.2 安装子系统

在微软应用商店搜索 Linux，可以看到一系列 Linux 发行版，根据自己需要选择适合自己的发行版，这里我选用 Ubuntu 18.04 LTS。等待下载完成后启动 Ubuntu 18.04 LTS，等待安装完成，输入账户和密码，我们便得到了一个 Linux 环境了。

![2020041102](https://image.eelve.com/eblog/2020041102-b3495d5d24fa4514b2e5293ded3cd61e.png)


# 贰、使用技巧

## 2.1使用其他命令行工具

为什么不推荐自带的命令行呢？因为不支撑复制，这样你就只用手敲各种命令了。这里我推荐Windows Terminal，然后在Windows Terminal中键入`WSL`,就可以进入命令行了或者直接选择`Ubuntu 18.04`。

![2020041104](https://image.eelve.com/eblog/2020041104-617b46212475414ba2a4fd754bb395a8.png)
![2020041103](https://image.eelve.com/eblog/2020041103-dd423936b8d348039cac18e3dd41db08.png)

## 2.2 更改源

Ubuntu 默认的 apt 源是国外的源，实在是太慢了，这里换成阿里云的源。

### 2.2.1 首先复制源文件备份，便于以后恢复

```shell script
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
```

### 2.2.2 查看版本信息

```shell script
cc@Chirius:/mnt/c/Users/Chirius$ lsb_release -c
Codename:       bionic
```

### 2.2.3 编辑源文件

```shell script
cc@Chirius:/mnt/c/Users/Chirius$ sudo vim /etc/apt/sources.list
```

### 2.2.4 根据 Ubuntu 版本号，添加相应内容：

```shell script
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse

deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse

deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse

deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse

deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse

deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse

deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
```

然后保存退出

### 2.2.5 升级系统

```shell script
cc@Chirius:/mnt/c/Users/Chirius$ sudo apt-get update
```

```shell script
cc@Chirius:/mnt/c/Users/Chirius$ sudo apt-get upgrade
```

# 叁、WSL 文件位置

如果想在 Linux 查看其他分区，WSL 将其它盘符挂载在 /mnt 下。

```shell script
cc@Chirius:/$ cd mnt
cc@Chirius:/mnt$ ls
c  d
cc@Chirius:/mnt$ pwd
/mnt
```

如果想在 Windows 下查看 WSL 文件位置，文件位置在：C:\Users\用户名\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu18.04onWindows_79rhkp1fndgsc\LocalState\rootfs 下。

我们还可以在资源管理器中键入`\\wsl$`

![2020041105](https://image.eelve.com/eblog/2020041105-c34cdd30c9b24c6e879114f45880091b.png)

然后我们还可以添加网络位置

![2020041106](https://image.eelve.com/eblog/2020041106-564ce889eb8843fe8687d63a2f81fece.png)


# 肆、添加root密码

由于默认进入子系统之后是你添加的用户，当你需要root权限是可以通过`sudo`加上相应的命令解决。那还有另外一种方法：设置一个root用户的密码，然后切换到root用户去执行相应的命令。下面就说一下在子系统中设置root用户密码：

首先需要Windows管理员身份运行`cmd`或者`PowerShell`，然后执行下面命令

```bash
Windows PowerShell
版权所有 (C) Microsoft Corporation。保留所有权利。

尝试新的跨平台 PowerShell https://aka.ms/pscore6

PS C:\Users\Chirius> wsl
cc@Chirius:/mnt/c/Users/Chirius$ sudo passwd root
[sudo] password for cc:
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully
cc@Chirius:/mnt/c/Users/Chirius$ su root
Password:
root@Chirius:/mnt/c/Users/Chirius#
```

我们可以看到就已经可以切换到root用户了。

【**后面的话**】在Windows2004版本中会发布WSL2，后面再来继续体验。

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
