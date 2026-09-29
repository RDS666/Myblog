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

## 常用命令

```powershell
npm run clean   # 清理生成文件
npm run build   # 构建静态网站
npm run dev     # 启动本地预览
```
