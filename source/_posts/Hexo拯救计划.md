---
title: Hexo拯救计划
tags: lifeme
categories: lifeme
description: >-
  就在上个月底，Github遭受了中间人攻击，导致Github Pages的证书被篡改失效，而基于此的一众利用Github
  Pages生成博客全部都不能访问。鉴于“不能把鸡蛋放在同一个篮子里”的优秀理念，我决定给我的博客找一个新家。
abbrlink: 7eb7357b
date: 2020-04-06 14:37:42
---

【**前面的话**】就在上个月底，Github遭受了中间人攻击，导致Github Pages的证书被篡改失效，而基于此的一众利用Github Pages生成博客全部都不能访问。鉴于“不能把鸡蛋放在同一个篮子里”的优秀理念，我决定给我的博客找一个新家。

# 壹、第三方博客

本人在有[Github Pages生成的博客](https://zzlve.win)之外，我还有拥有[Halo搭建的博客](https://eelve.com)。[Halo](https://halo.run/)一个优秀的开源博客发布应用。
# 贰、CloudFlare

我们可以利用CloudFlare，在Hexo外层套一层证书，进而不使用Github Pages的证书，来避免这个问题。目前我的博客就是使用的CloudFlare，其访问速度和Gihub Pages的Fastly Anycast节点速度差不多，都是比较慢。

# 叁、Gitee/Coding/GitLab

我们也可以使用其他托管平台提供的服务，主要就是你需要将你的源程序上传到对应的平台然后在上面发布，下面说一下优缺点：

- [Gitee](https://eelve.gitee.io)
  - 优点：
    - 1.支持HTTPS
    - 2.上海腾讯云节点
  - 缺点
    - 自定义域名需要付费套餐（且域名需要备案）  


- Coding
  - 优点：
    - 1.可自定义域名
    - 2.支持HTTPS
    - 3.全球腾讯云新加坡CN2
  - 缺点
    - 1.不稳定
    - 2.不能被百度爬虫收录



- GitLab
  - 优点：
    - 1.可自定义域名，自定义证书
    - 2.支持HTTPS，一键SSL配置
    - 3.GitLab-CI集成
    - 4.Fastly Anycast节点
    - 5.与GitHub功能上差不多，自带的GitLab-Ci持续部署能有效地提高效率。
  - 缺点
    - 1.国内访问速度与GitHub相似


# 肆、Netlify

主要特点：
- 1.可自定义域名
- 2.支持HTTPS HTTP/2 IPv6
- 3.自定义页面重定向，静态资源优化
- 4.DigitalOcean 美国纽约&新加坡节点

另外Netlify提供的服务应该算是最多的。自定义插入代码、打包和压缩js/css、压缩，处理图片、自动部署、提供Webhooks与API等功能。

我自己的实现：[南国薏米](https://eelve.netlify.com/)。在我本地提交代码之后会自动触发，重新解析从而可以达到博客同步更新，在这一点上是和Github Pages更新是一样的。


# 伍、ZEIT

主要特点：
- 1.可自定义域名，自定义证书（付费）
- 2.支持HTTPS
- 3.提供ServerLess服务
- 4.GCP&AWS节点
- 5.国内电信联通走台湾（电信有些地区35段绕美国），移动走美国

另外大陆速度不错，可使用 now.sh CLI或GitHub，GitLab，Bitbucket导入项目进行自动代码部署，提供ServerLess，会地总分配的*.now.sh域名，但免费额度的流量有点少，限量20G。

我自己的实现：[南国薏米](https://eelve-github-io.now.sh/)。在我本地提交代码之后会自动触发，重新解析从而可以达到博客同步更新，在这一点上是和Github Pages更新是一样的。说实话我们完全可以将博客迁移，并且你之前开发Hexo的不走完全没有改变。另外你的Hexo是采用多分支管理：博客分支和源代码分支。如果你的源代码分支中包含主题子仓库的话，发布之后ZEIT是不能正常解析的，会丢失样式。如果为了解决我们可以配置ZEIT是解析我们Hexo博客分支就 可以了。

# 陆、云存储

我这里有一个利用又拍云实现的案例：[南国薏米](https://image.eelve.com/)。我们可以在生成静态页面之后，将页面全部上传的控件中，然后在云存储中开启index首页，就可以正常访问了。这里我们还可以结合hexo的插件来使用：

安装插件

```shell script
npm install hexo-deployer-upyundeploy --save
```

编辑根目录的_config.yml文件的deploy字段,配置又拍云存储的服务名称、操作员名称、操作员密码

```yaml
deploy:
  - type: upyun
    serviceName: 服务名称
    operatorName: 操作员名称
    operatorPassword: 操作员密码
    path: / 上传目录(选填，默认为根目录)
```


---

【**后面的话**】以上列举的各种方法，叁、肆、伍、陆都是生成静态博客。其中我个人最推荐方案伍，不仅你的开放方式不会改变，另外还能得到比较好的访问速度，还可以被百度的爬虫抓取。另外如果有服务器也喜欢的折腾的话，可以使用地方法博客程序搭建，包括但不仅限于Halo。

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
