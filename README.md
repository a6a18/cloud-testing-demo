# 本地 Docker 雲端測試模擬環境

這是一個基於 Docker 與 docker-compose 的本地模擬雲端測試環境，幫助測試工程師在不使用真實雲服務的情況下，熟悉並練習雲端測試核心流程。

## 🏗️ 架構概覽

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx LB      │    │   API Node 1    │    │   API Node 2    │
│   (Port 80)     │◄──►│   (Port 5000)   │    │   (Port 5001)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   API Node N    │
                    │   (Port 500N)   │
                    └─────────────────┘
```

## 🚀 快速開始

### 前置需求

- Docker Desktop
- Docker Compose
- Git

### 安裝與啟動

1. **克隆項目**
```bash
git clone https://github.com/a6a18/cloud-testing-demo.git
cd cloud-testing-demo
```

2. **啟動環境**
```bash
# 啟動所有服務
docker-compose up -d

# 查看服務狀態
docker-compose ps
```

3. **驗證環境**
```bash
# 檢查健康狀態
curl http://localhost/health

# 檢查 API 狀態
curl http://localhost/api/v1/status
```

## 📋 功能特性

### ✅ 核心功能

- **F1: 多節點 API 服務** - Flask 微服務，支援多節點部署
- **F2: 負載平衡器** - Nginx 負載平衡，支援健康檢查
- **F3: IAM 權限模擬** - Token 認證，角色權限管理
- **F4: 簡易 Auto Scaling** - docker-compose scale 擴容
- **F5: 自動化測試腳本** - pytest 完整測試套件
- **F6: Failover 測試支援** - 故障轉移與高可用測試

### 🔧 API 端點

| 端點 | 方法 | 認證 | 說明 |
|------|------|------|------|
| `/health` | GET | ❌ | 健康檢查 |
| `/api/v1/status` | GET | ❌ | 服務狀態 |
| `/api/v1/users` | GET | ✅ | 獲取用戶列表 |
| `/api/v1/users` | POST | ✅ | 創建新用戶 |
| `/api/v1/users/{id}` | DELETE | ✅ | 刪除用戶 |
| `/api/v1/error-test` | GET | ❌ | 錯誤測試 |

### 🔑 認證 Token

| Token | 角色 | 權限 |
|-------|------|------|
| `test_token_123` | admin | read, write, delete |
| `user_token_456` | user | read |
| `guest_token_789` | guest | read |
| `invalid_token_999` | invalid | 無權限 |

## 🧪 測試指南

### 運行測試

```bash
# 運行所有測試
docker-compose run tests

# 運行特定測試類別
docker-compose run tests pytest test_api.py::TestAPIAuthentication -v

# 生成 HTML 報告
docker-compose run tests pytest --html=report.html --self-contained-html
```

### 測試類別

1. **認證測試** (`TestAPIAuthentication`)
   - Token 驗證
   - 權限檢查
   - 無認證訪問

2. **用戶管理測試** (`TestAPIUserManagement`)
   - 創建用戶
   - 刪除用戶
   - 權限控制

3. **負載平衡測試** (`TestAPILoadBalancing`)
   - 請求分發
   - 並發處理

4. **故障轉移測試** (`TestAPIFailover`)
   - 錯誤處理
   - 超時測試

5. **性能測試** (`TestAPIPerformance`)
   - 響應時間
   - 健康檢查性能

6. **安全性測試** (`TestAPISecurity`)
   - SQL 注入防護
   - XSS 防護

## 🔄 擴容與縮容

### 手動擴容

```bash
# 擴展到 3 個 API 節點
docker-compose up -d --scale api=3

# 擴展到 5 個 API 節點
docker-compose up -d --scale api=5
```

### 查看擴容效果

```bash
# 快速測試負載平衡
./scripts/quick_load_test.sh

# 詳細測試負載平衡
./scripts/test_load_balancing.sh

# 手動測試節點分發
for i in {1..10}; do
  node_id=$(curl -s -H "Authorization: Bearer test_token_123" \
                http://localhost/api/v1/users | python -c "import sys, json; print(json.load(sys.stdin)['node_id'])")
  echo "請求 $i: 節點 $node_id"
done
```

## 🛠️ 故障測試

### 模擬節點故障

```bash
# 停止某個 API 節點
docker-compose stop api_1

# 檢查負載平衡器是否自動轉移流量
curl http://localhost/health

# 重啟節點
docker-compose start api_1
```

### 測試錯誤處理

```bash
# 測試 404 錯誤
curl "http://localhost/api/v1/error-test?type=404"

# 測試 500 錯誤
curl "http://localhost/api/v1/error-test?type=500"

# 測試超時
curl "http://localhost/api/v1/error-test?type=timeout"
```

## 📊 監控與日誌

### 查看日誌

```bash
# 查看所有服務日誌
docker-compose logs

# 查看特定服務日誌
docker-compose logs api
docker-compose logs nginx

# 實時日誌
docker-compose logs -f
```

### 性能監控

```bash
# 查看容器資源使用
docker stats

# 查看網絡連接
docker network ls
docker network inspect cloud-testing_cloud-testing-network
```

## 🔧 配置說明

### 環境變數

| 變數 | 預設值 | 說明 |
|------|--------|------|
| `FLASK_ENV` | development | Flask 環境 |
| `NODE_ID` | 1 | API 節點 ID |
| `API_BASE_URL` | http://nginx | 測試 API 基礎 URL |
| `TEST_TOKEN` | test_token_123 | 測試用 Token |

### 端口映射

| 服務 | 容器端口 | 主機端口 | 說明 |
|------|----------|----------|------|
| Nginx | 80 | 80 | 負載平衡器 |
| API | 5000 | 內部網絡 | API 服務（通過Nginx訪問） |

## 🚨 故障排除

### 常見問題

1. **端口衝突**
```bash
# 檢查端口使用
netstat -tulpn | grep :80

# 修改 docker-compose.yml 中的端口映射
```

2. **負載平衡測試失敗**
```bash
# 確保有多個API節點
docker-compose up -d --scale api=3

# 使用提供的測試腳本
./scripts/quick_load_test.sh
```

2. **容器啟動失敗**
```bash
# 查看詳細錯誤
docker-compose logs api
docker-compose logs nginx

# 重新構建
docker-compose build --no-cache
docker-compose up -d
```

3. **測試失敗**
```bash
# 檢查服務是否正常運行
docker-compose ps

# 檢查網絡連接
docker-compose exec tests ping nginx

# 查看詳細錯誤日誌
docker-compose logs api
docker-compose logs nginx
```

## 📚 學習資源

### 雲端測試概念

- **負載平衡** - 分散請求到多個服務器
- **健康檢查** - 監控服務可用性
- **故障轉移** - 自動切換到備用節點
- **權限管理** - IAM 角色與權限控制
- **自動擴容** - 根據負載自動調整資源

### 相關技術

- **Docker** - 容器化技術
- **Nginx** - 負載平衡器
- **Flask** - Python Web 框架
- **pytest** - Python 測試框架
- **微服務架構** - 分散式系統設計

## 🤝 貢獻指南

歡迎提交 Issue 和 Pull Request！

### 開發環境設置

```bash
# 安裝開發依賴
pip install -r tests/requirements.txt

# 本地運行測試
pytest tests/test_api.py -v
```

## 📄 授權

MIT License

---

**注意**: 這是一個教學用的模擬環境，不適用於生產環境。 
