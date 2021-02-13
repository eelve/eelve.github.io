---
layout: spring
title: Spring Boot单体应用集成Sentinel熔断能力
date: 2021-02-13 11:52:54
tags: hide
categories: hide
description: 前面对Sentinel的入门知识有了一定了解之后，这里就来介绍在生产中简单的应用。
---


【**前面的话**】在前文 [Sentinel入门指北](https://eelve.com/archives/hellosentinel) 中对`Sentinel`有了简单的了解之后，下面就`Spring Boot`单体应用集成`Sentinel`做一下简单的讨论。实际上官方已经提供了[Spring Cloud Alibaba Sentinel](https://github.com/alibaba/spring-cloud-alibaba/wiki/Sentinel)，然后在配合`控制台`就可以方便使用熔断能力。但是存在部分不想引入`控制台`的场景，此文就由此而来。

---

# 壹、sentinel介绍

---

【**后面的话**】

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
