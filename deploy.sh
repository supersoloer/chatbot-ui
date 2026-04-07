#!/bin/bash

echo "🚀 Chatbot UI Docker 部署脚本"
echo "================================"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ 错误: Docker 未安装"
    echo "请先安装 Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ 错误: Docker Compose 未安装"
    exit 1
fi

# 选择部署模式
echo ""
echo "请选择部署模式:"
echo "  1) 简化版 (推荐) - 只包含 Next.js + PostgreSQL"
echo "  2) 完整版 - 包含 Supabase + Kong Gateway"
echo ""
read -p "请输入选择 (1/2) [默认: 1]: " -n 1 -r
echo ""

DEPLOY_MODE=${REPLY:-1}

if [ "$DEPLOY_MODE" = "1" ]; then
    COMPOSE_FILE="docker-compose.simple.yml"
    ENV_FILE=".env.simple"
    echo "✅ 使用简化版部署"
else
    COMPOSE_FILE="docker-compose.yml"
    ENV_FILE=".env.docker"
    echo "✅ 使用完整版部署"
fi

# 检查环境变量文件
if [ ! -f .env ]; then
    echo "📝 创建环境变量文件..."
    cp "$ENV_FILE" .env
    echo "⚠️  请编辑 .env 文件，配置必要的 API Keys"
    echo ""
    read -p "是否现在编辑 .env 文件? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ${EDITOR:-nano} .env
    fi
fi

echo ""
echo "🔨 构建 Docker 镜像..."
docker-compose -f "$COMPOSE_FILE" build

echo ""
echo "🚀 启动服务..."
docker-compose -f "$COMPOSE_FILE" up -d

echo ""
echo "⏳ 等待服务启动..."
sleep 5

# 检查服务状态
echo ""
echo "📊 服务状态:"
docker-compose -f "$COMPOSE_FILE" ps

echo ""
echo "✅ 部署完成!"
echo ""
echo "📍 访问地址:"
echo "   应用: http://localhost:3000"
if [ "$DEPLOY_MODE" = "2" ]; then
    echo "   数据库: localhost:5432"
    echo "   API: http://localhost:8000"
else
    echo "   数据库: localhost:5432"
fi
echo ""
echo "📝 常用命令:"
if [ "$DEPLOY_MODE" = "1" ]; then
    echo "   查看日志: docker-compose -f docker-compose.simple.yml logs -f"
    echo "   停止服务: docker-compose -f docker-compose.simple.yml down"
    echo "   重启服务: docker-compose -f docker-compose.simple.yml restart"
else
    echo "   查看日志: docker-compose logs -f"
    echo "   停止服务: docker-compose down"
    echo "   重启服务: docker-compose restart"
fi
echo ""
echo "💡 提示: 使用 'make help' 查看更多命令"
echo ""
