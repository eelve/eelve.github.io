---
title: WSL2初体验
date: 2020-07-19 20:33:01
tags: WSL，Windows
categories: WSL
---



【**前面的话**】前面已经对[WSL初体验](https://eelve.com/archives/hellowsl) ，今天就将升级为WSL2，并且【**前面的话**】前面已经对[WSL初体验](https://eelve.com/archives/hellowsl) ，今天就将升级为WSL2，并且在WSL2使用xrdp实现图形桌面。

---

# 壹、WSL升级为WSL2

```bash
wsl --set-version Ubuntu-18.04 2
```

其中`Ubuntu-18.04`为你安装的WSL的发行版本，可以通过` wsl -l -v`来查看安装的WSL的发行版本详细信息。

另外我在升级的过程中遇到了`WSL 2 需要更新其内核组件`问题。解决方法也很简单，[从微软下载WSL2 Linux内核的升级包](https://docs.microsoft.com/zh-cn/windows/wsl/wsl2-kernel), 下载完成之后直接一路安装即可，之后WSL2就可以成功升级了。

最后如果想要将默认的WSL发行版设置成WSL2，可以使用下面命令

```bash
wsl --set-default-version 2
```

# 贰、安装图形化桌面

## 2.1 安装

先更新,再安装`xfce4`和`xrdp`

```bash
$ sudo apt update
$ sudo apt install -y xfce4 xrdp
```

## 2.2 修改xrdp默认端口

由于`xrdp`安装好后默认配置使用的是和Windows远程桌面相同的`3389` 端口,为了防止和Windows系统远程桌面冲突,建议修改成其他的端口

```bash
$ sudo vim /etc/xrdp/xrdp.ini
# 修改下面这一行,将默认的3389改成其他端口即可
port=13389
```

## 2.3 为当前用户指定登录session类型

    注意这一步很重要,如果不设置的话会导致后面远程桌面连接上闪退
    
```bash
$ vim ~/.xsession

# 写入下面内容(就一行)
xfce4-session
```    

## 2.4 启动xrdp

由于WSL2里面不能用`systemd`,所以需要手动启动

```bash
$ sudo /etc/init.d/xrdp start
```

# 叁、远程访问

在Windows系统中运行mstsc命令打开远程桌面连接,地址输入localhost:13389

    注意这里的端口号应当与上面修改配置中一致

![2020071901](https://image.eelve.com/eblog/2020071901-6f2b76d2c58f4213950f820ef05f85d8.png)
![2020071902](https://image.eelve.com/eblog/2020071902-c42b474dc5374bda9f576619a491b1ed.png)

输入linux系统的用户名和密码，就可以登陆成功了

![2020071903](https://image.eelve.com/eblog/2020071903-b7632286a2c648bdac1d0a92585612a3.png)
    



【**后面的话**】如果在日常使用中遇到WSL异常，一般为网络端口占用问题导致，一般可以通过重置网络修复，使用管理员身份运行cmd，重置端口，然后重启：`netsh winsock reset`。

```bash
C:\Users\Chirius>netsh winsock reset
```

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
