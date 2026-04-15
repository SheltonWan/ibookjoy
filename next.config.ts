import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: 'export',        // 输出纯静态文件到 out/ 目录
  basePath: '/ibookjoy',   // 部署到子路径 /ibookjoy
  trailingSlash: true,     // 生成 about/index.html 而非 about.html，兼容静态服务器
  images: {
    unoptimized: true,     // 静态导出模式下关闭图片优化服务，直接输出原图
  },
};

export default nextConfig;
