---
title: 用命令将本地jar包导入到本地maven仓库
date: 2019-08-09 17:15:04
tags: maven
---
【**前情提要**】在日常开发过程中，我们总是不可避免的需要依赖某些不在中央仓库，同时也不在本地仓库中的jar包，这是我们就需要使用命令行将需要导入本地仓库中的jar包导入本地仓库，使得项目依赖本地仓库中的代码。

-----
例如我们需要将下面pom文件中的jar包引入本地仓库
```xml
      <dependency>
            <groupId>com.eelve</groupId>
            <artifactId>todo</artifactId>
            <version>1.0</version>
       </dependency>
```

----
导入命令
```xml
mvn install:install-file -Dfile=D:\link\lib\todo-1.0.jar  -DgroupId=com.eelve -DartifactId=todo -Dversion=1.0 -Dpackaging=jar
```

-----
命令详解
```xml
-Dfile：jar包所在本地的具体路径
-DgroupId：项目组织唯一的标识符，实际对应JAVA的包的结构
-DartifactId：项目的唯一的标识符，实际对应项目的名称，就是项目根目录的名称
-Dversion：版本号
-Dpackaging：打包的类型

```

----
结果示例
![导入jar包结果](https://eelve.com/upload/2019/6/导入jar包结果-859bee2db9f14a2a8079b449d38e061c.png)

---
【小贴士】maven的仓库分类

在maven中，仓库可以分为：本地仓库、远程仓库。
远程仓库可以分为：中央仓库、私服仓库。
中央仓库是maven官方指定的仓库，可以理解为“寻找的最后一站”。
私服仓库可以是自己建的，也可以是其它主体建的（比如aliyun的maven仓库，jboss的maven仓库等）。
私服可以分为：全局应用的私服仓库、应用到项目自身的私服仓库。

maven寻找得顺序大致可以理解为：
1，在本地仓库中寻找，如果没有则进入下一步。
2，在全局应用的私服仓库中寻找，如果没有则进入下一步。
3，在项目自身的私服仓库中寻找，如果没有则进入下一步。
4，在中央仓库中寻找，如果没有则终止寻找。

补充：
1，如果在找寻的过程中，如果发现该仓库有镜像设置，则用镜像的地址代替。
2，如果仓库的id设置成“central”，则该配置会覆盖maven默认的中央仓库配置。

以上，通过实践得来的，可能不全面，仅当参考
