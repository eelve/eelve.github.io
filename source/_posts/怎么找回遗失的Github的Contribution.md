---
title: 怎么找回遗失的Github的Contribution
date: 2020-03-01 00:18:06
tags: github
categories: github
description: 在日常工作中，一般都会用到版本管理工具git，往往项目组要求的提交信息和Github的提交信息是不一致的，有的时候就可能会出现不可避免的犯错，导致Github的Contribution丢失，进而就在Github中丢失了打卡记录。好在Github提供了解决方法，下面就把官网的方案搬过来。
---
【**前面的话**】在日常工作中，一般都会用到版本管理工具git，往往项目组要求的提交信息和Github的提交信息是不一致的，有的时候就可能会出现不可避免的犯错，导致Github的Contribution丢失，进而就在Github中丢失了打卡记录。好在Github提供了解决方法，下面就把官网的方案搬过来。

---

首先是官网的原网站：
[Changing author info](https://help.github.com/en/github/using-git/changing-author-info) 

To change the name and/or email address recorded in existing commits, you must rewrite the entire history of your Git repository.


---
下面是中文翻译

1.打开终端（Mac 或 Linux 用户）或命令行（Windows 用户）。

2.创建一个你的 repo 的全新裸 clone （repo.git 替换为你的项目，下同） 
```shell script
git clone --bare <https://github.com/user/repo.git> cd repo.git
```

3.复制粘贴脚本，并根据你的信息修改以下变量：
```yaml
OLD_EMAIL
CORRECT_NAME
CORRECT_EMAIL
```

脚本：
```shell script
#!/bin/sh

git filter-branch --env-filter '

OLD_EMAIL="your-old-email@example.com"
CORRECT_NAME="Your Correct Name"
CORRECT_EMAIL="your-correct-email@example.com"

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
```

4.按 Enter 执行脚本。

5.查看新 Git 历史有没有错误。

6.把正确历史 push 到 Github：（push 有困难时记得修改 DNS 或者搭梯子） 
```shell script
git push --force --tags origin 'refs/heads/*'
```

7.清除临时 clone。
 ```shell script
cd ..
rm -rf repo.git
```

---
【**后面的话**】正确合理的设置全局用户名和邮箱，同时针对有特殊要求的项目就可以单独设置。
```shell script
git config user.name  "name"
git config --global user.name "globalname"
git config user.email  "email"
git config --global user.email  "globalemail"

```
同时该操作谨慎在与他人的合作项目中使用，改变作者信息 为改变已经存在的 commit 的用户名和/或邮箱地址，你必须重写你 Git repo 的整个历史。

    警告：这种行为对你的 repo 的历史具有破坏性。如果你的 repo 是与他人协同工作的，重写已发布的历史是一种不好的习惯。仅限紧急情况执行该操作。 使用脚本改变你 repo 的 Git 历史 我们写了一段能把 commit 作者旧的邮箱地址修改为正确用户名和邮箱的脚本。
    
    注意：执行这段脚本会重写 repo 所有协作者的历史。完成以下操作后，任何 fork 或 clone 的人必须获取重写后的历史并把所有本地修改 rebase 入重写后的历史中。

意思就是需要重新拉去代码才能继续进行开发了

---

![薏米笔记](https://image.eelve.com/eblog/eblog-b269767ff45b4e01a1c380e38898c1c0.png)
