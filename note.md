🔧 可用命令：
docker-compose ps - 查看服務狀態
docker-compose logs -f - 查看實時日誌
curl http://localhost/health - 健康檢查
curl http://localhost/api/v1/status - API 狀態
docker-compose up -d --scale api=3 - 擴展 API 節點
