---
title: 如何在这个博客发布新文章
date: 2026-09-28 10:00:00
updated: 2026-09-29 16:30:00
categories:
  - 博客搭建
tags:
  - Hexo
  - Markdown
  - GitHub Pages
cover: /images/cover-code.jpg
description: 一份留给自己的 Hexo 写作与发布速查手册。
---

这篇文章是一份简短的使用说明，记录如何创建、预览和发布博客文章。

<!-- more -->

## 创建文章

在项目目录执行：

```powershell
npm run new -- "文章标题"
```

新文件会出现在 `source/_posts/` 目录。文件开头的 Front Matter 用来配置标题、日期、分类、标签和封面：

```yaml
---
title: 文章标题
date: 2026-09-29 18:00:00
categories:
  - 技术
tags:
  - 学习笔记
cover: /images/cover-code.jpg
description: 一句话介绍文章内容。
---
```

## 本地预览

```powershell
npm run dev
```

浏览器访问 `http://localhost:4000/Myblog/`，保存 Markdown 后页面会自动重新生成。

## 发布网站

确认预览没有问题后提交并推送：

```powershell
git add .
git commit -m "发布：文章标题"
git push
```

GitHub Actions 会自动构建网站并部署到 GitHub Pages。第一次部署时，需要在仓库的 **Settings → Pages → Build and deployment** 中将 Source 设为 **GitHub Actions**。
