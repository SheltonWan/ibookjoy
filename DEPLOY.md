# ibookjoy 部署指南

**目标**：将 ibookjoy 项目以静态站点形式部署到服务器，通过 `https://www.smartwingtech.com/ibookjoy` 访问，不影响原有站点。

---

## 原理说明

- 项目使用 `next build` 的 `output: 'export'` 模式，生成纯静态 HTML/CSS/JS 文件到 `out/` 目录
- 已在 `next.config.ts` 中设置 `basePath: '/ibookjoy'`，Next.js 会自动处理所有内部链接和静态资源路径
- 服务器只需通过 Nginx 将 `/ibookjoy` 路径指向静态文件目录，**无需 Node.js 进程**，不会影响原有站点

---

## 快速部署（脚本方式）

### 步骤一：修改脚本配置

打开 `deploy.sh`，将 `YOUR_SERVER_IP` 替换为真实 IP：

```bash
SERVER_IP="150.158.49.134"
```

如果使用 SSH 密钥登录（推荐），同时填写：

```bash
SSH_KEY="~/.ssh/id_rsa"   # 你的私钥路径
```

### 步骤二：赋予脚本执行权限并运行

```bash
chmod +x deploy.sh
./deploy.sh
```

脚本会自动完成：构建 → 上传（增量同步）。

---

## 首次部署：配置 Nginx（必须手动操作一次）

### 方法一：通过宝塔面板（推荐）

1. 登录宝塔面板（通常是 `http://服务器IP:8888`）
2. 左侧菜单 → **网站** → 找到 `smartwingtech.com` → 点击**设置**
3. 点击**配置文件**标签页
4. 在 `server { }` 块内，找到 `location / {` 这一行，**在它的上方**插入以下内容：

```nginx
    # ibookjoy 静态站点
    location /ibookjoy {
        alias /www/wwwroot/ibookjoy;
        index index.html;
        try_files $uri $uri/ $uri/index.html /ibookjoy/index.html;
    }

    location /ibookjoy/ {
        alias /www/wwwroot/ibookjoy/;
        index index.html;
        try_files $uri $uri/ $uri/index.html /ibookjoy/index.html;
    }
```

5. 点击**保存** → 宝塔会自动重载 Nginx

### 方法二：SSH 命令行操作

```bash
# 1. 登录服务器
ssh root@150.158.49.134

# 2. 编辑 Nginx 配置（路径视实际情况可能略有不同）
nano /www/server/panel/vhost/nginx/smartwingtech.com.conf

# 3. 找到 location / { 前面，插入 nginx-ibookjoy.conf 中的内容

# 4. 检查配置语法
nginx -t

# 5. 重载 Nginx（不中断现有连接）
nginx -s reload
```

---

## 后续每次更新部署

代码修改后，只需再次运行：

```bash
./deploy.sh
```

---

## 目录结构参考（服务器端）

```
/www/wwwroot/
├── smartwingtech.com/     ← 原有站点，不动
└── ibookjoy/              ← ibookjoy 静态文件（脚本自动创建并上传）
    ├── index.html
    ├── _next/
    ├── about/
    └── ...
```

---

## 验证

部署完成后，在浏览器访问：

- `https://www.smartwingtech.com/ibookjoy` → 应显示 ibookjoy 首页
- `https://www.smartwingtech.com` → 原有站点保持正常

如果访问出现 404，检查 Nginx 配置中 `alias` 路径是否与 `REMOTE_DIR` 一致。

---

## 常见问题

### 静态资源 404（CSS/JS 加载失败）

确认 `next.config.ts` 中有 `basePath: '/ibookjoy'`，并且是在修改后重新 build 的。

### 子页面刷新 404

确认 Nginx 配置中包含了 `try_files $uri $uri/ $uri/index.html /ibookjoy/index.html;`。

### 权限问题

```bash
# 在服务器上确保 www 用户可读
chmod -R 755 /www/wwwroot/ibookjoy
chown -R www:www /www/wwwroot/ibookjoy
```
