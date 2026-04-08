---
title: 把博客部署到 GitHub Pages 的自动化流程
date: 2026-04-08 16:10:00
updated: 2026-04-08 16:10:00
description: 使用 GitHub Actions 自动生成并发布 Hexo 静态页面。
tags:
  - GitHub Actions
  - GitHub Pages
  - 自动化
categories:
  - 部署
cover: /img/post-2.svg
---

我不想每次写完文章都手动复制静态文件，所以最适合博客的方式，往往是把部署也交给 GitHub Actions。

<!-- more -->

自动化部署的好处很直接：

- 只要推送到 `main` 分支，就会自动构建站点
- 发布流程固定，减少本地环境差异
- 以后换电脑也不用重新记一套部署命令

这个仓库里已经准备好了 GitHub Pages 工作流文件。你把代码推到 GitHub 后，只需要：

1. 创建一个仓库
2. 把 `_config.yml` 里的 `url` 和 `root` 改成你自己的
3. 在仓库设置里启用 GitHub Pages，并选择 `GitHub Actions` 作为发布来源

之后每次提交文章，博客都会跟着自动更新。对个人站来说，这种维护成本是很友好的。
