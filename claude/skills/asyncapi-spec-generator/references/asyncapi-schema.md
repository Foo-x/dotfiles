# AsyncAPI 3.0.0 スキーマリファレンス

## 最小仕様テンプレート

```yaml
asyncapi: 3.0.0
info:
  title: API Title
  version: 1.0.0
  description: API の説明
  contact:
    name: API Support
    email: support@example.com

defaultContentType: application/json

servers:
  production:
    host: broker.example.com
    protocol: kafka
    description: 本番環境

channels:
  user/signedup:
    description: ユーザー登録イベント
    messages:
      userSignedUp:
        $ref: '#/components/messages/UserSignedUp'

operations:
  receiveUserSignedUp:
    action: receive
    channel:
      $ref: '#/channels/user/signedup'
    messages:
      - $ref: '#/components/messages/UserSignedUp'

components:
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
  messages:
    UserSignedUp:
      name: UserSignedUp
      title: User Signed Up
      payload:
        $ref: '#/components/schemas/User'
```

## 主要フィールド

- `asyncapi`: 仕様バージョン (3.0.0)
- `info`: タイトル/説明/バージョン/連絡先
- `servers`: 接続先とプロトコル
- `channels`: チャンネル定義
- `operations`: 送受信オペレーション定義
- `components`: 再利用要素 (schemas/messages/securitySchemes)
- `defaultContentType`: 既定のペイロード種別

## バインディング

AsyncAPIでは `bindings` を以下のオブジェクトに追加可能:
- `servers[*].bindings`
- `channels[*].bindings`
- `operations[*].bindings`
- `components.messages[*].bindings`

プロトコル固有のキーは各プロトコルのリファレンスに従うこと。
