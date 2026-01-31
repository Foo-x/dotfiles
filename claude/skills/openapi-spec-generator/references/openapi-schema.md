# OpenAPI 3.2.x スキーマリファレンス

## 基本構造

OpenAPI 3.2.x仕様書の必須要素と推奨構造を定義します。

### 最小限の仕様書テンプレート

```yaml
openapi: 3.2.0
info:
  title: API Title
  version: 1.0.0
  description: API の説明
  contact:
    name: API Support
    email: support@example.com
  license:
    name: Apache 2.0
    url: https://www.apache.org/licenses/LICENSE-2.0.html

servers:
  - url: https://api.example.com/v1
    description: 本番環境
  - url: https://staging-api.example.com/v1
    description: ステージング環境

paths:
  /example:
    get:
      summary: 例示エンドポイント
      description: エンドポイントの詳細説明
      operationId: getExample
      tags:
        - Examples
      parameters:
        - name: id
          in: query
          description: リソースID
          required: false
          schema:
            type: string
      responses:
        '200':
          description: 成功レスポンス
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ExampleResponse'
        '400':
          description: バリデーションエラー
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

components:
  schemas:
    ExampleResponse:
      type: object
      required:
        - id
        - name
      properties:
        id:
          type: string
          description: リソースID
        name:
          type: string
          description: リソース名
        createdAt:
          type: string
          format: date-time
          description: 作成日時

    Error:
      type: object
      required:
        - code
        - message
      properties:
        code:
          type: integer
          format: int32
          description: エラーコード
        message:
          type: string
          description: エラーメッセージ
        details:
          type: array
          items:
            type: string
          description: エラー詳細

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
    apiKey:
      type: apiKey
      in: header
      name: X-API-Key

security:
  - bearerAuth: []
```

## OpenAPI 3.2.x の主要機能

### 1. JSON Schema 完全互換

OpenAPI 3.1+ では JSON Schema 2020-12 と完全互換:

```yaml
components:
  schemas:
    User:
      type: object
      properties:
        name:
          type: string
          minLength: 1
          maxLength: 100
        age:
          type: integer
          minimum: 0
          maximum: 150
        email:
          type: string
          format: email
        tags:
          type: array
          items:
            type: string
          uniqueItems: true
```

### 2. Webhooks サポート

```yaml
webhooks:
  newOrder:
    post:
      requestBody:
        description: 新規注文情報
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Order'
      responses:
        '200':
          description: Webhook受信確認
```

### 3. HTTPメソッドの定義

各エンドポイントで使用可能なHTTPメソッド:

- `get`: リソース取得
- `post`: リソース作成
- `put`: リソース全体更新
- `patch`: リソース部分更新
- `delete`: リソース削除
- `options`: 許可されたメソッドの確認
- `head`: レスポンスヘッダのみ取得
- `trace`: リクエストのループバックテスト

### 4. パラメータの場所 (in)

```yaml
parameters:
  - name: id
    in: path        # パスパラメータ
    required: true
    schema:
      type: string

  - name: page
    in: query       # クエリパラメータ
    schema:
      type: integer
      default: 1

  - name: X-API-Key
    in: header      # リクエストヘッダ
    required: true
    schema:
      type: string

  - name: sessionId
    in: cookie      # Cookie
    schema:
      type: string
```

### 5. リクエストボディ

```yaml
requestBody:
  description: ユーザー作成データ
  required: true
  content:
    application/json:
      schema:
        $ref: '#/components/schemas/CreateUserRequest'
      examples:
        basic:
          summary: 基本的な例
          value:
            name: John Doe
            email: john@example.com
        admin:
          summary: 管理者の例
          value:
            name: Admin User
            email: admin@example.com
            role: admin
    application/xml:
      schema:
        $ref: '#/components/schemas/CreateUserRequest'
```

### 6. レスポンス定義

```yaml
responses:
  '200':
    description: 成功
    headers:
      X-RateLimit-Limit:
        description: リクエスト上限
        schema:
          type: integer
      X-RateLimit-Remaining:
        description: 残りリクエスト数
        schema:
          type: integer
    content:
      application/json:
        schema:
          $ref: '#/components/schemas/User'
  '404':
    description: リソースが見つかりません
    content:
      application/json:
        schema:
          $ref: '#/components/schemas/Error'
```

### 7. セキュリティスキーム

```yaml
components:
  securitySchemes:
    # Bearer認証
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

    # APIキー
    apiKey:
      type: apiKey
      in: header
      name: X-API-Key

    # OAuth2
    oauth2:
      type: oauth2
      flows:
        authorizationCode:
          authorizationUrl: https://example.com/oauth/authorize
          tokenUrl: https://example.com/oauth/token
          scopes:
            read: リソース読み取り
            write: リソース書き込み

    # OpenID Connect
    openId:
      type: openIdConnect
      openIdConnectUrl: https://example.com/.well-known/openid-configuration

# グローバルセキュリティ
security:
  - bearerAuth: []

# エンドポイント固有のセキュリティ
paths:
  /public:
    get:
      security: []  # セキュリティなし
  /admin:
    get:
      security:
        - oauth2: [admin]  # OAuth2の特定スコープ
```

### 8. スキーマの再利用

```yaml
components:
  schemas:
    # ベーススキーマ
    BaseEntity:
      type: object
      required:
        - id
        - createdAt
      properties:
        id:
          type: string
          format: uuid
        createdAt:
          type: string
          format: date-time
        updatedAt:
          type: string
          format: date-time

    # 継承とマージ
    User:
      allOf:
        - $ref: '#/components/schemas/BaseEntity'
        - type: object
          required:
            - email
          properties:
            email:
              type: string
              format: email
            name:
              type: string

    # oneOf (いずれか)
    Pet:
      oneOf:
        - $ref: '#/components/schemas/Dog'
        - $ref: '#/components/schemas/Cat'
      discriminator:
        propertyName: petType

    # anyOf (1つ以上)
    SearchResult:
      anyOf:
        - $ref: '#/components/schemas/User'
        - $ref: '#/components/schemas/Organization'

  parameters:
    # 再利用可能なパラメータ
    PageParam:
      name: page
      in: query
      schema:
        type: integer
        minimum: 1
        default: 1

    LimitParam:
      name: limit
      in: query
      schema:
        type: integer
        minimum: 1
        maximum: 100
        default: 20

  responses:
    # 再利用可能なレスポンス
    NotFound:
      description: リソースが見つかりません
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'

    Unauthorized:
      description: 認証が必要です
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
```

### 9. タグによるグループ化

```yaml
tags:
  - name: Users
    description: ユーザー管理API
  - name: Organizations
    description: 組織管理API
  - name: Auth
    description: 認証API

paths:
  /users:
    get:
      tags:
        - Users
      summary: ユーザー一覧取得
```

### 10. 外部ドキュメント

```yaml
externalDocs:
  description: 詳細なAPIドキュメント
  url: https://docs.example.com/api

paths:
  /users:
    get:
      externalDocs:
        description: ユーザーAPIガイド
        url: https://docs.example.com/api/users
```

## データ型とフォーマット

### 基本型

| 型 | フォーマット | 説明 | 例 |
|---|------------|------|-----|
| `string` | - | 文字列 | `"hello"` |
| `string` | `date` | 日付 | `"2024-01-31"` |
| `string` | `date-time` | 日時 | `"2024-01-31T12:00:00Z"` |
| `string` | `email` | メールアドレス | `"user@example.com"` |
| `string` | `uri` | URI | `"https://example.com"` |
| `string` | `uuid` | UUID | `"123e4567-e89b-12d3-a456-426614174000"` |
| `integer` | `int32` | 32bit整数 | `123` |
| `integer` | `int64` | 64bit整数 | `9223372036854775807` |
| `number` | `float` | 浮動小数点 | `3.14` |
| `number` | `double` | 倍精度浮動小数点 | `3.141592653589793` |
| `boolean` | - | 真偽値 | `true`, `false` |
| `array` | - | 配列 | `[1, 2, 3]` |
| `object` | - | オブジェクト | `{"key": "value"}` |

### バリデーション

```yaml
components:
  schemas:
    ValidationExample:
      type: object
      properties:
        # 文字列バリデーション
        username:
          type: string
          minLength: 3
          maxLength: 20
          pattern: '^[a-zA-Z0-9_]+$'

        # 数値バリデーション
        age:
          type: integer
          minimum: 0
          maximum: 150
          multipleOf: 1

        price:
          type: number
          minimum: 0
          exclusiveMinimum: true  # 0は含まない

        # 配列バリデーション
        tags:
          type: array
          minItems: 1
          maxItems: 10
          uniqueItems: true
          items:
            type: string

        # Enum
        status:
          type: string
          enum:
            - pending
            - active
            - completed
            - cancelled

        # Nullable (OpenAPI 3.1+)
        middleName:
          type: [string, "null"]

        # ReadOnly / WriteOnly
        id:
          type: string
          readOnly: true   # レスポンスのみ
        password:
          type: string
          writeOnly: true  # リクエストのみ
```

## ベストプラクティス

### 1. 一貫性のある命名規則

- エンドポイント: ケバブケース (`/user-profiles`)
- プロパティ名: キャメルケース (`firstName`) またはスネークケース (`first_name`)
- operationId: キャメルケース (`getUserProfile`)

### 2. バージョニング

```yaml
# URLパスによるバージョニング (推奨)
servers:
  - url: https://api.example.com/v1

# または info.version で管理
info:
  version: 1.0.0
```

### 3. エラーレスポンスの統一

```yaml
components:
  schemas:
    Error:
      type: object
      required:
        - code
        - message
      properties:
        code:
          type: integer
        message:
          type: string
        errors:
          type: array
          items:
            type: object
            properties:
              field:
                type: string
              message:
                type: string
```

### 4. ページネーション

```yaml
paths:
  /users:
    get:
      parameters:
        - $ref: '#/components/parameters/PageParam'
        - $ref: '#/components/parameters/LimitParam'
      responses:
        '200':
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
                  pagination:
                    type: object
                    properties:
                      page:
                        type: integer
                      limit:
                        type: integer
                      total:
                        type: integer
                      totalPages:
                        type: integer
```

### 5. コンテンツネゴシエーション

複数のレスポンスフォーマットをサポート:

```yaml
responses:
  '200':
    content:
      application/json:
        schema:
          $ref: '#/components/schemas/User'
      application/xml:
        schema:
          $ref: '#/components/schemas/User'
      text/csv:
        schema:
          type: string
```

## 自動生成時の注意点

1. **operationId の一意性**: 各エンドポイントのoperationIdは一意にする
2. **$ref の解決**: コンポーネントへの参照は `#/components/schemas/SchemaName` 形式
3. **必須フィールド**: `openapi`, `info.title`, `info.version`, `paths` は必須
4. **YAMLフォーマット**: インデントは2スペース、配列は `-` で表記
5. **description の充実**: 可能な限りエンドポイントとパラメータに説明を追加
