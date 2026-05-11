#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PARENT_DIR="$(dirname "$PROJECT_DIR")"

# 加载环境变量
source "$PROJECT_DIR/.env"

DATE=$(date +%Y%m%d_%H%M%S)
TMP_DIR="/tmp/backup_$DATE"
BACKUP_FILE="/tmp/backup_$DATE.tar.gz"

echo "[$(date)] 开始备份..."

# 创建临时目录，存放 mysqldump
mkdir -p "$TMP_DIR"

# MySQL 全量导出
echo "[$(date)] 导出 MySQL..."
docker exec mysql mysqldump \
  -uroot -p"$MYSQL_ROOT_PASSWORD" \
  --all-databases \
  --single-transaction \
  > "$TMP_DIR/mysql.sql"

# 打包 data 目录 + mysqldump
echo "[$(date)] 打包数据..."
tar -czf "$BACKUP_FILE" \
  -C "$PARENT_DIR" data \
  -C /tmp "backup_$DATE"

# 配置 rclone 连接 R2（通过环境变量，无需 config 文件）
export RCLONE_CONFIG_R2_TYPE=s3
export RCLONE_CONFIG_R2_PROVIDER=Cloudflare
export RCLONE_CONFIG_R2_ACCESS_KEY_ID="$R2_ACCESS_KEY_ID"
export RCLONE_CONFIG_R2_SECRET_ACCESS_KEY="$R2_SECRET_ACCESS_KEY"
export RCLONE_CONFIG_R2_ENDPOINT="https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com"
export RCLONE_CONFIG_R2_ACL=private

# 上传到 R2
echo "[$(date)] 上传到 R2..."
rclone copy "$BACKUP_FILE" "r2:${R2_BUCKET}/backups/"

# 删除 R2 上 7 天前的备份
echo "[$(date)] 清理旧备份..."
rclone delete "r2:${R2_BUCKET}/backups/" --min-age 7d

# 清理本地临时文件
rm -rf "$TMP_DIR" "$BACKUP_FILE"

echo "[$(date)] 备份完成: backup_$DATE.tar.gz"
