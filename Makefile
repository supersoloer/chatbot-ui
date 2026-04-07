.PHONY: help build up down restart logs clean backup restore dev prod

# 默认目标
help:
	@echo "Chatbot UI - Docker 管理命令"
	@echo ""
	@echo "使用方法: make [命令]"
	@echo ""
	@echo "可用命令:"
	@echo "  make setup      - 初始化环境（首次使用）"
	@echo "  make build      - 构建 Docker 镜像"
	@echo "  make up         - 启动所有服务（简化版）"
	@echo "  make up-full    - 启动所有服务（完整版含 Kong）"
	@echo "  make down       - 停止所有服务"
	@echo "  make restart    - 重启所有服务"
	@echo "  make logs       - 查看日志"
	@echo "  make logs-app   - 查看应用日志"
	@echo "  make logs-db    - 查看数据库日志"
	@echo "  make ps         - 查看服务状态"
	@echo "  make clean      - 清理容器和镜像"
	@echo "  make backup     - 备份数据库"
	@echo "  make restore    - 恢复数据库"
	@echo "  make dev        - 启动开发环境"
	@echo "  make prod       - 启动生产环境（简化版）"
	@echo "  make shell      - 进入应用容器"
	@echo "  make db-shell   - 进入数据库"
	@echo "  make rebuild    - 重新构建并启动"

# 初始化环境
setup:
	@echo "📝 初始化环境..."
	@if [ ! -f .env ]; then \
		cp .env.simple .env; \
		echo "✅ 已创建 .env 文件（简化版）"; \
		echo "⚠️  请编辑 .env 文件，配置必要的 API Keys"; \
		echo "💡 提示: 如需完整版（含 Supabase），使用 .env.docker"; \
	else \
		echo "⚠️  .env 文件已存在"; \
	fi

# 构建镜像
build:
	@echo "🔨 构建 Docker 镜像..."
	docker-compose build

# 启动服务（简化版 - 推荐）
up:
	@echo "🚀 启动服务（简化版：Next.js + PostgreSQL）..."
	docker-compose -f docker-compose.simple.yml up -d
	@echo "✅ 服务已启动"
	@echo "📍 访问地址: http://localhost:3000"

# 启动服务（完整版 - 含 Kong Gateway）
up-full:
	@echo "🚀 启动服务（完整版：含 Kong Gateway）..."
	docker-compose up -d
	@echo "✅ 服务已启动"
	@echo "📍 访问地址: http://localhost:3000"
	@echo "📍 API Gateway: http://localhost:8000"

# 停止服务
down:
	@echo "🛑 停止服务..."
	@docker-compose -f docker-compose.simple.yml down 2>/dev/null || true
	@docker-compose down 2>/dev/null || true

# 重启服务
restart:
	@echo "🔄 重启服务..."
	docker-compose restart

# 查看日志
logs:
	@docker-compose -f docker-compose.simple.yml logs -f 2>/dev/null || docker-compose logs -f

# 查看应用日志
logs-app:
	@docker-compose -f docker-compose.simple.yml logs -f app 2>/dev/null || docker-compose logs -f app

# 查看数据库日志
logs-db:
	@docker-compose -f docker-compose.simple.yml logs -f postgres 2>/dev/null || docker-compose logs -f postgres

# 查看服务状态
ps:
	@docker-compose -f docker-compose.simple.yml ps 2>/dev/null || docker-compose ps

# 清理
clean:
	@echo "🧹 清理容器和镜像..."
	docker-compose down -v
	docker system prune -f

# 备份数据库
backup:
	@echo "💾 备份数据库..."
	@mkdir -p backups
	@docker-compose exec -T postgres pg_dump -U postgres chatbotui | gzip > backups/backup_$$(date +%Y%m%d_%H%M%S).sql.gz
	@echo "✅ 备份完成: backups/backup_$$(date +%Y%m%d_%H%M%S).sql.gz"

# 恢复数据库
restore:
	@echo "📥 恢复数据库..."
	@if [ -z "$(FILE)" ]; then \
		echo "❌ 错误: 请指定备份文件"; \
		echo "使用方法: make restore FILE=backups/backup_xxx.sql.gz"; \
		exit 1; \
	fi
	@gunzip -c $(FILE) | docker-compose exec -T postgres psql -U postgres chatbotui
	@echo "✅ 恢复完成"

# 开发环境
dev:
	@echo "💻 启动开发环境..."
	docker-compose -f docker-compose.dev.yml up

# 生产环境
prod: build up

# 进入应用容器
shell:
	docker-compose exec app sh

# 进入数据库
db-shell:
	docker-compose exec postgres psql -U postgres chatbotui

# 重新构建并启动
rebuild:
	@echo "🔨 重新构建..."
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d
	@echo "✅ 重新构建完成"

# 查看资源使用
stats:
	docker stats chatbot-app chatbot-postgres

# 更新应用
update:
	@echo "🔄 更新应用..."
	git pull
	docker-compose build
	docker-compose up -d
	@echo "✅ 更新完成"
