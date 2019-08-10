---
title: No PostCSS Config found in ...报错解决
date: 2019-08-09 17:10:14
tags: [node,github]
categories: node
---
【**前情提要**】日前本人将本地项目上传GitHub之后，然后再clone到本地，运行是报错：Error: No PostCSS Config found in...

---
项目在本地打包运行的时候不报错，上传到 GitHub 之后，再 clone 到本地，执行安装依赖命令：
```shell
cnpm install
```
安装完依赖之后再执行编译命令：
```shell
npm run dev
```
这个时候居然报错了，纳尼？以为是Github代码的问题，就重新操作两遍，依然还是报错。于是开始搜索解决办法，在项目根目录新建postcss.config.js文件，并对postcss进行配置：
```propertis
module.exports = { 
  plugins: { 
    'autoprefixer': {browsers: 'last 5 version'} 
  } 
}
```
然后测试，果然好了

```shell
npm run dev
```

项目在本地运行时本来不报错的，但是为什么上传到 GitHub 之后，再 clone 下来，再运行就得单独写一个 postcss.config.js 的文件并配置一下呢？

在npm上查到的postcss配置在webpack.config.js，postcss.config.js是针对webpack3.0做的特殊处理

【小贴士】如果在国内执行npm install很慢的话，可以安装cnpm命令，使用淘宝镜像，速度贼快。cnpm跟npm用法完全一致，只是在执行命令时将npm改为cnpm即可。但是cnpm 的仓库只是 npm 仓库的一个拷贝，它不承担 publish 工作，所以你用 cnpm publish 命令会执行失败的，另外不仅是 publish 会执行失败，其它的需要注册用户(npm adduser)、或者修改 package 状态等命令都无法用 cnpm。

---
[淘宝 NPM 镜像](http://npm.taobao.org/)：这是一个完整 npmjs.org 镜像，你可以用此代替官方版本(只读)，同步频率目前为 10分钟 一次以保证尽量与官方服务同步。
