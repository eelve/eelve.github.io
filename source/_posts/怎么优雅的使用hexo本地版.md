---
title: 怎么优雅的使用hexo
tags: hide
categories: hide
description: >-
  在使用hexo搭建自己的个人博客前，我一直使用Halo来搭建自己的博客。但是还是决定用hexo再搭建一个博客，主要是为了让自己在Github上留下自己的印记。
abbrlink: 152670fd
date: 2020-02-23 22:20:58
---
【**前情提要**】在使用[hexo](https://hexo.io/zh-cn/)搭建自己的个人博客前，我一直使用[Halo](https://halo.run/)来搭建自己的博客。但是还是决定用hexo再搭建一个博客，主要是为了让自己在Github上留下自己的印记。

-----
关于hexo的基础使用知识我在这里就不做过多的介绍了，如果是在是不知道可以看以下[官方文档](https://hexo.io/zh-cn/docs/)。我这里主要说一下怎么用Github保存博客源代码和生成的网站代码。

* 1.新建一个分支用来保存博客源代码，并且设为默认分支，如下图所示
![20200223011](https://eelve.com/upload/2020/2/20200223011-1816538384854e64bb090740d8ea0621.png)
* 2.执行hexo d -g上传博客内容
* 3.使用git命令提交源代码到eblog分支
**这样当你换电脑或者重新构建项目的时候就可以从github拉去代码就可以进行继续编写了，是不是很方便**

---
【**小贴士**】常用hexo插件
* 1.permalink_pinyin,将文章标题中的汉字转为拼音，有利于SEO
```yaml
permalink_pinyin:
  enable: true
  separator: '-' # default: '-'
```
* 2.hexo-generator-cname,避免每次提交之后都要重新配置博客域名的工作
```yaml
#设置保存CNAME的插件
Plugins:
  - hexo-generator-cname
```
* 3.提交博客之前最好可以预览一遍，一般出现样式不正确之后，记得使用hexo clean命令哦

---
最后附上一个我的博客的基本配置
```yaml
# Hexo Configuration
## Docs: https://hexo.io/docs/configuration.html
## Source: https://github.com/hexojs/hexo/

# Site
title: 南国薏米
subtitle: 南国不须收薏苡,百年终竟是芭蕉。
description: A human being,who loves football and music.
keywords: 南国薏米
author: Chillo
language: zh-CN
timezone: Asia/Shanghai

# URL
## If your site is put in a subdirectory, set url as 'http://yoursite.com/child' and root as '/child/'
url: http://zzlve.win
root: /
permalink: :year/:month/:day/:title/
permalink_defaults:

# Directory
source_dir: source
public_dir: public
tag_dir: tags
archive_dir: archives
category_dir: categories
code_dir: downloads/code
i18n_dir: :lang
skip_render:

# Writing
new_post_name: :title.md # File name of new posts
default_layout: post
titlecase: false # Transform title into titlecase
external_link: true # Open external links in new tab
filename_case: 0
render_drafts: false
post_asset_folder: false
relative_link: false
future: true
highlight:
  enable: true
  line_number: true
  auto_detect: false
  tab_replace:

# Home page setting
# path: Root path for your blogs index page. (default = '')
# per_page: Posts displayed per page. (0 = disable pagination)
# order_by: Posts order. (Order by date descending by default)
index_generator:
  path: ''
  per_page: 10
  order_by: -date

# Category & Tag
default_category: uncategorized
category_map:
tag_map:

# Date / Time format
## Hexo uses Moment.js to parse and display date
## You can customize the date format as defined in
## http://momentjs.com/docs/#/displaying/format/
date_format: YYYY-MM-DD
time_format: HH:mm:ss

# Pagination
## Set per_page to 0 to disable pagination
per_page: 10
pagination_dir: page

# Extensions
## Plugins: https://hexo.io/plugins/
## Themes: https://hexo.io/themes/
theme: next

# Deployment
## Docs: https://hexo.io/docs/deployment.html
deploy:
  type: git
  repo: https://github.com/eelve/eelve.github.io.git
  branch: master

#设置保存CNAME的插件
Plugins:
  - hexo-generator-cname


feed:
  type: atom
  path: atom.xml
  limit: 20
plugins: hexo-generate-feed


search:
  path: search.xml
  field: post
  format: html
  limit: 10000

permalink_pinyin:
  enable: true
  separator: '-' # default: '-'
```
---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
