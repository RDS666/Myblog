---
title: 使用配置自动发布 Markdown 文章
date: 2026-09-29 18:30:00
updated: 2026-09-29 18:30:00
categories:
  - 博客搭建
tags:
  - Hexo
  - Markdown
  - GitHub Pages
cover: /images/cover-code.jpg
description: 从一篇本地 Markdown 到线上博客的完整操作指南。
---

这篇文章说明如何使用项目中的自动发布工具，把本地 Markdown 文档发布到博客。

<!-- more -->

## 一、工具做了什么

运行一次命令后，工具会依次完成：

1. 读取 `publish.config.json`
2. 找到指定的 Markdown 文件
3. 根据配置生成 Hexo Front Matter
4. 将文章复制到 `source/_posts/`
5. 执行 Hexo 构建检查
6. 创建 Git 提交
7. 推送到 GitHub
8. 触发 GitHub Actions 更新网站

网站地址是：<https://rds666.github.io/Myblog/>

## 二、第一次使用

在项目根目录 `F:\个人博客` 打开 PowerShell。

如果本地还没有发布配置，先复制示例：

```powershell
Copy-Item publish.config.example.json publish.config.json
```

`publish.config.json` 已经被加入 `.gitignore`，只保存在本地，不会上传到 GitHub。

## 三、准备 Markdown 文件

最简单的做法是编辑：

```text
drafts/article.md
```

这个目录专门存放尚未发布的文章，不会被 Git 跟踪。正文可以直接使用普通 Markdown：

```markdown
# 文章正文标题

这里是文章内容。

## 小标题

继续写正文、代码和列表。
```

文档可以放在任意位置，稍后在配置的 `file` 字段中填写路径。

## 四、填写发布配置

打开项目根目录的 `publish.config.json`：

```json
{
  "file": "drafts/article.md",
  "title": "我的第一篇文章",
  "slug": "my-first-post",
  "categories": ["技术笔记"],
  "tags": ["学习", "Markdown"],
  "description": "文章在首页显示的简介。",
  "cover": "/images/cover-code.jpg",
  "coverFile": "",
  "assetsDirectory": "",
  "date": "auto",
  "updated": "auto",
  "useExistingFrontMatter": false,
  "overwrite": false,
  "commitMessage": "发布：我的第一篇文章",
  "push": true
}
```

字段说明：

| 字段 | 用途 |
| --- | --- |
| `file` | Markdown 文件路径，可以是相对项目根目录的路径或绝对路径 |
| `title` | 文章标题 |
| `slug` | 文章网址名称，只能用小写英文、数字和连字符 |
| `categories` | 分类数组 |
| `tags` | 标签数组 |
| `description` | 首页文章简介 |
| `cover` | 已经存在于博客中的封面 URL |
| `coverFile` | 本地封面文件，会自动复制到博客图片目录 |
| `assetsDirectory` | 文章图片所在的本地目录 |
| `date` | 写 `auto` 自动使用当前时间，也可以手动填写日期 |
| `updated` | 写 `auto` 自动使用当前时间 |
| `useExistingFrontMatter` | 原文已有完整 Hexo 头部时设为 `true` |
| `overwrite` | 更新同名文章时设为 `true`，新文章保持 `false` |
| `push` | 是否自动执行 `git push` |

### Windows 路径的正确写法

JSON 中的反斜杠必须写成两个：

```json
"file": "C:\\Users\\86199\\Desktop\\后端\\java集合.md"
```

不要把额外的双引号写进路径：

```json
"file": "\"C:\\Users\\86199\\Desktop\\后端\\java集合.md\""
```

后一种写法会把 `"` 当成文件名的一部分，从而报“路径中具有非法字符”。

## 五、先校验，不发布

建议每次先运行：

```powershell
npm run publish -- --ValidateOnly
```

如果看到：

```text
Config and Markdown validation passed.
```

说明路径、slug 和文章格式都通过了检查。这一步不会生成文章、不会提交，也不会推送。

## 六、正式发布

确认校验通过后运行：

```powershell
npm run publish
```

成功时会看到构建、提交和推送信息。等待 GitHub Actions 运行完成后，文章就会出现在博客中。

## 七、发布本地图片

### 封面图

如果封面图片在本地，例如：

```text
C:\Users\86199\Desktop\cover.jpg
```

可以配置：

```json
"coverFile": "C:\\Users\\86199\\Desktop\\cover.jpg"
```

脚本会自动复制图片，并生成对应的 `cover` 路径。

### 正文图片

把正文图片放在一个目录，例如：

```text
drafts/article-assets/
├── diagram.png
└── screenshot.jpg
```

配置：

```json
"assetsDirectory": "drafts/article-assets"
```

然后在 Markdown 中使用发布后的路径：

```markdown
![示意图](/images/posts/my-first-post/diagram.png)
```

其中 `my-first-post` 必须和配置里的 `slug` 一致。

## 八、更新已经发布的文章

保持原来的 `slug`，修改 Markdown 内容，并将：

```json
"overwrite": true
```

然后重新运行：

```powershell
npm run publish
```

更新完成后可以把 `overwrite` 改回 `false`，避免之后误覆盖文章。

## 九、已有 Front Matter 的文章

如果 Markdown 文件已经包含完整的 Hexo 头部：

```markdown
---
title: 已有标题
date: 2026-09-29 10:00:00
categories:
  - 技术
---
```

将配置改为：

```json
"useExistingFrontMatter": true
```

如果保持 `false`，脚本会移除原来的头部，并使用 `publish.config.json` 重新生成。

## 十、常见问题

### `The post already exists`

slug 已经被使用。新文章换一个 slug；要更新旧文章则把 `overwrite` 设为 `true`。

### `Invalid path` 或“路径中具有非法字符”

检查 Windows 路径是否使用了双反斜杠，并确认没有把额外的引号写进路径。

### 推送失败

文章和本地提交会保留，不会丢失。网络恢复后在项目根目录执行：

```powershell
git push
```

### 网站没有立即更新

打开仓库的 `Actions`，等待 `Deploy Hexo to GitHub Pages` 变成绿色。通常需要几十秒到几分钟。
