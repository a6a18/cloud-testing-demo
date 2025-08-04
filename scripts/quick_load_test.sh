#!/bin/bash

# 快速負載平衡測試

echo "⚖️  快速負載平衡測試"
echo "=================="

# 檢查環境
if ! curl -f http://localhost/health > /dev/null 2>&1; then
    echo "❌ 環境未運行"
    exit 1
fi

echo "📊 發送 20 個請求測試負載平衡..."
echo ""

declare -A node_counts

for i in {1..20}; do
    node_id=$(curl -s -H "Authorization: Bearer test_token_123" \
                  http://localhost/api/v1/users | python -c "import sys, json; print(json.load(sys.stdin)['node_id'])")
    echo "請求 $i: 節點 $node_id"
    
    if [ -z "${node_counts[$node_id]}" ]; then
        node_counts[$node_id]=1
    else
        node_counts[$node_id]=$((${node_counts[$node_id]} + 1))
    fi
done

echo ""
echo "📊 負載平衡統計:"
total_nodes=${#node_counts[@]}

if [ $total_nodes -eq 1 ]; then
    echo "⚠️  單節點環境 - 建議擴展到多個節點"
    node_id=$(echo "${!node_counts[@]}" | tr ' ' '\n' | head -1)
    echo "節點 $node_id: 20 請求 (100%)"
    echo ""
    echo "💡 運行以下命令啟用多節點:"
    echo "   docker-compose up -d --scale api=3"
else
    echo "✅ 多節點負載平衡檢測到 $total_nodes 個節點"
    for node_id in "${!node_counts[@]}"; do
        percentage=$(echo "scale=1; ${node_counts[$node_id]} * 100 / 20" | bc 2>/dev/null || echo "0")
        echo "節點 $node_id: ${node_counts[$node_id]} 請求 ($percentage%)"
    done
fi

echo ""
echo "✅ 測試完成！" 