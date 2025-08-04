#!/bin/bash

# 本地 Docker 雲端測試模擬環境擴容腳本

set -e

echo "📈 本地 Docker 雲端測試模擬環境擴容腳本"
echo ""

# 檢查環境是否運行
if ! curl -f http://localhost/health > /dev/null 2>&1; then
    echo "❌ 環境未運行，請先執行 ./scripts/start.sh"
    exit 1
fi

# 顯示當前狀態
echo "📊 當前服務狀態:"
docker-compose ps

echo ""
echo "請選擇擴容選項:"
echo "1) 擴展到 2 個 API 節點"
echo "2) 擴展到 3 個 API 節點"
echo "3) 擴展到 5 個 API 節點"
echo "4) 擴展到 10 個 API 節點"
echo "5) 縮容到 1 個 API 節點"
echo "6) 查看負載平衡效果"
echo "7) 模擬節點故障"
echo "0) 退出"
echo ""

read -p "請輸入選項 (0-7): " choice

case $choice in
    1)
        echo "🔄 擴展到 2 個 API 節點..."
        docker-compose up -d --scale api=2
        ;;
    2)
        echo "🔄 擴展到 3 個 API 節點..."
        docker-compose up -d --scale api=3
        ;;
    3)
        echo "🔄 擴展到 5 個 API 節點..."
        docker-compose up -d --scale api=5
        ;;
    4)
        echo "🔄 擴展到 10 個 API 節點..."
        docker-compose up -d --scale api=10
        ;;
    5)
        echo "📉 縮容到 1 個 API 節點..."
        docker-compose up -d --scale api=1
        ;;
    6)
        echo "⚖️ 測試負載平衡分發..."
        echo "發送 20 個請求並統計節點分發:"
        echo ""
        
        declare -A node_counts
        total_requests=20
        
        for i in $(seq 1 $total_requests); do
            node_id=$(curl -s -H "Authorization: Bearer test_token_123" \
                          http://localhost/api/v1/users | jq -r '.node_id')
            echo "請求 $i: 節點 $node_id"
            
            if [ -z "${node_counts[$node_id]}" ]; then
                node_counts[$node_id]=1
            else
                node_counts[$node_id]=$((${node_counts[$node_id]} + 1))
            fi
        done
        
        echo ""
        echo "📊 負載平衡統計:"
        for node_id in "${!node_counts[@]}"; do
            percentage=$(echo "scale=1; ${node_counts[$node_id]} * 100 / $total_requests" | bc)
            echo "節點 $node_id: ${node_counts[$node_id]} 請求 ($percentage%)"
        done
        ;;
    7)
        echo "🛠️ 模擬節點故障..."
        echo "停止第一個 API 節點..."
        docker-compose stop cloud-testing_api_1 2>/dev/null || docker-compose stop cloud-testing-api-1 2>/dev/null || echo "無法停止特定節點，嘗試停止所有 API 節點..."
        
        echo "等待 5 秒..."
        sleep 5
        
        echo "測試健康檢查..."
        if curl -f http://localhost/health > /dev/null 2>&1; then
            echo "✅ 服務仍然可用"
        else
            echo "❌ 服務不可用"
        fi
        
        echo "重啟 API 節點..."
        docker-compose start api
        ;;
    0)
        echo "👋 退出擴容測試"
        exit 0
        ;;
    *)
        echo "❌ 無效選項"
        exit 1
        ;;
esac

if [ $choice -ge 1 ] && [ $choice -le 5 ]; then
    echo ""
    echo "⏳ 等待服務啟動..."
    sleep 5
    
    echo "📊 更新後的服務狀態:"
    docker-compose ps
    
    echo ""
    echo "🏥 健康檢查:"
    if curl -f http://localhost/health > /dev/null 2>&1; then
        echo "✅ 所有服務正常運行"
    else
        echo "❌ 服務異常，請檢查日誌: docker-compose logs"
    fi
fi

echo ""
echo "✅ 擴容操作完成！"
echo ""
echo "📋 常用命令:"
echo "  - 查看日誌: docker-compose logs -f"
echo "  - 查看狀態: docker-compose ps"
echo "  - 停止環境: docker-compose down"
echo "  - 運行測試: ./scripts/test.sh" 