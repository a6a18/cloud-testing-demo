#!/bin/bash

# 本地 Docker 雲端測試模擬環境完整演示

set -e

echo "🎬 本地 Docker 雲端測試模擬環境完整演示"
echo "=========================================="
echo ""

# 檢查 Docker
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未運行，請先啟動 Docker Desktop"
    exit 1
fi

# 啟動環境
echo "🚀 步驟 1: 啟動環境"
./scripts/start.sh

echo ""
echo "⏳ 等待服務完全啟動..."
sleep 15

# 基本功能演示
echo ""
echo "🔧 步驟 2: 基本功能演示"
echo ""

echo "📊 健康檢查:"
curl -s http://localhost/health | python -m json.tool

echo ""
echo "📋 API 狀態:"
curl -s http://localhost/api/v1/status | python -m json.tool

echo ""
echo "👥 獲取用戶列表 (需要認證):"
curl -s -H "Authorization: Bearer test_token_123" \
     http://localhost/api/v1/users | python -m json.tool

echo ""
echo "➕ 創建新用戶:"
curl -s -X POST \
     -H "Authorization: Bearer test_token_123" \
     -H "Content-Type: application/json" \
     -d '{"name": "Demo User", "email": "demo@example.com"}' \
     http://localhost/api/v1/users | python -m json.tool

# 權限測試演示
echo ""
echo "🔐 步驟 3: 權限測試演示"
echo ""

echo "❌ 無認證訪問 (應該失敗):"
curl -s http://localhost/api/v1/users | python -m json.tool

echo ""
echo "❌ 無效 Token (應該失敗):"
curl -s -H "Authorization: Bearer invalid_token" \
     http://localhost/api/v1/users | python -m json.tool

echo ""
echo "❌ 用戶權限創建用戶 (應該失敗):"
curl -s -X POST \
     -H "Authorization: Bearer user_token_456" \
     -H "Content-Type: application/json" \
     -d '{"name": "Test User"}' \
     http://localhost/api/v1/users | python -m json.tool

# 擴容演示
echo ""
echo "📈 步驟 4: 擴容演示"
echo ""

echo "🔄 擴展到 3 個 API 節點..."
docker-compose up -d --scale api=3
sleep 10

echo "⚖️ 測試負載平衡分發 (10 個請求):"
for i in {1..10}; do
    node_id=$(curl -s -H "Authorization: Bearer test_token_123" \
                  http://localhost/api/v1/users | python -c "import sys, json; print(json.load(sys.stdin)['node_id'])")
    echo "請求 $i: 節點 $node_id"
done

# 故障測試演示
echo ""
echo "🛠️ 步驟 5: 故障測試演示"
echo ""

echo "🔍 測試錯誤端點:"
echo "404 錯誤:"
curl -s "http://localhost/api/v1/error-test?type=404" | python -m json.tool

echo ""
echo "500 錯誤:"
curl -s "http://localhost/api/v1/error-test?type=500" | python -m json.tool

# 自動化測試
echo ""
echo "🧪 步驟 6: 自動化測試"
echo ""

echo "運行認證測試..."
docker-compose run tests pytest test_api.py::TestAPIAuthentication -v

echo ""
echo "運行負載平衡測試..."
docker-compose run tests pytest test_api.py::TestAPILoadBalancing -v

echo ""
echo "運行性能測試..."
docker-compose run tests pytest test_api.py::TestAPIPerformance -v

# 總結
echo ""
echo "🎉 演示完成！"
echo ""
echo "📋 環境信息:"
echo "  - 負載平衡器: http://localhost"
echo "  - 健康檢查: http://localhost/health"
echo "  - API 狀態: http://localhost/api/v1/status"
echo ""
echo "🔧 可用命令:"
echo "  - 運行完整測試: ./scripts/test.sh"
echo "  - 擴容測試: ./scripts/scale.sh"
echo "  - 查看日誌: docker-compose logs -f"
echo "  - 停止環境: docker-compose down"
echo ""
echo "📚 學習重點:"
echo "  - 微服務架構與負載平衡"
echo "  - API 認證與權限管理"
echo "  - 故障轉移與高可用性"
echo "  - 自動化測試與 CI/CD"
echo "  - Docker 容器化與編排" 