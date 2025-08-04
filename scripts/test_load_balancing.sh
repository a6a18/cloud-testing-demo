#!/bin/bash

# 負載平衡測試腳本

set -e

echo "⚖️  負載平衡測試腳本"
echo "=================="

# 檢查環境是否運行
if ! curl -f http://localhost/health > /dev/null 2>&1; then
    echo "❌ 環境未運行，請先啟動環境"
    exit 1
fi

echo "📊 當前服務狀態:"
docker-compose ps

echo ""
echo "請選擇測試類型:"
echo "1) 快速測試 (10 個請求)"
echo "2) 標準測試 (50 個請求)"
echo "3) 壓力測試 (100 個請求)"
echo "4) 持續監控 (每5秒測試一次)"
echo "0) 退出"
echo ""

read -p "請輸入選項 (0-4): " choice

case $choice in
    1)
        total_requests=10
        echo "🚀 快速測試 (10 個請求)..."
        ;;
    2)
        total_requests=50
        echo "📊 標準測試 (50 個請求)..."
        ;;
    3)
        total_requests=100
        echo "🔥 壓力測試 (100 個請求)..."
        ;;
    4)
        echo "📈 持續監控模式 (按 Ctrl+C 停止)..."
        while true; do
            echo ""
            echo "🕐 $(date '+%H:%M:%S') - 執行測試..."
            
            declare -A node_counts
            for i in {1..20}; do
                node_id=$(curl -s -H "Authorization: Bearer test_token_123" \
                              http://localhost/api/v1/users | python -c "import sys, json; print(json.load(sys.stdin)['node_id'])")
                
                if [ -z "${node_counts[$node_id]}" ]; then
                    node_counts[$node_id]=1
                else
                    node_counts[$node_id]=$((${node_counts[$node_id]} + 1))
                fi
            done
            
            echo "📊 節點分發統計:"
            for node_id in "${!node_counts[@]}"; do
                percentage=$(echo "scale=1; ${node_counts[$node_id]} * 100 / 20" | bc 2>/dev/null || echo "50")
                echo "  節點 $node_id: ${node_counts[$node_id]} 請求 ($percentage%)"
            done
            
            sleep 5
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

if [ $choice -ge 1 ] && [ $choice -le 3 ]; then
    echo ""
    echo "🔄 發送 $total_requests 個請求..."
    
    declare -A node_counts
    start_time=$(date +%s)
    
    for i in $(seq 1 $total_requests); do
        node_id=$(curl -s -H "Authorization: Bearer test_token_123" \
                      http://localhost/api/v1/users | python -c "import sys, json; print(json.load(sys.stdin)['node_id'])")
        
        if [ -z "${node_counts[$node_id]}" ]; then
            node_counts[$node_id]=1
        else
            node_counts[$node_id]=$((${node_counts[$node_id]} + 1))
        fi
        
        # 顯示進度
        if [ $((i % 10)) -eq 0 ]; then
            echo "   進度: $i/$total_requests"
        fi
    done
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo ""
    echo "📊 測試結果:"
    echo "   總請求數: $total_requests"
    echo "   測試時間: ${duration}秒"
    echo "   平均響應時間: $(echo "scale=2; $duration / $total_requests" | bc)秒"
    echo ""
    echo "🎯 節點分發統計:"
    
    total_nodes=${#node_counts[@]}
    if [ $total_nodes -eq 1 ]; then
        echo "   ⚠️  檢測到單節點環境"
        node_id=$(echo "${!node_counts[@]}" | tr ' ' '\n' | head -1)
        echo "   節點 $node_id: $total_requests 請求 (100%)"
        echo ""
        echo "💡 建議: 運行 'docker-compose up -d --scale api=3' 來啟用多節點負載平衡"
    else
        echo "   ✅ 檢測到多節點負載平衡"
        for node_id in "${!node_counts[@]}"; do
            percentage=$(echo "scale=1; ${node_counts[$node_id]} * 100 / $total_requests" | bc 2>/dev/null || echo "0")
            echo "   節點 $node_id: ${node_counts[$node_id]} 請求 ($percentage%)"
        done
        
        # 計算分發均勻性
        ideal_percentage=$(echo "scale=1; 100 / $total_nodes" | bc)
        echo ""
        echo "📈 負載平衡分析:"
        echo "   理想分發: 每個節點 $ideal_percentage%"
        echo "   實際節點數: $total_nodes"
        
        # 檢查分發是否相對均勻
        max_count=0
        min_count=$total_requests
        for count in "${node_counts[@]}"; do
            if [ $count -gt $max_count ]; then
                max_count=$count
            fi
            if [ $count -lt $min_count ]; then
                min_count=$count
            fi
        done
        
        if [ $max_count -eq $min_count ]; then
            echo "   🎉 完美負載平衡！"
        elif [ $((max_count - min_count)) -le 2 ]; then
            echo "   ✅ 良好的負載平衡"
        else
            echo "   ⚠️  負載分發不均勻"
        fi
    fi
fi

echo ""
echo "✅ 測試完成！"
echo ""
echo "📋 其他測試命令:"
echo "  - 擴展節點: docker-compose up -d --scale api=3"
echo "  - 查看日誌: docker-compose logs -f"
echo "  - 運行自動化測試: docker-compose run tests" 