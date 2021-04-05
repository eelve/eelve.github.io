---
title: 基于Redis实现限流
date: 2021-04-03 22:58:13
tags: limiting
categories: limiting
description: 前面说过目前几种比较常见的限流的中间件，Sentinel、Hystrix和resilience4j，也提到过自己实现限流功能，今天就基于Redis实现一哈限流功能。
---
【**前情提要**】前面说过目前几种比较常见的限流的中间件，Sentinel、Hystrix和resilience4j，也提到过自己实现限流功能，今天就基于Redis实现一哈限流功能。

# 壹、Redis实现限流介绍

前面说过基于Guava的限流的解决方案，但是这个方案只适用于单体应用，所以这边我们就可用借助第三方中间件来实现，这里就使用Redis来实现，进一步实现集群限流的功能。主要参考Redis官方的伪代码：[https://redis.io/commands/incr](https://redis.io/commands/incr)


# 贰、基于Redis的setnx的操作

我们在使用Redis的分布式锁的时候，大家都知道是依靠了setnx的指令，在CAS（Compare and swap）的操作的时候，同时给指定的key设置了过期实践（expire），我们在限流的主要目的就是为了在单位时间内，有且仅有N数量的请求能够访问我的代码程序。所以依靠setnx可以很轻松的做到这方面的功能。

比如我们需要在10秒内限定20个请求，那么我们在setnx的时候可以设置过期时间10，当请求的setnx数量达到20时候即达到了限流效果。代码比较简单就不做展示了。

当然这种做法的弊端是很多的，比如当统计1-10秒的时候，无法统计2-11秒之内，如果需要统计N秒内的M个请求，那么我们的Redis中需要保持N个key等等问题。

# 叁、基于Redis的数据结构zset

其实限流涉及的最主要的就是滑动窗口，上面也提到1-10怎么变成2-11。其实也就是起始值和末端值都各+1即可。

而我们如果用Redis的list数据结构可以轻而易举的实现该功能，我们可以将请求打造成一个zset数组，当每一次请求进来的时候，value保持唯一，可以用UUID生成，而score可以用当前时间戳表示，因为score我们可以用来计算当前时间戳之内有多少的请求数量。而zset数据结构也提供了range方法让我们可以很轻易的获取到2个时间戳内有多少请求

```java
public Response limitFlow(){
    Long currentTime = new Date().getTime();
    System.out.println(currentTime);
    if(redisTemplate.hasKey("limit")) {
        Integer count = redisTemplate.opsForZSet().rangeByScore("limit", currentTime -  intervalTime, currentTime).size();        // intervalTime是限流的时间 
        System.out.println(count);
        if (count != null && count > 5) {
            return Response.ok("每分钟最多只能访问5次");
        }
    }
    redisTemplate.opsForZSet().add("limit",UUID.randomUUID().toString(),currentTime);
    return Response.ok("访问成功");
}
```

通过上述代码可以做到滑动窗口的效果，并且能保证每N秒内至多M个请求，缺点就是zset的数据结构会越来越大。实现方式相对也是比较简单的。

# 肆、基于Redis的令牌桶算法

令牌桶算法提及到输入速率和输出速率，当输出速率大于输入速率，那么就是超出流量限制了。也就是说我们每访问一次请求的时候，可以从Redis中获取一个令牌，如果拿到令牌了，那就说明没超出限制，而如果拿不到，则结果相反。

依靠上述的思想，我们可以结合Redis的List数据结构很轻易的做到这样的代码，只是简单实现依靠List的leftPop来获取令牌

```java
// 输出令牌
public Response limitFlow2(Long id){
    Object result = redisTemplate.opsForList().leftPop("limit_list");
    if(result == null){
        return Response.ok("当前令牌桶中无令牌");
    }
    return Response.ok(articleDescription2);
}
```
再依靠Java的定时任务，定时往List中rightPush令牌，当然令牌也需要唯一性，所以我这里还是用UUID进行了生成

```java
// 10S的速率往令牌桶中添加UUID，只为保证唯一性
@Scheduled(fixedDelay = 10_000,initialDelay = 0)
public void setIntervalTimeTask(){
    redisTemplate.opsForList().rightPush("limit_list",UUID.randomUUID().toString());
}
```

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
