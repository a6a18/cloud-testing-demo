from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import time
import random
import logging
from functools import wraps

app = Flask(__name__)
CORS(app)

# 配置日誌
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 模擬 IAM 權限管理
VALID_TOKENS = {
    'test_token_123': {'role': 'admin', 'permissions': ['read', 'write', 'delete']},
    'user_token_456': {'role': 'user', 'permissions': ['read']},
    'guest_token_789': {'role': 'guest', 'permissions': ['read']}
}

def verify_token(token):
    """驗證 API Token"""
    if not token:
        return False, "缺少認證 Token"
    
    if token not in VALID_TOKENS:
        return False, "無效的 Token"
    
    return True, VALID_TOKENS[token]

def require_auth(f):
    """認證裝飾器"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = request.headers.get('Authorization', '').replace('Bearer ', '')
        is_valid, result = verify_token(token)
        
        if not is_valid:
            return jsonify({'error': result}), 401
        
        request.user_info = result
        return f(*args, **kwargs)
    return decorated_function

@app.route('/health', methods=['GET'])
def health_check():
    """健康檢查端點"""
    # 自動檢測容器ID作為節點ID
    import socket
    hostname = socket.gethostname()
    # 使用hostname的最後6位字符作為節點ID
    node_id = hostname[-6:] if len(hostname) >= 6 else os.environ.get('NODE_ID', '1')
    
    return jsonify({
        'status': 'healthy',
        'node_id': node_id,
        'timestamp': time.time(),
        'service': 'cloud-testing-api'
    })

@app.route('/api/v1/users', methods=['GET'])
@require_auth
def get_users():
    """獲取用戶列表 (需要認證)"""
    # 模擬數據庫查詢延遲
    time.sleep(random.uniform(0.1, 0.5))
    
    users = [
        {'id': 1, 'name': '張三', 'email': 'zhang@example.com', 'role': 'admin'},
        {'id': 2, 'name': '李四', 'email': 'li@example.com', 'role': 'user'},
        {'id': 3, 'name': '王五', 'email': 'wang@example.com', 'role': 'user'}
    ]
    
    # 自動檢測容器ID作為節點ID
    import socket
    hostname = socket.gethostname()
    # 使用hostname的最後6位字符作為節點ID
    node_id = hostname[-6:] if len(hostname) >= 6 else os.environ.get('NODE_ID', '1')
    
    logger.info(f"Node {node_id} 處理用戶列表請求")
    
    return jsonify({
        'users': users,
        'total': len(users),
        'node_id': node_id
    })

@app.route('/api/v1/users', methods=['POST'])
@require_auth
def create_user():
    """創建新用戶 (需要寫入權限)"""
    if 'write' not in request.user_info['permissions']:
        return jsonify({'error': '權限不足'}), 403
    
    data = request.get_json()
    if not data or 'name' not in data:
        return jsonify({'error': '缺少必要欄位'}), 400
    
    # 模擬創建用戶
    new_user = {
        'id': random.randint(100, 999),
        'name': data['name'],
        'email': data.get('email', f"{data['name']}@example.com"),
        'role': data.get('role', 'user')
    }
    
    # 自動檢測容器ID作為節點ID
    import socket
    hostname = socket.gethostname()
    # 使用hostname的最後6位字符作為節點ID
    node_id = hostname[-6:] if len(hostname) >= 6 else os.environ.get('NODE_ID', '1')
    
    logger.info(f"Node {node_id} 創建新用戶: {new_user['name']}")
    
    return jsonify({
        'message': '用戶創建成功',
        'user': new_user,
        'node_id': node_id
    }), 201

@app.route('/api/v1/users/<int:user_id>', methods=['DELETE'])
@require_auth
def delete_user(user_id):
    """刪除用戶 (需要刪除權限)"""
    if 'delete' not in request.user_info['permissions']:
        return jsonify({'error': '權限不足'}), 403
    
    # 自動檢測容器ID作為節點ID
    import socket
    hostname = socket.gethostname()
    # 使用hostname的最後6位字符作為節點ID
    node_id = hostname[-6:] if len(hostname) >= 6 else os.environ.get('NODE_ID', '1')
    
    logger.info(f"Node {node_id} 刪除用戶 ID: {user_id}")
    
    return jsonify({
        'message': f'用戶 {user_id} 刪除成功',
        'node_id': node_id
    })

@app.route('/api/v1/status', methods=['GET'])
def get_status():
    """獲取服務狀態 (無需認證)"""
    # 自動檢測容器ID作為節點ID
    import socket
    hostname = socket.gethostname()
    # 使用hostname的最後6位字符作為節點ID
    node_id = hostname[-6:] if len(hostname) >= 6 else os.environ.get('NODE_ID', '1')
    
    return jsonify({
        'service': 'cloud-testing-api',
        'version': '1.0.0',
        'node_id': node_id,
        'uptime': time.time(),
        'environment': os.environ.get('FLASK_ENV', 'production')
    })

@app.route('/api/v1/error-test', methods=['GET'])
def error_test():
    """模擬錯誤端點 (用於測試故障處理)"""
    error_type = request.args.get('type', '500')
    
    if error_type == '404':
        return jsonify({'error': '資源未找到'}), 404
    elif error_type == '500':
        return jsonify({'error': '內部服務器錯誤'}), 500
    elif error_type == 'timeout':
        time.sleep(10)  # 模擬超時
        return jsonify({'message': '請求超時'}), 408
    
    return jsonify({'error': '未知錯誤類型'}), 400

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True) 