#!/bin/bash
# ============================================================
# ibookjoy 部署脚本
# 目标：将静态站点部署到服务器 /ibookjoy 子路径
# 访问地址：https://www.smartwingtech.com/ibookjoy
# ============================================================
set -e

# ── 配置区（按实际情况修改）──────────────────────────────────
SERVER_IP="150.158.49.134"           # 腾讯云轻量服务器
SERVER_USER="root"
REMOTE_DIR="/www/wwwroot/ibookjoy"  # 服务器上静态文件存放目录
SSH_KEY=""                          # 可选：SSH 私钥路径，例如 ~/.ssh/id_rsa
# ─────────────────────────────────────────────────────────────

# 构建 SSH 参数
SSH_CMD="ssh"
RSYNC_SSH="ssh"
if [ -n "$SSH_KEY" ]; then
  SSH_CMD="ssh -i $SSH_KEY"
  RSYNC_SSH="ssh -i $SSH_KEY"
fi

echo "======================================================"
echo " ibookjoy 静态站点部署"
echo " 目标服务器：${SERVER_USER}@${SERVER_IP}:${REMOTE_DIR}"
echo "======================================================"

# 1. 本地构建
echo ""
echo "[1/4] 安装依赖..."
npm install

echo ""
echo "[2/4] 构建静态文件..."
npm run build
echo "✓ 构建完成，静态文件在 out/ 目录"

# 2. 在服务器上创建目标目录
echo ""
echo "[3/4] 在服务器上创建目录 ${REMOTE_DIR}..."
$SSH_CMD ${SERVER_USER}@${SERVER_IP} "mkdir -p ${REMOTE_DIR}"

# 3. 上传文件（rsync 增量同步，--delete 清理服务器上已删除的旧文件）
echo ""
echo "[4/4] 上传静态文件到服务器..."
rsync -avz --delete \
  -e "${RSYNC_SSH}" \
  out/ \
  ${SERVER_USER}@${SERVER_IP}:${REMOTE_DIR}/

echo ""
echo "======================================================"
echo "✓ 部署完成！"
echo ""
echo "后续步骤（首次部署需要手动配置 Nginx）："
echo "  请参考 DEPLOY.md 中的「Nginx 配置」章节"
echo "  配置完成后访问：https://www.smartwingtech.com/ibookjoy"
echo "======================================================"
