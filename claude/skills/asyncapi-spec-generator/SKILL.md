---
name: asyncapi-spec-generator
description: プロジェクトを分析してAsyncAPI 3.0.0仕様書を自動生成するスキル。CLAUDE.mdやAGENT.mdからプロジェクト概要を読み取り、使用プロトコル/基盤を検出し、チャンネル・メッセージ・オペレーション定義を抽出する。以下の場合に使用:(1) 既存プロジェクトのAsyncAPI仕様書を作成したい時、(2) イベント/メッセージAPIドキュメントを自動生成したい時、(3) AsyncAPI仕様書が必要な時
disable-model-invocation: true
---

# AsyncAPI仕様書生成スキル

プロジェクトを分析してAsyncAPI 3.0.0形式のAPI仕様書を自動生成します。

## 実行フロー

### Phase 1: プロジェクト概要とプロトコルの把握

**目的:** プロジェクトドキュメントから全体像と使用プロトコルを理解する

1. **プロジェクトドキュメントの検索と読み取り**
   ```bash
   find . -maxdepth 2 \( -name 'AGENTS.md' -o -name 'CLAUDE.md' -o -name 'README.md' \) -type f 2>/dev/null
   ```

   優先順位: `AGENTS.md` > `CLAUDE.md` > `README.md`

   各ファイルを読み込み、以下の情報を抽出:

   **a) 基本情報 (AsyncAPI仕様書に使用)**
   - プロジェクト名 → `info.title`
   - プロジェクト説明 → `info.description`
   - バージョン情報 → `info.version`
   - 連絡先情報 → `info.contact`
   - デフォルトコンテンツタイプ → `defaultContentType`

   **b) メッセージ基盤/プロトコル情報 (検出に使用)**
   - Kafka, RabbitMQ/AMQP, MQTT, NATS, Redis Streams, AWS SNS/SQS, WebSocket
   - 技術スタック、アーキテクチャ、インフラセクションから抽出

2. **プロトコル検出結果の確認**
   - ドキュメントから1つ以上のプロトコルが特定できた場合:
     ```
     ✓ プロトコル検出: [Kafka/MQTT/...]
     ```
     → Phase 3へ進む

   - ドキュメントから特定できなかった場合:
     ```
     ⚠ ドキュメントからプロトコルを特定できませんでした
     → Phase 2でフォールバック検出を実行します
     ```
     → Phase 2へ進む

3. **プロジェクト構造のスキャン**
   ```bash
   tree -L 3 -I 'node_modules|venv|.git|__pycache__|vendor|target' 2>/dev/null

   find . -maxdepth 3 -type d \
     -not -path '*/node_modules/*' \
     -not -path '*/venv/*' \
     -not -path '*/.git/*' \
     -not -path '*/__pycache__/*' \
     -not -path '*/vendor/*' \
     -not -path '*/target/*' \
     2>/dev/null | head -50

   find . -maxdepth 4 -type d \( -name 'src' -o -name 'app' -o -name 'services' -o -name 'handlers' -o -name 'consumers' -o -name 'producers' \) 2>/dev/null
   ```

4. **出力先の確認**
   - ユーザーに出力ファイル名を確認 (デフォルト: `asyncapi.yaml`)
   - 既存ファイルがある場合は上書き確認

---

### Phase 2: プロトコル検出 (フォールバック)

**目的:** Phase 1で特定できなかった場合、設定ファイルからプロトコルを検出する

**注意:** Phase 1で特定できた場合、このPhaseはスキップして Phase 3へ進む

#### 検出対象と設定ファイル

| 基盤/プロトコル | 検出ファイル | 検索パターン |
|---|---|---|
| Kafka | `package.json`, `pom.xml`, `build.gradle`, `go.mod`, `requirements.txt`, `pyproject.toml` | `kafka`, `kafkajs`, `spring-kafka`, `segmentio/kafka-go`, `confluent-kafka` |
| RabbitMQ/AMQP | 同上 | `rabbitmq`, `amqp`, `amqplib`, `spring-amqp` |
| MQTT | 同上 | `mqtt`, `paho-mqtt`, `hbmqtt` |
| NATS | 同上 | `nats`, `nats.js`, `nats.go` |
| Redis Streams | 同上 | `redis`, `ioredis`, `spring-data-redis` |
| AWS SNS/SQS | 同上 | `sns`, `sqs`, `aws-sdk`, `boto3` |
| WebSocket | 同上 | `websocket`, `ws`, `socket.io`, `spring-websocket` |

#### 検出手順

1. **設定ファイルの検索**
   ```bash
   find . -maxdepth 2 \( \
     -name 'package.json' -o \
     -name 'requirements.txt' -o \
     -name 'pyproject.toml' -o \
     -name 'pom.xml' -o \
     -name 'build.gradle' -o \
     -name 'go.mod' -o \
     -name 'Gemfile' -o \
     -name 'composer.json' \
   \) -type f 2>/dev/null
   ```

2. **設定ファイルの読み取りと検索**
   - 見つかった設定ファイルを順に読み込み、上記キーワードを検索

3. **検出できなかった場合**
   - ユーザーに使用プロトコルを質問
   - または、汎用的なパターンで可能な限り抽出を試みる

---

### Phase 3: リファレンスファイルの読み込み

**目的:** 検出されたプロトコルに対応するリファレンスのみを読み込む

1. **プロトコル別リファレンスの読み込み**

   | 検出されたプロトコル | 読み込むリファレンス |
   |---|---|
   | Kafka | `references/protocols/kafka.md` |
   | RabbitMQ/AMQP | `references/protocols/amqp.md` |
   | MQTT | `references/protocols/mqtt.md` |
   | NATS | `references/protocols/nats.md` |
   | Redis Streams | `references/protocols/redis-streams.md` |
   | AWS SNS/SQS | `references/protocols/aws-sns-sqs.md` |
   | WebSocket | `references/protocols/websocket.md` |

   **重要:** Progressive Disclosure設計に従い、検出されたプロトコルのリファレンス**のみ**を読み込むこと。

2. **AsyncAPIスキーマリファレンスの読み込み**

   全プロトコル共通で `references/asyncapi-schema.md` を読み込む:
   - AsyncAPI 3.0.0 の基本構造
   - Channels / Operations / Messages
   - Bindings の取り扱い

3. **読み込み確認**
   ```
   ✓ リファレンス読み込み完了:
     - references/protocols/[protocol].md
     - references/asyncapi-schema.md
   ```

---

### Phase 4: チャンネル/オペレーション抽出

**目的:** プロトコル固有のパターンを使用してチャンネルとオペレーションを抽出する

1. **ルーティング/購読/発行ファイルの特定**
   - リファレンスの「チャンネル定義ファイルの典型的な場所」セクションを確認
   - リファレンスに記載されたGlobパターンを使用

2. **チャンネル定義の検索**
   - リファレンスの「チャンネル定義パターン」セクションを確認
   - リファレンスに記載されたGrepパターンを使用

3. **主要なメッセージハンドラ/プロデューサの読み込み**
   - 検出されたファイルの中から重要なファイル(3-5個程度)を選択して読み込む

---

### Phase 5: メッセージ/スキーマ情報の抽出

**目的:** メッセージペイロード/ヘッダーのスキーマを推定する

1. **型定義・モデルファイルの検索**
   - リファレンスの「ペイロード抽出」「メッセージスキーマ推定」セクションを確認
   - リファレンスに記載された型定義ファイルの場所とパターンを使用

2. **バリデーション定義の検索**
   - リファレンスに記載されたバリデーションライブラリパターンを使用
   - 型マッピング表を参照してAsyncAPIスキーマに変換

3. **主要なモデルファイルの読み込み**
   - 重要なモデル/スキーマファイル(3-5個程度)を読み込む

---

### Phase 6: AsyncAPI仕様書の生成

**目的:** 収集した情報を基にAsyncAPI 3.0.0形式のYAMLを生成する

#### 6.1 基本構造の作成

```yaml
asyncapi: 3.0.0
info:
  title: <プロジェクト名>
  version: <バージョン>
  description: <プロジェクト説明>
  contact:
    name: <連絡先名>
    email: <メールアドレス>

defaultContentType: application/json

servers:
  production:
    host: <host>
    protocol: <protocol>
    description: 本番環境

channels:
  # ここにチャンネルを追加

operations:
  # ここに送受信オペレーションを追加

components:
  schemas:
    # ここにスキーマ定義を追加
  messages:
    # ここにメッセージ定義を追加
  securitySchemes:
    # ここにセキュリティスキームを追加
```

#### 6.2 チャンネルの追加

```yaml
channels:
  user/signedup:
    description: ユーザー登録イベント
    messages:
      userSignedUp:
        $ref: '#/components/messages/UserSignedUp'
```

#### 6.3 オペレーションの追加

```yaml
operations:
  receiveUserSignedUp:
    action: receive
    channel:
      $ref: '#/channels/user/signedup'
    messages:
      - $ref: '#/components/messages/UserSignedUp'
```

#### 6.4 メッセージとスキーマの定義

```yaml
components:
  messages:
    UserSignedUp:
      name: UserSignedUp
      title: User Signed Up
      payload:
        $ref: '#/components/schemas/User'
  schemas:
    User:
      type: object
      required:
        - id
        - email
      properties:
        id:
          type: string
        email:
          type: string
          format: email
```

#### 6.5 プロトコルバインディング

- 該当プロトコルの binding を `servers`, `channels`, `operations`, `messages` に追加
- 具体的なキーは protocol reference に従う

#### 6.6 ファイル出力

```bash
Write: <出力ファイル名>
```

---

## ベストプラクティス

### 1. 情報の優先順位

1. **明示的な型定義・アノテーション** (TypeScript型、Pydantic、Java DTO等)
2. **バリデーションライブラリ**
3. **フレームワークの自動生成機能**
4. **コード内の実装**
5. **推測**

### 2. 不明な情報の扱い

- スキーマが不明な場合、`type: object` とする
- 説明が不明な場合は省略する
- チャンネル/オペレーションが多すぎる場合(50以上)、主要なものに絞る

### 3. セキュリティ

- 認証が必要な場合は `security` と `securitySchemes` を設定
- 機密情報を examples に含めない

### 4. YAMLフォーマット

- インデントは2スペース
- 配列は `- ` で表記
- 文字列に特殊文字がある場合は引用符で囲む

---

## トラブルシューティング

### プロトコルが検出されない場合

1. ユーザーに使用プロトコルを確認
2. 手動でリファレンスファイルを読み込み
3. 汎用的なパターンでチャンネル/メッセージを検索

### チャンネルが見つからない場合

1. プロデューサ/コンシューマの場所をユーザーに確認
2. より広範なGlobパターンで検索
3. `publish(`, `subscribe(`, `send(`, `emit(`, `on(` 等を検索

### スキーマ情報が不足している場合

1. 基本的なスキーマのみを定義
2. ユーザーに追加情報を質問
3. 後で手動で編集できることを伝える

---

## 制限事項

- HTTP RESTは対象外 (AsyncAPIはメッセージ駆動API向け)
- 複雑なスキーマ(再帰的定義等)は簡略化される場合がある
- カスタムバリデーションロジックは反映されない場合がある

---

## 参考リソース

- [AsyncAPI 3.0.0 Specification](https://www.asyncapi.com/docs/reference/specification/v3.0.0)
- [AsyncAPI Examples](https://www.asyncapi.com/docs/reference/examples)
