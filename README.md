# RDS666 的博客

基于 Hexo 与 Butterfly 构建，通过 GitHub Actions 自动部署到 GitHub Pages。

## 本地运行

```powershell
npm install
npm run dev
```

访问 <http://localhost:4000/Myblog/>。

## 新建文章

```powershell
npm run new -- "文章标题"
```

文章保存在 `source/_posts/`。完成后推送到 `main` 分支，GitHub Actions 会自动发布网站。

## 通过配置自动发布 Markdown

1. 将 Markdown 文档放入 `drafts/article.md`，也可以在配置中填写任意本地文件的绝对路径。
2. 编辑根目录下的 `publish.config.json`，填写标题、slug、分类、标签和封面等信息。
3. 运行发布命令：

```powershell
npm run publish
```

脚本会自动生成 Hexo Front Matter、复制文章和图片、执行构建检查、创建 Git 提交并推送到 GitHub。GitHub Actions 随后会更新线上网站。

只检查配置而不发布时，可以运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/publish.ps1 -ValidateOnly
```

`slug` 只允许小写英文字母、数字和连字符。需要更新已经发布的同名文章时，将 `overwrite` 改为 `true`。完整配置说明见 `publish.config.example.json`。

## 常用命令

```powershell
npm run clean   # 清理生成文件
npm run build   # 构建静态网站
npm run dev     # 启动本地预览
```
