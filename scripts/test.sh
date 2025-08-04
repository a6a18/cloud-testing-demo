#!/bin/bash

# 本地 Docker 雲端測試模擬環境測試腳本

set -e

echo "🧪 本地 Docker 雲端測試模擬環境測試腳本"
echo ""

# 檢查環境是否運行
if ! curl -f http://localhost/health > /dev/null 2>&1; then
    echo "❌ 環境未運行，請先執行 ./scripts/start.sh"
    exit 1
fi

# 顯示測試選項
echo "請選擇測試類型:"
echo "1) 運行所有測試"
echo "2) 認證測試"
echo "3) 用戶管理測試"
echo "4) 負載平衡測試"
echo "5) 故障轉移測試"
echo "6) 性能測試"
echo "7) 安全性測試"
echo "8) 手動 API 測試"
echo "9) 擴容測試"
echo "0) 退出"
echo ""

read -p "請輸入選項 (0-9): " choice

case $choice in
    1)
        echo "🚀 運行所有測試..."
        docker-compose run tests pytest -v --html=report.html --self-contained-html
        ;;
    2)
        echo "🔐 運行認證測試..."
        docker-compose run tests pytest test_api.py::TestAPIAuthentication -v
        ;;
    3)
        echo "👥 運行用戶管理測試..."
        docker-compose run tests pytest test_api.py::TestAPIUserManagement -v
        ;;
    4)
        echo "⚖️ 運行負載平衡測試..."
        docker-compose run tests pytest test_api.py::TestAPILoadBalancing -v
        ;;
    5)
        echo "🔄 運行故障轉移測試..."
        docker-compose run tests pytest test_api.py::TestAPIFailover -v
        ;;
    6)
        echo "⚡ 運行性能測試..."
        docker-compose run tests pytest test_api.py::TestAPIPerformance -v
        ;;
    7)
        echo "🔒 運行安全性測試..."
        docker-compose run tests pytest test_api.py::TestAPISecurity -v
        ;;
    8)
        echo "🔧 手動 API 測試..."
        echo ""
        echo "測試健康檢查:"
        curl -s http://localhost/health | jq .
        echo ""
        echo "測試 API 狀態:"
        curl -s http://localhost/api/v1/status | jq .
        echo ""
        echo "測試用戶列表 (需要認證):"
        curl -s -H "Authorization: Bearer test_token_123" \
             http://localhost/api/v1/users | jq .
        echo ""
        echo "測試創建用戶:"
        curl -s -X POST \
             -H "Authorization: Bearer test_token_123" \
             -H "Content-Type: application/json" \
             -d '{"name": "測試用戶", "email": "test@example.com"}' \
             http://localhost/api/v1/users | jq .
        ;;
    9)
        echo "📈 擴容測試..."
        echo "擴展到 3 個 API 節點..."
        docker-compose up -d --scale api=3
        sleep 5
        echo "測試負載平衡分發..."
        for i in {1..10}; do
            node_id=$(curl -s -H "Authorization: Bearer test_token_123" \
                          http://localhost/api/v1/users | jq -r '.node_id')
            echo "請求 $i: 節點 $node_id"
        done
        ;;
    0)
        echo "👋 退出測試"
        exit 0
        ;;
    *)
        echo "❌ 無效選項"
        exit 1
        ;;
esac

echo ""
echo "✅ 測試完成！"
echo ""
echo "📊 查看測試報告:"
echo "  docker-compose run tests cat report.html"
echo ""
echo "📋 查看日誌:"
echo "  docker-compose logs -f" 