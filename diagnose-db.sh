#!/bin/bash

echo "🔍 PostgreSQL 容器诊断脚本"
echo "================================"

# 查找 PostgreSQL 容器
echo ""
echo "📦 查找 PostgreSQL 容器..."
CONTAINERS=$(docker ps --format "{{.Names}}" | grep -i postgres)

if [ -z "$CONTAINERS" ]; then
    echo "❌ 未找到运行中的 PostgreSQL 容器"
    exit 1
fi

echo "找到以下容器:"
echo "$CONTAINERS"
echo ""

# 让用户选择容器
if [ $(echo "$CONTAINERS" | wc -l) -gt 1 ]; then
    echo "请输入容器名称:"
    read CONTAINER_NAME
else
    CONTAINER_NAME=$CONTAINERS
fi

echo ""
echo "🔧 诊断容器: $CONTAINER_NAME"
echo "================================"

# 1. 查看环境变量
echo ""
echo "1️⃣ 环境变量:"
docker exec $CONTAINER_NAME env | grep POSTGRES || echo "未找到 POSTGRES 相关环境变量"

# 2. 查看运行的进程
echo ""
echo "2️⃣ PostgreSQL 进程:"
docker exec $CONTAINER_NAME ps aux | grep postgres | head -5

# 3. 尝试不同的用户名
echo ""
echo "3️⃣ 尝试连接数据库..."

USERS=("postgres" "admin" "root" "dokploy")

for USER in "${USERS[@]}"; do
    echo -n "尝试用户: $USER ... "
    if docker exec $CONTAINER_NAME psql -U $USER -c "SELECT 1" > /dev/null 2>&1; then
        echo "✅ 成功!"
        WORKING_USER=$USER
        break
    else
        echo "❌ 失败"
    fi
done

if [ -z "$WORKING_USER" ]; then
    echo ""
    echo "❌ 无法使用常见用户名连接"
    echo ""
    echo "💡 建议:"
    echo "1. 检查 Dokploy 创建数据库时的配置"
    echo "2. 查看容器日志: docker logs $CONTAINER_NAME"
    echo "3. 进入容器手动检查: docker exec -it $CONTAINER_NAME bash"
    exit 1
fi

# 4. 列出数据库
echo ""
echo "4️⃣ 当前数据库列表:"
docker exec $CONTAINER_NAME psql -U $WORKING_USER -c "\l"

# 5. 询问是否创建 chatbotui 数据库
echo ""
echo "================================"
echo "✅ 找到可用用户: $WORKING_USER"
echo ""
read -p "是否创建 chatbotui 数据库? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "📝 创建数据库..."
    docker exec $CONTAINER_NAME psql -U $WORKING_USER -c "CREATE DATABASE chatbotui;"

    echo ""
    echo "✅ 数据库创建完成!"
    echo ""
    echo "📋 数据库连接信息:"
    echo "   用户名: $WORKING_USER"
    echo "   数据库: chatbotui"
    echo "   容器名: $CONTAINER_NAME"
    echo ""
    echo "📝 DATABASE_URL 配置:"
    echo "   DATABASE_URL=postgresql://$WORKING_USER:你的密码@$CONTAINER_NAME:5432/chatbotui"
    echo ""

    # 询问是否执行迁移
    read -p "是否执行数据库迁移? (y/n) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "🔄 执行数据库迁移..."

        if [ -d "supabase/migrations" ]; then
            for file in supabase/migrations/*.sql; do
                echo "执行: $(basename $file)"
                docker exec -i $CONTAINER_NAME psql -U $WORKING_USER -d chatbotui < "$file"
            done
            echo ""
            echo "✅ 迁移完成!"
        else
            echo "❌ 未找到 supabase/migrations 目录"
        fi
    fi
fi

echo ""
echo "🎉 诊断完成!"
