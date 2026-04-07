# Docker 部署指南

## 🚀 快速开始

### 1. 配置环境变量

```bash
cp .env.example .env
nano .env
```

**必须配置：**
```bash
# 数据库密码（生产环境请修改）
POSTGRES_PASSWORD=your_strong_password

# 至少一个 AI API Key
OPENAI_API_KEY=sk-...
# 或
ANTHROPIC_API_KEY=sk-ant-...
```

### 2. 启动服务

```bash
# 方式 1: 使用部署脚本
./deploy.sh

# 方式 2: 使用 Makefile
make setup && make build && make up

# 方式 3: 使用 docker-compose
docker-compose up -d
```

### 3. 访问应用

- **应用**: http://localhost:3000
- **数据库**: localhost:5432

## 🛠️ 常用命令

```bash
make help       # 查看所有命令
make up         # 启动服务
make down       # 停止服务
make logs       # 查看日志
make backup     # 备份数据库
make restart    # 重启服务
```

## 📝 环境变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `POSTGRES_PASSWORD` | 数据库密码 | postgres |
| `APP_PORT` | 应用端口 | 3000 |
| `POSTGRES_PORT` | 数据库端口 | 5432 |
| `OPENAI_API_KEY` | OpenAI API Key | - |
| `ANTHROPIC_API_KEY` | Anthropic API Key | - |

完整配置请查看 `.env.example` 文件。
