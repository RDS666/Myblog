# My Hexo Blog

这是一个已经配置好 `Hexo + Butterfly + GitHub Pages` 的个人博客项目。

## 本地运行

```bash
npm install
npm run server
```

浏览器打开 `http://localhost:4000`。

## 你需要先改的地方

编辑 [\_config.yml](./_config.yml)：

- `title`
- `author`
- `description`
- `url`
- `root`

编辑 [\_config.butterfly.yml](./_config.butterfly.yml)：

- GitHub 链接
- 邮箱
- 首页副标题
- 公告和侧边栏文案

## GitHub Pages 发布

推荐使用个人主页仓库：

1. 在 GitHub 创建仓库：`<你的用户名>.github.io`，或者像你现在这样用项目仓库 `Myblog`
2. 把本项目推到该仓库的 `main` 分支
3. 在仓库 `Settings -> Pages` 中确认发布来源为 `GitHub Actions`
4. 等待 `Actions` 工作流执行完成

如果你使用的是项目仓库，比如你现在的 `Myblog`，记得把 [\_config.yml](./_config.yml) 里的 `url` 设为 `https://rds666.github.io`，`root` 设为 `/Myblog/`。

## 常用命令

```bash
npm run server
npm run build
npx hexo clean
npx hexo new post "文章标题"
```

## 主题说明

当前使用的是 `Butterfly` 主题，它比 Hexo 默认主题更现代，也更适合个人博客。以后如果你想换风格，可以继续试试：

- NexT
- Stellar
- Keep
