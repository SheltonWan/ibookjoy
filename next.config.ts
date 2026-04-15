import type { NextConfig } from "next";

const BASE_PATH = '/ibookjoy';

const nextConfig: NextConfig = {
  output: 'export',        // 输出纯静态文件到 out/ 目录
  basePath: BASE_PATH,     // 部署到子路径 /ibookjoy
  trailingSlash: true,     // 生成 about/index.html 而非 about.html，兼容静态服务器
  images: {
    unoptimized: true,     // 静态导出模式下关闭图片优化服务，直接输出原图
  },
  env: {
    // 将 basePath 暴露给客户端代码，供 site.config.ts 中的 BASE_PATH 使用
    NEXT_PUBLIC_BASE_PATH: BASE_PATH,
  },
};

export default nextConfig;
