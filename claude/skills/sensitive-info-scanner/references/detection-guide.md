# 検出パターンと判断基準

Claudeが機微情報を検出する際の、パターン・フォーマット・判断基準の詳細を記載したガイドです。

---

## 1. 変数名パターン

以下のキーワードが変数名・設定キー名に含まれる場合は、その値を注視する。

### 認証・機密キーワード
`password`, `passwd`, `pwd`, `secret`, `credential`, `auth_token`, `access_token`, `refresh_token`, `private_key`, `api_key`, `apikey`, `api_secret`

### 接続・サービス固有キーワード
`db_url`, `database_url`, `connection_string`, `dsn`, `aws_secret`, `stripe_key`, `slack_token`, `jwt_secret`, `encryption_key`, `signing_key`

**判断ポイント:** キーワードが含まれていても、値がプレースホルダーや環境変数参照であれば除外する。実値（ランダム文字列や具体的な値）が入っている場合のみ検出とする。

---

## 2. ファイル名パターン

### 高リスクファイル（優先的に内容確認）
| ファイル名パターン | リスク |
|-------------------|--------|
| `.env`, `.env.*`, `.env.local` | 環境変数ファイル—機密情報が直接記載される |
| `*.pem`, `*.key`, `*.p12`, `*.pfx` | 秘密鍵・証明書ファイル |
| `secrets.*`, `credentials.*` | シークレット定義ファイル |
| `*.keystore` | Java キーストア |
| `id_rsa`, `id_ed25519`, `id_ecdsa` | SSH秘密鍵 |

### 中リスクファイル（機密キーワード検出時に内容確認）
| ファイル名パターン | リスク |
|-------------------|--------|
| `*.yaml`, `*.yml` | CI/CD設定・Kubernetes定義に機密が混入するCase多 |
| `*.json` | 設定ファイルに機密が混入するCase多 |
| `*.toml`, `*.cfg`, `*.conf`, `*.ini` | アプリケーション設定ファイル |
| `Dockerfile`, `docker-compose.*` | 環境変数やシークレットが直接記載されるCase |
| `Makefile`, `*.sh` | スクリプト内にハードコード済み認証情報がある Case |

---

## 3. 文字列・値パターン

### 既知フォーマット
以下の文字列フォーマットは、特定サービスの認証情報として信頼度が高い。

| サービス | パターン | 重要度 |
|---------|----------|--------|
| AWS Access Key ID | `AKIA` で始まる20文字（大文字・数字） | Critical |
| AWS Secret Access Key | 40文字のBase64文字列（変数名がAWS関連の場合） | Critical |
| GCP APIキー | `AIza` で始まる39文字 | Critical |
| GitHub PAT | `ghp_` で始まる40文字 | Critical |
| GitHub OAuth | `gho_` で始まる40文字 | Critical |
| Stripe ライブキー | `sk_live_` で始まる | Critical |
| Stripe テストキー | `sk_test_` で始まる | Medium |
| Slack トークン | `xox[baprs]-` で始まる | High |
| SendGrid APIキー | `SG.` で始まる特定形式 | High |
| Twilio Account SID | `AC` で始まる32桁hex | High |
| SSH/PEM 秘密鍵 | `-----BEGIN ... PRIVATE KEY-----` | Critical |
| JWT トークン | `eyJ` で始まる、`.` で3段째に分割される文字列 | High |
| DB接続文字列 | `postgres://`, `mysql://`, `mongodb://`, `redis://` で始まる | Critical |

### 高エントロピー文字列
- 長さ20文字以上かつランダム感の高い文字列（大文字・小文字・数字・記号の組み合わせ）で、機密キーワード変数に代入されている場合は検出対象とする
- 単語の組み合わせや辞書語の列であれば除外する

### PII（個人情報）
| 種類 | パターン | 重要度 |
|------|----------|--------|
| メールアドレス | `xxx@xxx.xx` 形式 | Low |
| クレジットカード番号 | Visa(4で始まる16桁)・MC(51-55で始まる16桁)・Amex(34/37で始まる15桁)等 | Critical |
| 日本の電話番号 | `0XX-XXXX-XXXX` 形式 | Medium |
| マイナンバー | 12桁の数字（連続番号や明確なパターンは除外） | Critical |

---

## 4. コンテキスト分析による判断基準

### テストコンテキストの緩和
パス中に以下のキーワードが含まれる場合、検出された機微情報の重要度を `Info` に緩和する。

```
test, tests, mock, mocks, fixture, fixtures,
fake, fakes, sample, __tests__, spec
```

### プレースホルダーの除外
以下に該当する値は機密情報ではなくプレースホルダーと判定し、除外する。

- `placeholder`, `changeme`, `dummy`
- `your_password`, `your-key`, `YOUR_API_KEY` 等の "your_" / "YOUR_" プレフィックス
- `xxx`, `XXXX`（3文字以上の連続 x/X）
- `<anything>` （角括弧で囲まれた文字列）
- `{{anything}}` （テンプレート変数）
- `${anything}` （環境変数参照）
- `[anything]` （矩形括弧で囲まれた文字列）
- `DUMMY_*`, `SAMPLE_*`, `TEST_*` で始まる大文字列
- コメント内の説明文や例示として明確に使われている文字列

### コメント・ドキュメント内の検出
- `.md`, `.txt`, `.rst` 等のドキュメントファイルの中で検出された場合は、実際のコードで使われているかどうかも確認する
- 「例として」「サンプルとして」と明示されている場合は `Info` とする

---

## 5. 信頼度決定基準

| 信頼度 | 判定条件 |
|--------|----------|
| **High** | 既知フォーマットに正確に一致（AWS, GitHub, Stripe等）・秘密鍵ヘッダーが検出された・実値が変数に直接代入されている |
| **Medium** | 機密キーワード変数に高エントロピー値が代入されている・DB接続文字列だが一部プレースホルダーが混在・PII がコード本体に存在する |
| **Low** | テストコンテキスト内の検出・ドキュメント内の例示・値の性質が曖昧・エントロピーが低い |
