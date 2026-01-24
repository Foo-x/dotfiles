# コンプライアンスフレームワーク

## SOC 2 (Service Organization Control 2)

### 概要
SOC 2は、サービス組織がデータをどのように管理しているかを評価するための監査基準です。

### 信頼サービス基準（Trust Services Criteria）

#### CC (Common Criteria) - 共通基準
すべてのSOC 2監査に必須

**CC1: 統制環境（Control Environment）**
- [ ] 組織の誠実性と倫理的価値
- [ ] 取締役会の独立性と監督
- [ ] 権限と責任の確立
- [ ] 能力のある人材の獲得、育成、維持

**CC2: コミュニケーションと情報（Communication and Information）**
- [ ] 内部統制に関連する情報の入手
- [ ] 内部統制に関する情報の内部コミュニケーション
- [ ] 外部当事者との適切なコミュニケーション

**CC3: リスク評価（Risk Assessment）**
- [ ] 目標の明確化
- [ ] リスクの特定と分析
- [ ] 不正リスクの評価
- [ ] 重要な変更の識別と評価

**CC4: モニタリング活動（Monitoring Activities）**
- [ ] 継続的および個別評価の実施
- [ ] 欠陥の評価と伝達

**CC5: 統制活動（Control Activities）**
- [ ] リスクに対応する統制活動の選択と展開
- [ ] テクノロジー統制の選択と展開
- [ ] ポリシーと手順を通じた展開

#### 追加基準（オプション）

**A: 可用性（Availability）**
- [ ] システムの稼働率目標（例: 99.9%）
- [ ] バックアップとリカバリー手順
- [ ] 冗長性とフェイルオーバー
- [ ] インシデント対応計画

```yaml
# 可用性要件例
availability_requirements:
  uptime_target: 99.9%
  rto: 4 hours  # Recovery Time Objective
  rpo: 1 hour   # Recovery Point Objective
  backup_frequency: daily
  backup_retention: 30 days
  disaster_recovery_test: quarterly
```

**C: 機密性（Confidentiality）**
- [ ] データ分類ポリシー
- [ ] アクセス制御
- [ ] 暗号化（保存時、通信時）
- [ ] データ保持とデータ削除ポリシー

**I: 処理の完全性（Processing Integrity）**
- [ ] データ入力の検証
- [ ] 処理エラーの検出と修正
- [ ] データ出力の検証
- [ ] 監査証跡

**P: プライバシー（Privacy）**
- [ ] 個人情報の収集、使用、保持、開示に関する通知と同意
- [ ] アクセス、修正、削除の権利
- [ ] データ品質の維持
- [ ] 第三者との情報共有の管理

**S: セキュリティ（Security）** - 常に必須
- [ ] アクセス制御（論理的および物理的）
- [ ] システム操作のログ記録と監視
- [ ] 変更管理
- [ ] リスク軽減

### SOC 2 実装チェックリスト

```markdown
## アクセス制御
- [ ] ユーザーアクセス管理プロセス
- [ ] 多要素認証（MFA）
- [ ] パスワードポリシー（最低12文字、複雑性要件）
- [ ] 四半期ごとのアクセスレビュー
- [ ] 職責の分離

## 変更管理
- [ ] 変更要求プロセス
- [ ] 開発/ステージング/本番環境の分離
- [ ] コードレビュープロセス
- [ ] デプロイメント承認
- [ ] ロールバック手順

## システムモニタリング
- [ ] セキュリティイベントのログ記録
- [ ] ログの集中管理
- [ ] 異常検知とアラート
- [ ] ログの保持（最低1年）

## インシデント対応
- [ ] インシデント対応計画
- [ ] インシデント対応チーム
- [ ] インシデントの記録と追跡
- [ ] 事後レビューとレッスンラーンド

## データ保護
- [ ] 保存データの暗号化
- [ ] 通信データの暗号化（TLS 1.2以上）
- [ ] バックアップの暗号化
- [ ] 鍵管理プロセス

## ベンダー管理
- [ ] ベンダーリスク評価
- [ ] ベンダー契約にセキュリティ条項
- [ ] 定期的なベンダーレビュー
```

---

## GDPR (General Data Protection Regulation)

### 概要
GDPRは、EU域内の個人データ保護を規定する法律です。違反時の罰金は最大2000万ユーロまたは年間売上の4%。

### 主要原則

**1. 適法性、公正性、透明性（Lawfulness, Fairness, Transparency）**
- [ ] 明確な法的根拠
- [ ] プライバシーポリシーの公開
- [ ] データ処理の目的の明示

**2. 目的の制限（Purpose Limitation）**
- [ ] 特定された目的のみでの処理
- [ ] 目的外使用の禁止

**3. データの最小化（Data Minimization）**
- [ ] 必要最小限のデータのみ収集
- [ ] 不要なデータの収集禁止

**4. 正確性（Accuracy）**
- [ ] データの正確性維持
- [ ] 不正確なデータの訂正・削除

**5. 保存の制限（Storage Limitation）**
- [ ] データ保持期間の設定
- [ ] 期間経過後の削除

**6. 完全性と機密性（Integrity and Confidentiality）**
- [ ] 適切なセキュリティ対策
- [ ] 暗号化、アクセス制御

**7. 説明責任（Accountability）**
- [ ] コンプライアンスの証明
- [ ] 記録の保持

### データ主体の権利

- [ ] **アクセス権（Right of Access）**: 自分のデータへのアクセス
- [ ] **訂正権（Right to Rectification）**: 不正確なデータの訂正
- [ ] **削除権（Right to Erasure / "Right to be Forgotten"）**: データの削除要求
- [ ] **処理の制限権（Right to Restriction of Processing）**: 処理の一時停止
- [ ] **データポータビリティ権（Right to Data Portability）**: データの移転
- [ ] **異議権（Right to Object）**: 処理への異議
- [ ] **自動化された意思決定に関する権利**: プロファイリングへの異議

### GDPR実装チェックリスト

```markdown
## データマッピング
- [ ] 個人データのインベントリ作成
- [ ] データフローの文書化
- [ ] 第三者へのデータ転送の特定

## 法的根拠
- [ ] 各処理活動の法的根拠の特定
  - 同意
  - 契約の履行
  - 法的義務
  - 正当な利益

## 同意管理
- [ ] 明確で理解しやすい同意取得
- [ ] 同意の記録
- [ ] 同意撤回の容易さ

## データ主体の権利対応
- [ ] アクセス要求への対応プロセス（1ヶ月以内）
- [ ] 削除要求への対応プロセス
- [ ] データエクスポート機能

## セキュリティ対策
- [ ] 個人データの暗号化
- [ ] 仮名化・匿名化の検討
- [ ] アクセス制御
- [ ] 定期的なセキュリティ評価

## データ保護影響評価（DPIA）
- [ ] 高リスク処理の特定
- [ ] DPIAの実施
- [ ] リスク軽減策の実装

## データ侵害対応
- [ ] 72時間以内の監督当局への通知プロセス
- [ ] データ主体への通知プロセス
- [ ] 侵害の記録

## DPO（データ保護責任者）
- [ ] DPOの任命（該当する場合）
- [ ] DPOの連絡先公開
```

### GDPR対応コード例

```python
# データ主体の権利実装例
from flask import Flask, request, jsonify
from datetime import datetime

class GDPRCompliance:
    """GDPR準拠機能"""

    @staticmethod
    def export_user_data(user_id):
        """データポータビリティ権の実装"""
        user_data = {
            'personal_info': get_user_personal_info(user_id),
            'activity_log': get_user_activity(user_id),
            'preferences': get_user_preferences(user_id),
            'exported_at': datetime.utcnow().isoformat()
        }
        return user_data

    @staticmethod
    def delete_user_data(user_id):
        """削除権（忘れられる権利）の実装"""
        # 法的保持義務のあるデータを除いて削除
        delete_user_account(user_id)
        delete_user_activity(user_id)
        anonymize_required_records(user_id)

        log_gdpr_action('data_deletion', user_id)

    @staticmethod
    def handle_access_request(user_id):
        """アクセス権の実装"""
        data = {
            'what_data_we_have': export_user_data(user_id),
            'why_we_process': get_processing_purposes(user_id),
            'legal_basis': get_legal_basis(user_id),
            'retention_period': get_retention_periods(user_id),
            'third_parties': get_data_recipients(user_id)
        }
        return data

# 同意管理
class ConsentManager:
    """同意管理"""

    @staticmethod
    def record_consent(user_id, purpose, method='explicit'):
        """同意の記録"""
        consent = {
            'user_id': user_id,
            'purpose': purpose,
            'method': method,
            'timestamp': datetime.utcnow(),
            'ip_address': request.remote_addr,
            'user_agent': request.headers.get('User-Agent')
        }
        save_consent_record(consent)

    @staticmethod
    def withdraw_consent(user_id, purpose):
        """同意の撤回"""
        update_consent(user_id, purpose, withdrawn=True)
        stop_processing(user_id, purpose)
```

---

## HIPAA (Health Insurance Portability and Accountability Act)

### 概要
HIPAAは、米国の医療情報保護法で、保護対象医療情報（PHI）の取り扱いを規制します。

### HIPAA規則

#### Security Rule（セキュリティ規則）

**管理的保護措置（Administrative Safeguards）**
- [ ] セキュリティ管理プロセス
  - リスク分析
  - リスク管理
  - 制裁ポリシー
  - 情報システム活動のレビュー

- [ ] 役割と責任の割り当て
  - セキュリティ責任者の指定

- [ ] 労働力のセキュリティ
  - 認可および監督
  - 労働力のクリアランス手順
  - 雇用終了手順

- [ ] 情報アクセス管理
  - アクセス認可
  - アクセス確立と修正

- [ ] セキュリティ意識とトレーニング
  - セキュリティ注意喚起
  - 保護対策
  - ログイン監視
  - パスワード管理

**物理的保護措置（Physical Safeguards）**
- [ ] 施設アクセス制御
  - 偶発的アクセス制御
  - 物理アクセス制御と検証手順

- [ ] ワークステーションの使用
  - 適切な使用ポリシー

- [ ] ワークステーションのセキュリティ
  - 物理的保護

- [ ] デバイスとメディアの制御
  - 処分
  - メディアの再利用
  - 説明責任
  - データのバックアップと保存

**技術的保護措置（Technical Safeguards）**
- [ ] アクセス制御
  - 一意のユーザー識別
  - 緊急アクセス手順
  - 自動ログオフ
  - 暗号化と復号化

- [ ] 監査制御
  - ハードウェア、ソフトウェア、手順メカニズム

- [ ] 完全性
  - 変更防止・検出メカニズム

- [ ] 個人または団体の認証
  - 認証手順

- [ ] 送信セキュリティ
  - 完全性制御
  - 暗号化

#### Privacy Rule（プライバシー規則）

- [ ] 個人の権利
  - PHIへのアクセス
  - PHIの修正
  - 開示の説明
  - 代替通信の要求

- [ ] 使用と開示の制限
  - 最小限必要の原則
  - マーケティング用途の制限

### HIPAA実装チェックリスト

```markdown
## リスク評価
- [ ] 年次リスク分析の実施
- [ ] 脆弱性の特定
- [ ] リスク軽減計画

## アクセス制御
- [ ] 役割ベースアクセス制御（RBAC）
- [ ] 一意のユーザーID
- [ ] 緊急アクセス手順
- [ ] 自動ログオフ（15分の非アクティブ後）

## 暗号化
- [ ] 保存時のPHI暗号化（AES-256）
- [ ] 通信時のPHI暗号化（TLS 1.2以上）
- [ ] モバイルデバイスの暗号化

## 監査ログ
- [ ] すべてのPHIアクセスのログ記録
- [ ] ログの6年間保持
- [ ] ログの定期的なレビュー

## ビジネスアソシエイト契約（BAA）
- [ ] すべてのベンダーとのBAA締結
- [ ] ベンダーのHIPAAコンプライアンス確認

## 侵害通知
- [ ] 60日以内の侵害通知プロセス
- [ ] 影響を受ける個人への通知
- [ ] HHSへの報告

## トレーニング
- [ ] 年次HIPAAトレーニング
- [ ] トレーニング記録の保持
```

---

## PCI DSS (Payment Card Industry Data Security Standard)

### 概要
PCI DSSは、クレジットカード情報を取り扱う組織のセキュリティ基準です。

### 12の要件

#### 1. ファイアウォールの設置と維持
- [ ] すべてのシステム間にファイアウォール設置
- [ ] ファイアウォールルールの文書化
- [ ] 四半期ごとのルールレビュー

#### 2. ベンダー提供のデフォルトを使用しない
- [ ] デフォルトパスワードの変更
- [ ] 不要なサービスの無効化
- [ ] セキュリティパラメータの変更

#### 3. 保存されるカード会員データの保護
- [ ] データ保持ポリシー
- [ ] 必要最小限のデータのみ保存
- [ ] PANの保存時の暗号化
- [ ] 機密認証データ（CVV、PINなど）の保存禁止

```python
# PCI DSS準拠のカードデータ処理例
class PCICompliantCardProcessor:
    """PCI DSS準拠カード処理"""

    @staticmethod
    def tokenize_card(card_number):
        """カード番号のトークン化（PANを保存しない）"""
        # トークン化サービス使用（実際の番号は保存しない）
        token = payment_gateway.tokenize(card_number)
        return token

    @staticmethod
    def mask_card_number(card_number):
        """カード番号のマスキング（最初6桁と最後4桁のみ表示）"""
        return card_number[:6] + '*' * 6 + card_number[-4:]

    @staticmethod
    def process_payment(token, amount):
        """トークンを使用した決済処理"""
        # カード番号ではなくトークンを使用
        result = payment_gateway.charge(token, amount)
        return result
```

#### 4. 公衆ネットワークでのカード会員データ送信の暗号化
- [ ] TLS 1.2以上の使用
- [ ] 強力な暗号化アルゴリズム
- [ ] 証明書の有効性確認

#### 5. マルウェアからの保護
- [ ] アンチウイルスソフトウェアの導入
- [ ] 定期的な更新
- [ ] 定期スキャン

#### 6. セキュアなシステムとアプリケーションの開発と維持
- [ ] セキュアな開発ライフサイクル
- [ ] コードレビュー
- [ ] 脆弱性評価
- [ ] パッチ管理（30日以内）

#### 7. カード会員データへのアクセス制限（業務上の必要性に基づく）
- [ ] 役割ベースアクセス制御
- [ ] 最小権限の原則
- [ ] アクセス権の定期的レビュー

#### 8. コンピュータアクセスの識別と認証
- [ ] 一意のユーザーID
- [ ] 強力なパスワードポリシー（最低7文字）
- [ ] 多要素認証（管理者および遠隔アクセス）

#### 9. カード会員データへの物理アクセス制限
- [ ] 物理アクセス制御
- [ ] 訪問者ログ
- [ ] メディアの安全な破棄

#### 10. ネットワークリソースとカード会員データへのすべてのアクセスの追跡と監視
- [ ] すべてのアクセスのログ記録
- [ ] ログの日次レビュー
- [ ] ログの1年間保持（最低3ヶ月はオンライン）

#### 11. セキュリティシステムとプロセスの定期的テスト
- [ ] 四半期ごとの脆弱性スキャン
- [ ] 年次ペネトレーションテスト
- [ ] 侵入検知システム（IDS）

#### 12. すべての従業員に対する情報セキュリティポリシーの維持
- [ ] セキュリティポリシーの文書化
- [ ] 年次セキュリティ意識向上トレーニング
- [ ] インシデント対応計画

### PCI DSSレベル

```
Level 1: 年間600万件以上のトランザクション
  - 年次オンサイト評価（QSA）

Level 2: 年間100万～600万件
  - 年次自己評価質問票（SAQ）

Level 3: 年間2万～100万件（e-commerce）
  - 年次SAQ

Level 4: 年間2万件未満
  - 年次SAQ
```

---

## コンプライアンスマッピング

### セキュリティコントロールのマッピング

```markdown
| セキュリティ対策 | SOC 2 | GDPR | HIPAA | PCI DSS |
|----------------|-------|------|-------|---------|
| MFA | CC6.1 | Art.32 | §164.312(a)(2) | Req 8.3 |
| 暗号化 | CC6.1 | Art.32 | §164.312(a)(2) | Req 3,4 |
| アクセス制御 | CC6.2 | Art.32 | §164.312(a)(1) | Req 7,8 |
| ログ記録 | CC7.2 | Art.30 | §164.312(b) | Req 10 |
| 脆弱性管理 | CC7.1 | Art.32 | §164.308(a)(8) | Req 6,11 |
| インシデント対応 | CC7.3 | Art.33 | §164.308(a)(6) | Req 12.10 |
| ベンダー管理 | CC9.2 | Art.28 | §164.308(b) | Req 12.8 |
```

### 統合チェックリスト

```markdown
## マルチコンプライアンスチェックリスト

### アクセス管理
- [ ] 一意のユーザーID（すべて）
- [ ] MFA（SOC 2, HIPAA管理者, PCI DSS管理者）
- [ ] RBAC（すべて）
- [ ] 四半期ごとのアクセスレビュー（SOC 2, PCI DSS）

### 暗号化
- [ ] 保存データ暗号化（すべて）
- [ ] TLS 1.2以上（すべて）
- [ ] 鍵管理（すべて）

### ログとモニタリング
- [ ] 包括的ログ記録（すべて）
- [ ] ログ保持: 最低1年（SOC 2, PCI DSS）、6年（HIPAA）
- [ ] 日次ログレビュー（PCI DSS）

### インシデント対応
- [ ] インシデント対応計画（すべて）
- [ ] 通知要件
  - GDPR: 72時間
  - HIPAA: 60日
  - SOC 2: 契約による

### リスク管理
- [ ] 年次リスク評価（すべて）
- [ ] DPIA（GDPR高リスク処理）
- [ ] 脆弱性スキャン（四半期ごと: PCI DSS）

### トレーニング
- [ ] 年次セキュリティトレーニング（すべて）
- [ ] トレーニング記録（すべて）
```

## 参考資料

- [SOC 2 Trust Services Criteria](https://www.aicpa.org/interestareas/frc/assuranceadvisoryservices/trustdataintegritytaskforce)
- [GDPR Official Text](https://gdpr-info.eu/)
- [HIPAA Security Rule](https://www.hhs.gov/hipaa/for-professionals/security/index.html)
- [PCI DSS v4.0](https://www.pcisecuritystandards.org/document_library)
