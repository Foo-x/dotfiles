# Zero Trust セキュリティチェックリスト

## Zero Trust の基本原則

Zero Trustは「信頼せず、常に検証する（Never Trust, Always Verify）」を基本とするセキュリティモデルです。

### コアテナント

1. **明示的な検証（Verify Explicitly）**
   - すべてのアクセスで認証・認可を実施
   - すべてのデータポイントで検証

2. **最小権限アクセス（Least Privilege Access）**
   - Just-In-Time（JIT）およびJust-Enough-Access（JEA）
   - リスクベースの適応型ポリシー

3. **侵害を想定（Assume Breach）**
   - セグメンテーション
   - エンドツーエンド暗号化
   - 継続的な監視

---

## 1. アイデンティティとアクセス管理

### 認証

- [ ] **多要素認証（MFA）の実装**
  - すべてのユーザーアカウント
  - すべての管理者アカウント
  - すべてのサービスアカウント

```python
# MFA実装例
from flask import session
import pyotp

def require_mfa(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get('mfa_verified'):
            return redirect('/verify-mfa')
        return f(*args, **kwargs)
    return decorated_function

@app.route('/verify-mfa', methods=['POST'])
def verify_mfa():
    user = get_current_user()
    totp = pyotp.TOTP(user.mfa_secret)

    if totp.verify(request.form['code']):
        session['mfa_verified'] = True
        return redirect('/dashboard')
    else:
        return 'Invalid MFA code', 401
```

- [ ] **強力なパスワードポリシー**
  - 最低12文字
  - 複雑性要件（大文字、小文字、数字、記号）
  - パスワード履歴（過去5回分の再利用禁止）
  - 90日ごとの変更（推奨）

- [ ] **パスワードレス認証の検討**
  - FIDO2/WebAuthn
  - 生体認証
  - マジックリンク

```javascript
// WebAuthn実装例
const credential = await navigator.credentials.create({
    publicKey: {
        challenge: new Uint8Array(32),
        rp: { name: "Example Corp" },
        user: {
            id: new Uint8Array(16),
            name: "user@example.com",
            displayName: "User"
        },
        pubKeyCredParams: [{ alg: -7, type: "public-key" }]
    }
});
```

### 認可

- [ ] **ロールベースアクセス制御（RBAC）**
  - 明確なロール定義
  - 最小権限の原則
  - 定期的なアクセスレビュー

```python
# RBAC実装例
class Permission:
    READ = 0x01
    WRITE = 0x02
    DELETE = 0x04
    ADMIN = 0xff

class Role:
    USER = Permission.READ
    MODERATOR = Permission.READ | Permission.WRITE
    ADMIN = Permission.ADMIN

def require_permission(permission):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            user = get_current_user()
            if not (user.role & permission):
                abort(403)
            return f(*args, **kwargs)
        return decorated_function
    return decorator
```

- [ ] **属性ベースアクセス制御（ABAC）**
  - コンテキストベースのアクセス決定
  - 動的ポリシー評価

```python
# ABAC実装例
def check_access(user, resource, action, context):
    policy = {
        'rules': [
            {
                'effect': 'allow',
                'conditions': [
                    user.department == resource.department,
                    action in user.permissions,
                    context.ip_address in ALLOWED_IPS,
                    context.time.hour >= 9 and context.time.hour <= 17
                ]
            }
        ]
    }

    for rule in policy['rules']:
        if all(rule['conditions']):
            return rule['effect'] == 'allow'

    return False  # Deny by default
```

- [ ] **Just-In-Time（JIT）アクセス**
  - 必要な時だけ権限を付与
  - 自動的な権限失効

### セッション管理

- [ ] **セキュアなセッション実装**
  - 暗号学的に安全なセッションID
  - HTTPOnly, Secure, SameSite Cookie属性
  - セッションタイムアウト

```python
# セキュアなセッション設定
app.config.update(
    SESSION_COOKIE_SECURE=True,
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE='Lax',
    PERMANENT_SESSION_LIFETIME=timedelta(minutes=30)
)
```

---

## 2. デバイスセキュリティ

### エンドポイント保護

- [ ] **デバイス健全性チェック**
  - OSバージョンの検証
  - セキュリティパッチの適用状況
  - マルウェア対策ソフトの有効化

- [ ] **デバイス登録と管理**
  - MDM（Mobile Device Management）
  - デバイス証明書
  - デバイスコンプライアンスポリシー

```python
# デバイス健全性チェック例
def check_device_health(device_info):
    checks = {
        'os_version': device_info['os_version'] >= MINIMUM_OS_VERSION,
        'antivirus': device_info['antivirus_enabled'],
        'firewall': device_info['firewall_enabled'],
        'disk_encrypted': device_info['disk_encrypted'],
        'last_updated': (datetime.now() - device_info['last_patch_date']).days <= 30
    }

    return all(checks.values()), checks
```

- [ ] **条件付きアクセス**
  - コンプライアンスに準拠したデバイスのみ許可
  - 場所ベースのアクセス制限
  - リスクベースの認証

---

## 3. ネットワークセグメンテーション

### マイクロセグメンテーション

- [ ] **ネットワークゾーン分離**
  - DMZ（Demilitarized Zone）
  - 内部ネットワーク
  - 管理ネットワーク
  - データベースネットワーク

```yaml
# Kubernetesネットワークポリシー例
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-network-policy
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 5432
```

- [ ] **ゼロトラストネットワークアクセス（ZTNA）**
  - すべての接続を検証
  - VPNの代替
  - アプリケーションレベルのアクセス制御

### ファイアウォール

- [ ] **次世代ファイアウォール（NGFW）**
  - アプリケーション認識
  - 侵入防止システム（IPS）
  - TLS/SSL インスペクション

- [ ] **Deny by Default**
  - すべてをブロックし、必要なものだけ許可
  - ホワイトリストアプローチ

```bash
# iptables例（Deny by Default）
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# 必要な接続のみ許可
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
```

---

## 4. データ保護

### 暗号化

- [ ] **保存データの暗号化（Encryption at Rest）**
  - データベース暗号化（TDE）
  - ファイルシステム暗号化
  - ディスク暗号化

```python
# データ暗号化例
from cryptography.fernet import Fernet

def encrypt_data(data, key):
    f = Fernet(key)
    encrypted = f.encrypt(data.encode())
    return encrypted

def decrypt_data(encrypted_data, key):
    f = Fernet(key)
    decrypted = f.decrypt(encrypted_data)
    return decrypted.decode()

# 使用例
key = Fernet.generate_key()
encrypted = encrypt_data("sensitive data", key)
```

- [ ] **通信データの暗号化（Encryption in Transit）**
  - TLS 1.2以上
  - 相互TLS（mTLS）
  - 強力な暗号スイート

```nginx
# Nginx TLS設定例
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
```

- [ ] **使用中データの暗号化（Encryption in Use）**
  - メモリ内暗号化
  - Confidential Computing（Intel SGX、AMD SEV）

### データ分類とDLP

- [ ] **データ分類**
  - Public（公開）
  - Internal（内部）
  - Confidential（機密）
  - Restricted（制限）

- [ ] **データ損失防止（DLP）**
  - 機密データの検出
  - データ流出の防止
  - ポリシーベースの制御

---

## 5. アプリケーションセキュリティ

### セキュアコーディング

- [ ] **入力検証**
  - すべての入力を検証
  - ホワイトリストアプローチ
  - サニタイゼーション

```python
# 入力検証例
from wtforms import Form, StringField, validators

class UserForm(Form):
    email = StringField('Email', [
        validators.Email(),
        validators.Length(min=6, max=120)
    ])
    age = IntegerField('Age', [
        validators.NumberRange(min=0, max=150)
    ])
```

- [ ] **出力エンコーディング**
  - XSS防止
  - コンテキスト適切なエンコーディング

```javascript
// XSS防止
import DOMPurify from 'dompurify';

const cleanHTML = DOMPurify.sanitize(userInput);
element.innerHTML = cleanHTML;
```

- [ ] **パラメータ化クエリ**
  - SQLインジェクション防止
  - ORMの使用

### API セキュリティ

- [ ] **API認証**
  - OAuth 2.0 / OpenID Connect
  - JWTトークン
  - APIキーの適切な管理

```python
# JWT検証例
import jwt

def verify_token(token):
    try:
        payload = jwt.decode(
            token,
            SECRET_KEY,
            algorithms=['HS256'],
            options={'verify_exp': True}
        )
        return payload
    except jwt.ExpiredSignatureError:
        raise AuthenticationError("Token expired")
    except jwt.InvalidTokenError:
        raise AuthenticationError("Invalid token")
```

- [ ] **APIレート制限**
  - DDoS防止
  - リソース保護

```python
# レート制限例
from flask_limiter import Limiter

limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@app.route("/api/data")
@limiter.limit("10 per minute")
def api_data():
    return jsonify(data)
```

- [ ] **APIセキュリティヘッダー**
  - CORS設定
  - Content Security Policy
  - X-Content-Type-Options

---

## 6. 監視と検知

### ログ管理

- [ ] **包括的なロギング**
  - 認証イベント
  - アクセス制御イベント
  - データ変更
  - システムイベント

```python
# 監査ログ例
import logging
import json

audit_logger = logging.getLogger('audit')

def log_audit_event(user, action, resource, result):
    event = {
        'timestamp': datetime.utcnow().isoformat(),
        'user': user.email,
        'action': action,
        'resource': resource,
        'result': result,
        'ip': request.remote_addr,
        'user_agent': request.headers.get('User-Agent')
    }
    audit_logger.info(json.dumps(event))
```

- [ ] **ログの集中管理**
  - SIEM（Security Information and Event Management）
  - ログ集約
  - 長期保存

### 異常検知

- [ ] **行動分析**
  - ユーザー行動分析（UBA）
  - 異常なアクセスパターンの検出
  - 機械学習ベースの検知

- [ ] **リアルタイムアラート**
  - セキュリティイベントの即時通知
  - 自動インシデント対応

```python
# 異常検知例
def detect_anomaly(user, action):
    # 過去の行動パターンと比較
    recent_actions = get_user_actions(user, days=7)

    # 異常な時間帯
    if action.timestamp.hour < 6 or action.timestamp.hour > 22:
        if not user.works_night_shift:
            alert_security_team(f"Unusual access time for {user.email}")

    # 異常な場所
    if action.ip_country != user.usual_country:
        alert_security_team(f"Access from unusual location for {user.email}")

    # 大量のリクエスト
    if len(recent_actions) > THRESHOLD:
        alert_security_team(f"Unusual activity volume for {user.email}")
```

---

## 7. インシデント対応

### 準備

- [ ] **インシデント対応計画**
  - 役割と責任の定義
  - エスカレーション手順
  - 連絡先リスト

- [ ] **インシデント対応チーム（CSIRT）**
  - 専任チームの編成
  - 定期的な訓練

### 検知と分析

- [ ] **セキュリティ監視**
  - 24/7 SOC
  - 自動化された脅威検知

### 封じ込め、根絶、回復

- [ ] **インシデント対応プレイブック**
  - 標準化された対応手順
  - 自動化された対応

```yaml
# インシデント対応プレイブック例
incident_type: unauthorized_access
steps:
  1. isolation:
    - Disable compromised account
    - Block IP address
    - Isolate affected systems

  2. investigation:
    - Collect logs
    - Analyze access patterns
    - Identify scope of breach

  3. containment:
    - Reset credentials
    - Patch vulnerabilities
    - Update firewall rules

  4. recovery:
    - Restore from backup
    - Verify system integrity
    - Re-enable services

  5. lessons_learned:
    - Document incident
    - Update procedures
    - Implement preventive measures
```

---

## 8. コンプライアンスと監査

### 継続的コンプライアンス

- [ ] **ポリシーの自動チェック**
  - Infrastructure as Code（IaC）スキャン
  - コンプライアンススコアリング

```yaml
# OPA (Open Policy Agent) ポリシー例
package kubernetes.admission

deny[msg] {
    input.request.kind.kind == "Pod"
    not input.request.object.spec.securityContext.runAsNonRoot
    msg := "Containers must not run as root"
}
```

- [ ] **定期的な監査**
  - アクセスレビュー（四半期ごと）
  - 権限レビュー
  - セキュリティ設定レビュー

### 証拠の保全

- [ ] **監査証跡**
  - 改ざん防止ログ
  - チェーンオブカストディ
  - 長期保存

---

## Zero Trust 成熟度評価

### レベル1: 従来型（Traditional）
- 境界ベースのセキュリティ
- 内部ネットワークを信頼
- 基本的な認証

### レベル2: 初期（Initial）
- MFA導入開始
- 一部のセグメンテーション
- 基本的なログ収集

### レベル3: 高度（Advanced）
- 包括的なMFA
- マイクロセグメンテーション
- SIEM統合
- 条件付きアクセス

### レベル4: 最適（Optimal）
- 完全な Zero Trust アーキテクチャ
- 自動化された脅威対応
- 継続的な検証
- AIベースの異常検知

## チェックリスト全体まとめ

```markdown
# Zero Trust 実装チェックリスト

## アイデンティティ
- [ ] MFA全面導入
- [ ] RBAC/ABAC実装
- [ ] JITアクセス
- [ ] セキュアなセッション管理

## デバイス
- [ ] デバイス健全性チェック
- [ ] MDM導入
- [ ] 条件付きアクセス

## ネットワーク
- [ ] マイクロセグメンテーション
- [ ] ZTNA実装
- [ ] Deny by Default

## データ
- [ ] 保存データ暗号化
- [ ] 通信データ暗号化
- [ ] データ分類
- [ ] DLP実装

## アプリケーション
- [ ] セキュアコーディング
- [ ] API認証・認可
- [ ] レート制限

## 監視
- [ ] 包括的ロギング
- [ ] SIEM統合
- [ ] 異常検知
- [ ] リアルタイムアラート

## インシデント対応
- [ ] IR計画
- [ ] CSIRTチーム
- [ ] プレイブック

## コンプライアンス
- [ ] ポリシー自動チェック
- [ ] 定期監査
- [ ] 監査証跡

成熟度レベル: [ Level 1 | Level 2 | Level 3 | Level 4 ]
```

## 参考資料

- [NIST Zero Trust Architecture (SP 800-207)](https://csrc.nist.gov/publications/detail/sp/800-207/final)
- [Microsoft Zero Trust](https://www.microsoft.com/en-us/security/business/zero-trust)
- [Google BeyondCorp](https://cloud.google.com/beyondcorp)
