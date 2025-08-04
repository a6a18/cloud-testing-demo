#!/bin/bash

# 本地 Docker 雲端測試模擬環境啟動腳本

set -e

echo "🚀 啟動本地 Docker 雲端測試模擬環境..."

# 檢查 Docker 是否運行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未運行，請先啟動 Docker Desktop"
    exit 1
fi

# 檢查 docker-compose 是否可用
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose 未安裝，請先安裝 Docker Compose"
    exit 1
fi

# 構建並啟動服務
echo "📦 構建 Docker 映像..."
docker-compose build

echo "🚀 啟動服務..."
docker-compose up -d

# 等待服務啟動
echo "⏳ 等待服務啟動..."
sleep 10

# 檢查服務狀態
echo "🔍 檢查服務狀態..."
docker-compose ps

# 測試健康檢查
echo "🏥 測試健康檢查..."
if curl -f http://localhost/health > /dev/null 2>&1; then
    echo "✅ 健康檢查通過"
else
    echo "❌ 健康檢查失敗"
    echo "查看日誌: docker-compose logs"
    exit 1
fi

# 測試 API 狀態
echo "📊 測試 API 狀態..."
if curl -f http://localhost/api/v1/status > /dev/null 2>&1; then
    echo "✅ API 狀態檢查通過"
else
    echo "❌ API 狀態檢查失敗"
fi

echo ""
echo "🎉 環境啟動完成！"
echo ""
echo "📋 可用端點:"
echo "  - 健康檢查: http://localhost/health"
echo "  - API 狀態: http://localhost/api/v1/status"
echo "  - 負載平衡器: http://localhost"
echo ""
echo "🧪 運行測試:"
echo "  docker-compose run tests"
echo ""
echo "📊 查看日誌:"
echo "  docker-compose logs -f"
echo ""
echo "🔄 擴容 API 節點:"
echo "  docker-compose up -d --scale api=3"
echo ""
echo "🛑 停止環境:"
echo "  docker-compose down" 