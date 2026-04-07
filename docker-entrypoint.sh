#!/bin/sh
set -e

echo "🚀 启动 Chatbot UI..."

# 等待数据库就绪
echo "⏳ 等待数据库连接..."
until pg_isready -h postgres -U postgres; do
  echo "数据库未就绪，等待中..."
  sleep 2
done

echo "✅ 数据库已就绪"

# 启动应用
echo "🎉 启动 Next.js 应用..."
exec node server.js
