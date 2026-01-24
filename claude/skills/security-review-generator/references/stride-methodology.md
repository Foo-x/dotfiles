# STRIDE 脅威モデリング手法

STRIDEは、Microsoft が開発した脅威モデリングフレームワークで、システムの脅威を6つのカテゴリに分類します。

## STRIDE カテゴリ

### S - Spoofing (なりすまし)

**定義:** 攻撃者が他のユーザーやシステムになりすます脅威。

**脅威例:**
- ユーザー認証情報の盗用
- セッションハイジャック
- IPアドレス偽装
- メールアドレス偽装
- 証明書偽造

**チェックポイント:**
- [ ] 多要素認証（MFA）の実装
- [ ] セッショントークンの暗号学的ランダム性
- [ ] 証明書検証
- [ ] 送信元検証
- [ ] アンチスプーフィング対策

**対策:**
- 強力な認証メカニズム（MFA、生体認証）
- 相互TLS認証
- デジタル署名
- セキュアなセッション管理
- IPアドレスとユーザーエージェントの検証

**検出方法:**
```python
# セッション検証例
def validate_session(request):
    # トークンの検証
    if not is_valid_token(request.session['token']):
        raise AuthenticationError("Invalid session")

    # IPアドレスの一貫性チェック
    if request.session['ip'] != request.remote_addr:
        raise SecurityError("IP address mismatch")

    # ユーザーエージェントの検証
    if request.session['user_agent'] != request.headers['User-Agent']:
        log_suspicious_activity()
```

---

### T - Tampering (改ざん)

**定義:** データやコードの不正な変更。

**脅威例:**
- データベースの不正変更
- 通信データの改ざん
- ファイルの改ざん
- ログの改ざん
- 設定ファイルの変更

**チェックポイント:**
- [ ] データ整合性の検証（ハッシュ、デジタル署名）
- [ ] 通信の暗号化（TLS）
- [ ] ファイルの整合性モニタリング
- [ ] 監査ログの保護
- [ ] 書き込み権限の最小化

**対策:**
- デジタル署名
- ハッシュ値による整合性チェック
- TLS/SSL通信
- ファイル整合性モニタリング（FIM）
- 監査ログの署名と集中管理
- アクセス制御リスト（ACL）

**検出方法:**
```python
# データ整合性検証例
import hashlib
import hmac

def verify_data_integrity(data, signature, secret_key):
    """データの整合性を検証"""
    expected_signature = hmac.new(
        secret_key.encode(),
        data.encode(),
        hashlib.sha256
    ).hexdigest()

    return hmac.compare_digest(signature, expected_signature)

# ファイル整合性チェック
def check_file_integrity(filepath, expected_hash):
    """ファイルの整合性をチェック"""
    sha256_hash = hashlib.sha256()
    with open(filepath, "rb") as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)

    return sha256_hash.hexdigest() == expected_hash
```

---

### R - Repudiation (否認)

**定義:** 行動の証拠を否定できる脅威。

**脅威例:**
- トランザクションの否認
- 監査ログの欠如
- ログの改ざん
- 非デジタル署名トランザクション
- タイムスタンプの欠如

**チェックポイント:**
- [ ] 包括的な監査ログ
- [ ] ログの改ざん防止
- [ ] デジタル署名
- [ ] タイムスタンプ
- [ ] 否認防止メカニズム

**対策:**
- 改ざん防止ログ（Append-only、署名）
- デジタル署名
- 信頼できるタイムスタンプ
- SIEM（Security Information and Event Management）
- ブロックチェーン技術

**実装例:**
```python
# 監査ログ実装例
import logging
import json
from datetime import datetime

class AuditLogger:
    """改ざん防止監査ログ"""

    def __init__(self, log_file):
        self.log_file = log_file
        self.logger = logging.getLogger('audit')

    def log_event(self, user, action, resource, result):
        """イベントをログに記録"""
        event = {
            'timestamp': datetime.utcnow().isoformat(),
            'user': user,
            'action': action,
            'resource': resource,
            'result': result,
            'ip_address': get_client_ip(),
        }

        # デジタル署名を追加
        event['signature'] = self._sign_event(event)

        self.logger.info(json.dumps(event))

    def _sign_event(self, event):
        """イベントに署名"""
        # 実装: HMAC-SHA256など
        pass

# 使用例
audit = AuditLogger('/var/log/audit.log')
audit.log_event(
    user='john@example.com',
    action='DELETE',
    resource='/api/users/123',
    result='SUCCESS'
)
```

---

### I - Information Disclosure (情報漏洩)

**定義:** 権限のないユーザーへの情報公開。

**脅威例:**
- データベースの露出
- APIからの過剰な情報返却
- エラーメッセージでの情報漏洩
- ソースコードの露出
- 機密ファイルの公開
- メタデータの漏洩

**チェックポイント:**
- [ ] エラーメッセージのサニタイズ
- [ ] データの最小化（必要最小限のみ返却）
- [ ] 機密データの暗号化
- [ ] アクセス制御
- [ ] セキュリティヘッダー設定

**対策:**
- データ分類と最小化
- 暗号化（保存時、通信時）
- 汎用的なエラーメッセージ
- セキュリティヘッダー（X-Frame-Options等）
- ディレクトリリスティング無効化
- デバッグモードの無効化（本番環境）

**実装例:**
```python
# エラー処理の安全な実装
from flask import Flask, jsonify
import logging

app = Flask(__name__)

@app.errorhandler(Exception)
def handle_error(error):
    # 詳細なエラーはログに記録
    logging.error(f"Error occurred: {str(error)}", exc_info=True)

    # ユーザーには汎用的なメッセージを返す
    return jsonify({
        'error': 'An error occurred',
        'message': 'Please contact support if the problem persists'
    }), 500

# APIレスポンスのフィルタリング
def filter_sensitive_fields(data):
    """機密フィールドを除外"""
    sensitive_fields = ['password', 'ssn', 'credit_card', 'api_key']

    if isinstance(data, dict):
        return {
            k: filter_sensitive_fields(v)
            for k, v in data.items()
            if k not in sensitive_fields
        }
    elif isinstance(data, list):
        return [filter_sensitive_fields(item) for item in data]
    else:
        return data
```

---

### D - Denial of Service (サービス拒否)

**定義:** システムの可用性を低下させる脅威。

**脅威例:**
- リソース枯渇攻撃
- アプリケーション層DoS
- ネットワーク層DoS/DDoS
- ロジックボム
- 無限ループ

**チェックポイント:**
- [ ] レート制限
- [ ] リソース制限（CPU、メモリ、ディスク）
- [ ] タイムアウト設定
- [ ] 入力サイズ制限
- [ ] DDoS保護

**対策:**
- レート制限（API、ログイン）
- リソースクォータ
- タイムアウト設定
- 入力検証とサイズ制限
- ロードバランシング
- CDN使用
- DDoS保護サービス（Cloudflare、AWS Shield）

**実装例:**
```python
# レート制限実装
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@app.route("/api/data")
@limiter.limit("10 per minute")
def get_data():
    return jsonify(data)

# リソース制限
import resource

def limit_resources():
    """リソース制限を設定"""
    # CPU時間制限（秒）
    resource.setrlimit(resource.RLIMIT_CPU, (60, 60))

    # メモリ制限（バイト）
    resource.setrlimit(resource.RLIMIT_AS, (512 * 1024 * 1024, 512 * 1024 * 1024))

    # ファイルサイズ制限
    resource.setrlimit(resource.RLIMIT_FSIZE, (10 * 1024 * 1024, 10 * 1024 * 1024))
```

```javascript
// Node.js レート制限
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15分
    max: 100 // 最大100リクエスト
});

app.use('/api/', limiter);

// タイムアウト設定
const timeout = require('connect-timeout');
app.use(timeout('5s'));
```

---

### E - Elevation of Privilege (権限昇格)

**定義:** より高い権限の取得。

**脅威例:**
- 垂直権限昇格（一般ユーザー→管理者）
- 水平権限昇格（他ユーザーのデータアクセス）
- SQLインジェクションによる権限昇格
- バッファオーバーフローによる権限昇格

**チェックポイント:**
- [ ] 最小権限の原則
- [ ] 権限チェックの一貫性
- [ ] 入力検証
- [ ] セキュアなコーディング
- [ ] 定期的な権限レビュー

**対策:**
- 最小権限の原則（Principle of Least Privilege）
- ロールベースアクセス制御（RBAC）
- すべてのリソースアクセスで認可チェック
- 入力検証
- セキュアなコーディングプラクティス

**実装例:**
```python
# 権限ベースのアクセス制御
from functools import wraps
from flask import abort

def require_permission(permission):
    """権限チェックデコレータ"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            user = get_current_user()

            if not user:
                abort(401)  # Unauthorized

            if not user.has_permission(permission):
                abort(403)  # Forbidden

            return f(*args, **kwargs)
        return decorated_function
    return decorator

@app.route('/admin/users', methods=['DELETE'])
@require_permission('user.delete')
def delete_user(user_id):
    # 権限確認済み
    User.delete(user_id)
    return jsonify({'status': 'success'})

# リソースオーナーシップチェック
@app.route('/api/documents/<doc_id>', methods=['GET'])
def get_document(doc_id):
    user = get_current_user()
    document = Document.get(doc_id)

    # オーナーまたは共有されているかチェック
    if document.owner_id != user.id and user.id not in document.shared_with:
        abort(403)

    return jsonify(document.to_dict())
```

---

## STRIDE 分析プロセス

### 1. システムの分解
```
- データフローダイアグラム（DFD）作成
- 信頼境界の特定
- エントリーポイントの特定
```

### 2. 脅威の列挙
各コンポーネントに対してSTRIDEカテゴリを適用

### 3. リスク評価
- 脅威の影響度評価
- 発生可能性評価
- リスクレベル決定

### 4. 対策の決定
- 緩和策の特定
- 実装優先度の決定

### 5. 検証
- 対策の有効性検証
- 継続的なレビュー

## STRIDE マッピング表

| コンポーネント | S | T | R | I | D | E |
|--------------|---|---|---|---|---|---|
| プロセス     | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| データストア | - | ✓ | ✓ | ✓ | ✓ | - |
| データフロー | - | ✓ | - | ✓ | ✓ | - |
| 外部エンティティ | ✓ | - | ✓ | - | - | - |

## STRIDE-per-Element テンプレート

### Webアプリケーションの例

```markdown
## コンポーネント: ログインAPI

### Spoofing
- 脅威: ブルートフォース攻撃
- 対策: レート制限、アカウントロックアウト、CAPTCHA

### Tampering
- 脅威: リクエストパラメータの改ざん
- 対策: 署名検証、HTTPS

### Repudiation
- 脅威: ログイン試行の否認
- 対策: 監査ログ、IPアドレス記録

### Information Disclosure
- 脅威: ユーザー列挙攻撃
- 対策: 汎用的なエラーメッセージ

### Denial of Service
- 脅威: 大量のログイン試行
- 対策: レート制限、リソース制限

### Elevation of Privilege
- 脅威: SQLインジェクションによる管理者権限取得
- 対策: パラメータ化クエリ、入力検証
```

## 自動化ツール

- **Microsoft Threat Modeling Tool**
- **OWASP Threat Dragon**
- **IriusRisk**
- **ThreatModeler**

## 参考資料

- [Microsoft STRIDE Documentation](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats)
- [OWASP Threat Modeling](https://owasp.org/www-community/Threat_Modeling)
- [The STRIDE Threat Model](https://en.wikipedia.org/wiki/STRIDE_(security))
