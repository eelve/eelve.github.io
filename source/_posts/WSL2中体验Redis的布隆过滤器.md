---
title: WSL2中体验Redis的布隆过滤器
tags: WSL，Redis
categories: WSL
description: 前面已经安装了WSL2 ，最近准备研究一下Redis的布隆过滤器，现在就先搭建一下环境。
abbrlink: 95571c44
date: 2020-08-15 11:39:40
---



【**前面的话**】前面已经安装了[WSL2](https://eelve.com/posts/22fec071.html) ，最近准备研究一下Redis的布隆过滤器，现在就先搭建一下环境。

---

# 壹、准备环境

- WSL：WSL2
- Docker: Docker for Windows `Use the WSL 2 based engine`


# 贰、安装过程

## 2.1 前情资讯

`Redis v4.0`之后有了 `Module（模块/插件）`功能，`Redis Modules`让 `Redis` 可以使用外部模块扩展其功能 。布隆过滤器就是其中的`Module`。详情可以查看`Redis`官方对 `Redis Modules`的介绍 ：https://redis.io/modules

另外，官网推荐了一个`RedisBloom`作为`Redis`布隆过滤器的`Module`,地址：https://github.com/RedisBloom/RedisBloom. 其他还有：

- redis-lua-scaling-bloom-filter （lua 脚本实现）：https://github.com/erikdubbelboer/redis-lua-scaling-bloom-filter
- pyreBloom（Python中的快速Redis 布隆过滤器） ：https://github.com/seomoz/pyreBloom
- ......

`RedisBloom`提供了多种语言的客户端支持，包括：`Python`、`Java`、`JavaScript` 和 `PHP`。

## 2.2 Docker安装

如果我们需要体验`Redis`中的布隆过滤器非常简单，通过 Docker 就可以了！这里我们使用这个仓库下的镜像：https://hub.docker.com/r/redislabs/rebloom/

下面是具体命令：

```bash
cc@Chirius:/mnt/c/Users/Chirius$ docker run -p 9379:6379 --name redis-redisbloom redislabs/rebloom:latest
1:C 15 Aug 2020 03:26:02.860 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
1:C 15 Aug 2020 03:26:02.860 # Redis version=6.0.5, bits=64, commit=00000000, modified=0, pid=1, just started
1:C 15 Aug 2020 03:26:02.860 # Configuration loaded
1:M 15 Aug 2020 03:26:02.862 * Running mode=standalone, port=6379.
1:M 15 Aug 2020 03:26:02.862 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
1:M 15 Aug 2020 03:26:02.862 # Server initialized
1:M 15 Aug 2020 03:26:02.862 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
1:M 15 Aug 2020 03:26:02.862 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
1:M 15 Aug 2020 03:26:02.864 * Module 'bf' loaded from /usr/lib/redis/modules/redisbloom.so
1:M 15 Aug 2020 03:26:02.864 * Ready to accept connections
^C1:signal-handler (1597462093) Received SIGINT scheduling shutdown...
1:M 15 Aug 2020 03:28:13.217 # User requested shutdown...
1:M 15 Aug 2020 03:28:13.217 # Redis is now ready to exit, bye bye...
```

根据提示修改内存参数等，注意使用root用户：

```bash
cc@Chirius:/mnt/c/Users/Chirius$ cd ~
cc@Chirius:~$ su root
Password:
root@Chirius:/home/cc# vi /etc/sysctl.conf
root@Chirius:/home/cc# sysctl vm.overcommit_memory=1
vm.overcommit_memory = 1
root@Chirius:/home/cc# echo never > /sys/kernel/mm/transparent_hugepage/enabled
root@Chirius:/home/cc# ll /sys/kernel/mm/transparent_hugepage/enabled
-rw-r--r-- 1 root root 4096 Aug 15 11:30 /sys/kernel/mm/transparent_hugepage/enabled
root@Chirius:/home/cc# cat /sys/kernel/mm/transparent_hugepage/enabled
always madvise [never]
root@Chirius:/home/cc# ll /etc/rc.local
ls: cannot access '/etc/rc.local': No such file or directory
root@Chirius:/home/cc# vi /etc/rc.local
root@Chirius:/home/cc#
```

然后再重启容器，就可以启动成功了，然后进行体验

# 叁、布隆过滤器体验

## 3.1 常用命令

> 注意： key:布隆过滤器的名称，item : 添加的元素。

- `BF.ADD`：将元素添加到布隆过滤器中，如果该过滤器尚不存在，则创建该过滤器。格式：`BF.ADD {key} {item}`。
- `BF.MADD`: 将一个或多个元素添加到“布隆过滤器”中，并创建一个尚不存在的过滤器。该命令的操作方式BF.ADD与之相同，只不过它允许多个输入并返回多个值。格式：`BF.MADD {key} {item} [item ...]`。
- `**BF.EXISTS **`: 确定元素是否在布隆过滤器中存在。格式：`BF.EXISTS {key} {item}`。
- `BF.MEXISTS`： 确定一个或者多个元素是否在布隆过滤器中存在格式：`BF.MEXISTS {key} {item} [item ...]`。

另外，`BF.RESERVE`命令需要单独介绍一下：

这个命令的格式如下：

```shell
BF.RESERVE {key} {error_rate} {capacity} [EXPANSION expansion] 。

```

下面简单介绍一下每个参数的具体含义：

- `key`：布隆过滤器的名称
- `error_rate`:误报的期望概率。这应该是介于0到1之间的十进制值。例如，对于期望的误报率0.1％（1000中为1），`error_rate`应该设置为0.001。该数字越接近零，则每个项目的内存消耗越大，并且每个操作的CPU使用率越高。
- `capacity`: 过滤器的容量。当实际存储的元素个数超过这个值之后，性能将开始下降。实际的降级将取决于超出限制的程度。随着过滤器元素数量呈指数增长，性能将线性下降。

可选参数：

- expansion：如果创建了一个新的子过滤器，则其大小将是当前过滤器的大小乘以`expansion`。默认扩展值为2。这意味着每个后续子过滤器将是前一个子过滤器的两倍。
    

## 3.2 体验

```bash
cc@Chirius:/mnt/c/Users/Chirius$ docker exec -it redis-redisbloom bash
root@9cc653f9411a:/data# redis-cli
127.0.0.1:6379> BF.ADD mine zzl
(integer) 1
127.0.0.1:6379> BF.ADD mine llo
(integer) 1
127.0.0.1:6379> BF.ADD mine iio
(integer) 1
127.0.0.1:6379> BF.EXISTS mine super
(integer) 0
127.0.0.1:6379> BF.EXISTS mine iio
(integer) 1
127.0.0.1:6379> BF.EXISTS mine zzl
(integer) 1
127.0.0.1:6379>

```


【**后面的话**】布隆过滤器主要用来解决`缓存穿透(大量请求的 key 根本不存在于缓存中，导致请求直接到了数据库上，根本没有经过缓存这一层)`。一般MySQL 默认的最大连接数在 150 左右，这个可以通过`show variables like '%max_connections%';`命令来查看。最大连接数一个还只是一个指标，cpu，内存，磁盘，网络等无力条件都是其运行指标，这些指标都会限制其并发能力！所以，一般`3000`个并发请求就能打死大部分数据库了。布隆过滤器是一个非常神奇的数据结构，通过它我们可以非常方便地判断一个给定数据是否存在与海量数据中。我们需要的就是判断`key`是否合法。具体是这样做的：把所有可能存在的请求的值都存放在布隆过滤器中，当用户请求过来，我会先判断用户发来的请求的值是否存在于布隆过滤器中。不存在的话，直接返回请求参数错误信息给客户端，存在的话才会走具体的业务的流程。


---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
