# 項目結構說明

```
cloud-testing/
├── 📁 api/                          # Flask API 微服務
│   ├── 📄 app.py                    # 主要 API 應用程式
│   ├── 📄 requirements.txt          # Python 依賴
│   └── 📄 Dockerfile               # API 容器配置
│
├── 📁 nginx/                        # Nginx 負載平衡器
│   └── 📄 nginx.conf               # Nginx 配置
│
├── 📁 tests/                        # 自動化測試套件
│   ├── 📄 test_api.py              # API 測試腳本
│   ├── 📄 requirements.txt          # 測試依賴
│   └── 📄 Dockerfile               # 測試容器配置
│
├── 📁 scripts/                      # 實用腳本
│   ├── 📄 start.sh                 # 環境啟動腳本
│   ├── 📄 test.sh                  # 測試運行腳本
│   └── 📄 scale.sh                 # 擴容測試腳本
│
├── 📄 docker-compose.yml           # 多容器編排配置
├── 📄 README.md                    # 項目說明文件
├── 📄 demo.sh                      # 完整演示腳本
├── 📄 .gitignore                   # Git 忽略文件
└── 📄 PROJECT_STRUCTURE.md         # 本文件
```

## 核心組件說明

### 🐳 Docker 配置
- **docker-compose.yml**: 定義多容器服務編排
  - API 服務 (可擴展)
  - Nginx 負載平衡器
  - 測試服務

### 🔧 API 服務 (api/)
- **app.py**: Flask 應用程式
  - IAM 權限模擬
  - 用戶管理 API
  - 健康檢查端點
  - 錯誤測試端點

### ⚖️ 負載平衡器 (nginx/)
- **nginx.conf**: Nginx 配置
  - 負載平衡算法
  - 健康檢查
  - 故障轉移
  - 日誌記錄

### 🧪 測試套件 (tests/)
- **test_api.py**: 完整測試套件
  - 認證測試
  - 功能測試
  - 負載平衡測試
  - 故障轉移測試
  - 性能測試
  - 安全性測試

### 📜 腳本工具 (scripts/)
- **start.sh**: 一鍵啟動環境
- **test.sh**: 互動式測試選擇
- **scale.sh**: 擴容與故障測試

## 技術棧

| 組件 | 技術 | 用途 |
|------|------|------|
| API 服務 | Flask + Python | 微服務後端 |
| 負載平衡器 | Nginx | 請求分發與健康檢查 |
| 容器化 | Docker | 環境隔離與部署 |
| 編排 | Docker Compose | 多容器管理 |
| 測試框架 | pytest | 自動化測試 |
| 腳本語言 | Bash | 自動化腳本 |

## 學習目標

### 🎯 雲端測試核心概念
1. **微服務架構** - 分散式系統設計
2. **負載平衡** - 請求分發與高可用
3. **健康檢查** - 服務監控與故障檢測
4. **故障轉移** - 自動恢復與容錯
5. **權限管理** - IAM 角色與訪問控制
6. **自動擴容** - 動態資源調整

### 🔧 技術技能
1. **Docker** - 容器化技術
2. **Nginx** - 負載平衡器配置
3. **Flask** - Python Web 框架
4. **pytest** - 測試框架
5. **API 測試** - RESTful API 測試
6. **CI/CD** - 持續整合與部署

## 使用流程

1. **環境啟動** → `./scripts/start.sh`
2. **功能測試** → `./scripts/test.sh`
3. **擴容測試** → `./scripts/scale.sh`
4. **完整演示** → `./demo.sh`
5. **環境清理** → `docker-compose down`

## 擴展建議

### 🚀 進階功能
- [ ] 添加數據庫服務 (PostgreSQL/MySQL)
- [ ] 實現 Redis 緩存
- [ ] 添加消息隊列 (RabbitMQ)
- [ ] 實現服務發現 (Consul)
- [ ] 添加監控系統 (Prometheus + Grafana)
- [ ] 實現 CI/CD 流水線

### 🧪 測試增強
- [ ] 添加壓力測試 (Locust)
- [ ] 實現端到端測試 (Selenium)
- [ ] 添加安全掃描 (OWASP ZAP)
- [ ] 實現 API 文檔生成 (Swagger)

### 📊 監控與日誌
- [ ] 集中化日誌 (ELK Stack)
- [ ] 應用性能監控 (APM)
- [ ] 告警系統
- [ ] 儀表板 (Grafana) 