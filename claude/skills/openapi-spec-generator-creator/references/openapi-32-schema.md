# OpenAPI 3.2 スキーマリファレンス

このドキュメントは、OpenAPI 3.2仕様の構造とフレームワーク別のコード検出パターンを定義します。

## OpenAPI 3.2 基本構造

### 必須フィールド

```yaml
openapi: 3.2.0  # 固定値
info:
  title: string  # API名
  version: string  # APIバージョン
paths:
  # エンドポイント定義
```

### info オブジェクト

```yaml
info:
  title: "My API"
  version: "1.0.0"
  summary: "短い説明（オプション）"
  description: "詳細な説明（オプション、Markdown対応）"
  termsOfService: "https://example.com/terms"  # オプション
  # contact: 含めない（計画により除外）
  # license: 含めない（計画により除外）
```

**重要制約:**
- `contact`フィールドは絶対に含めない
- `license`フィールドは絶対に含めない

### servers オブジェクト

```yaml
servers:
  - url: "https://api.example.com/v1"
    description: "本番環境"
  - url: "https://staging-api.example.com"
    description: "ステージング環境"
  - url: "http://localhost:{port}"
    description: "ローカル開発環境"
    variables:
      port:
        default: "3000"
        enum:
          - "3000"
          - "8080"
        description: "サーバーポート"
```

### paths オブジェクト

```yaml
paths:
  /users:
    get:
      summary: "ユーザー一覧取得"
      description: "全ユーザーを取得します"
      operationId: "getUsers"
      tags:
        - users
      parameters:
        - name: limit
          in: query
          description: "取得件数"
          required: false
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 10
      responses:
        "200":
          description: "成功"
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: "#/components/schemas/User"
        "400":
          description: "リクエストエラー"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Error"
    post:
      summary: "ユーザー作成"
      operationId: "createUser"
      tags:
        - users
      requestBody:
        description: "作成するユーザー情報"
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/CreateUserRequest"
      responses:
        "201":
          description: "作成成功"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/User"

  /users/{userId}:
    parameters:
      - name: userId
        in: path
        description: "ユーザーID"
        required: true
        schema:
          type: integer
          format: int64
    get:
      summary: "ユーザー詳細取得"
      operationId: "getUserById"
      tags:
        - users
      responses:
        "200":
          description: "成功"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/User"
        "404":
          description: "ユーザーが見つかりません"
```

### components オブジェクト

```yaml
components:
  schemas:
    User:
      type: object
      required:
        - id
        - username
        - email
      properties:
        id:
          type: integer
          format: int64
          description: "ユーザーID"
          example: 12345
        username:
          type: string
          minLength: 3
          maxLength: 30
          pattern: "^[a-zA-Z0-9_]+$"
          description: "ユーザー名"
          example: "john_doe"
        email:
          type: string
          format: email
          description: "メールアドレス"
          example: "john@example.com"
        createdAt:
          type: string
          format: date-time
          description: "作成日時"
          example: "2024-01-01T12:00:00Z"
        profile:
          $ref: "#/components/schemas/UserProfile"

    UserProfile:
      type: object
      properties:
        bio:
          type: string
          maxLength: 500
        avatar:
          type: string
          format: uri

    CreateUserRequest:
      type: object
      required:
        - username
        - email
        - password
      properties:
        username:
          type: string
          minLength: 3
          maxLength: 30
        email:
          type: string
          format: email
        password:
          type: string
          format: password
          minLength: 8

    Error:
      type: object
      required:
        - message
      properties:
        message:
          type: string
          description: "エラーメッセージ"
        code:
          type: string
          description: "エラーコード"
          example: "VALIDATION_ERROR"
        details:
          type: object
          additionalProperties: true

  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: "JWTトークン認証"

    apiKey:
      type: apiKey
      in: header
      name: X-API-Key
      description: "APIキー認証"

    oauth2:
      type: oauth2
      flows:
        authorizationCode:
          authorizationUrl: https://example.com/oauth/authorize
          tokenUrl: https://example.com/oauth/token
          scopes:
            read: "読み取り権限"
            write: "書き込み権限"
            admin: "管理者権限"

  parameters:
    LimitParam:
      name: limit
      in: query
      description: "取得件数"
      schema:
        type: integer
        minimum: 1
        maximum: 100
        default: 10

    OffsetParam:
      name: offset
      in: query
      description: "オフセット"
      schema:
        type: integer
        minimum: 0
        default: 0

  responses:
    NotFound:
      description: "リソースが見つかりません"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/Error"

    Unauthorized:
      description: "認証エラー"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/Error"

security:
  - bearerAuth: []

tags:
  - name: users
    description: "ユーザー管理API"
  - name: posts
    description: "投稿管理API"
```

## フレームワーク別検出パターン

### Node.js / TypeScript

#### Express

**ルート検出パターン:**
```javascript
// app.METHOD(path, handler)
app.get('/api/users', handler);
app.post('/api/users', handler);
app.put('/api/users/:id', handler);
app.patch('/api/users/:id', handler);
app.delete('/api/users/:id', handler);

// router.METHOD(path, handler)
const router = express.Router();
router.get('/users', handler);

// app.route(path).METHOD(handler)
app.route('/users')
  .get(handler)
  .post(handler);
```

**パラメータ形式:**
- パスパラメータ: `:paramName`
- 検出: `/:(\w+)/g`

#### NestJS

**ルート検出パターン:**
```typescript
// デコレータベース
@Controller('users')
export class UsersController {
  @Get()
  @Get(':id')
  @Post()
  @Put(':id')
  @Patch(':id')
  @Delete(':id')

  // リクエストボディ
  @Post()
  create(@Body() dto: CreateUserDto) {}

  // パスパラメータ
  @Get(':id')
  findOne(@Param('id') id: string) {}

  // クエリパラメータ
  @Get()
  findAll(@Query('limit') limit: number) {}
}
```

**型定義検出:**
```typescript
// DTOs
export class CreateUserDto {
  @IsString()
  @MinLength(3)
  username: string;

  @IsEmail()
  email: string;
}

// Interfaces
export interface User {
  id: number;
  username: string;
  email: string;
}
```

#### Fastify

**ルート検出パターン:**
```javascript
fastify.get('/users', opts, handler);
fastify.post('/users', opts, handler);

// スキーマ定義
fastify.post('/users', {
  schema: {
    body: {
      type: 'object',
      required: ['username'],
      properties: {
        username: { type: 'string' }
      }
    },
    response: {
      201: {
        type: 'object',
        properties: {
          id: { type: 'number' }
        }
      }
    }
  }
}, handler);
```

### Python

#### FastAPI

**ルート検出パターン:**
```python
# デコレータベース
@app.get("/users")
@app.post("/users")
@app.put("/users/{user_id}")
@app.patch("/users/{user_id}")
@app.delete("/users/{user_id}")

# パスパラメータ
@app.get("/users/{user_id}")
async def get_user(user_id: int):
    pass

# クエリパラメータ
@app.get("/users")
async def list_users(limit: int = 10, offset: int = 0):
    pass

# リクエストボディ
@app.post("/users")
async def create_user(user: CreateUserRequest):
    pass
```

**Pydanticモデル検出:**
```python
from pydantic import BaseModel, EmailStr, Field

class User(BaseModel):
    id: int
    username: str = Field(..., min_length=3, max_length=30)
    email: EmailStr
    created_at: datetime

class CreateUserRequest(BaseModel):
    username: str
    email: EmailStr
    password: str = Field(..., min_length=8)
```

#### Flask

**ルート検出パターン:**
```python
@app.route('/users', methods=['GET'])
@app.route('/users', methods=['POST'])
@app.route('/users/<int:user_id>', methods=['GET'])

# Blueprint
bp = Blueprint('users', __name__)
@bp.route('/users', methods=['GET'])
```

#### Django REST Framework

**ルート検出パターン:**
```python
# ViewSet
class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

# APIView
class UserList(APIView):
    def get(self, request):
        pass

    def post(self, request):
        pass

# urls.py
urlpatterns = [
    path('users/', UserList.as_view()),
    path('users/<int:pk>/', UserDetail.as_view()),
]
```

**Serializer検出:**
```python
from rest_framework import serializers

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'created_at']

class CreateUserSerializer(serializers.Serializer):
    username = serializers.CharField(min_length=3, max_length=30)
    email = serializers.EmailField()
```

### Go

#### Gin

**ルート検出パターン:**
```go
r := gin.Default()
r.GET("/users", handler)
r.POST("/users", handler)
r.PUT("/users/:id", handler)
r.PATCH("/users/:id", handler)
r.DELETE("/users/:id", handler)

// グループ
userGroup := r.Group("/api/users")
{
    userGroup.GET("", listUsers)
    userGroup.POST("", createUser)
}
```

**構造体検出:**
```go
type User struct {
    ID        uint      `json:"id" example:"1"`
    Username  string    `json:"username" binding:"required,min=3,max=30"`
    Email     string    `json:"email" binding:"required,email"`
    CreatedAt time.Time `json:"created_at"`
}

type CreateUserRequest struct {
    Username string `json:"username" binding:"required,min=3"`
    Email    string `json:"email" binding:"required,email"`
    Password string `json:"password" binding:"required,min=8"`
}
```

#### Echo

**ルート検出パターン:**
```go
e := echo.New()
e.GET("/users", handler)
e.POST("/users", handler)
e.PUT("/users/:id", handler)
```

### Java / Kotlin

#### Spring Boot

**ルート検出パターン:**
```java
@RestController
@RequestMapping("/api/users")
public class UserController {
    @GetMapping
    @GetMapping("/{id}")
    @PostMapping
    @PutMapping("/{id}")
    @PatchMapping("/{id}")
    @DeleteMapping("/{id}")

    @PostMapping
    public ResponseEntity<User> createUser(@RequestBody @Valid CreateUserRequest request) {
        // ...
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getUser(@PathVariable Long id) {
        // ...
    }
}
```

**モデル検出:**
```java
public class User {
    private Long id;

    @NotNull
    @Size(min = 3, max = 30)
    private String username;

    @Email
    private String email;

    private LocalDateTime createdAt;
}

public record CreateUserRequest(
    @NotNull @Size(min = 3) String username,
    @Email String email,
    @NotNull @Size(min = 8) String password
) {}
```

### Ruby

#### Rails

**ルート検出パターン:**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :users
  # 展開すると:
  # GET    /users
  # POST   /users
  # GET    /users/:id
  # PUT    /users/:id
  # PATCH  /users/:id
  # DELETE /users/:id

  get '/users', to: 'users#index'
  post '/users', to: 'users#create'
  get '/users/:id', to: 'users#show'
end
```

**モデル検出:**
```ruby
# app/models/user.rb
class User < ApplicationRecord
  validates :username, presence: true, length: { minimum: 3, maximum: 30 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
```

### PHP

#### Laravel

**ルート検出パターン:**
```php
// routes/api.php
Route::get('/users', [UserController::class, 'index']);
Route::post('/users', [UserController::class, 'store']);
Route::get('/users/{id}', [UserController::class, 'show']);
Route::put('/users/{id}', [UserController::class, 'update']);
Route::delete('/users/{id}', [UserController::class, 'destroy']);

// リソースルート
Route::apiResource('users', UserController::class);
```

**バリデーション検出:**
```php
class CreateUserRequest extends FormRequest
{
    public function rules()
    {
        return [
            'username' => 'required|string|min:3|max:30',
            'email' => 'required|email',
            'password' => 'required|string|min:8',
        ];
    }
}
```

### Rust

#### Actix-web

**ルート検出パターン:**
```rust
HttpServer::new(|| {
    App::new()
        .route("/users", web::get().to(list_users))
        .route("/users", web::post().to(create_user))
        .route("/users/{id}", web::get().to(get_user))
        .route("/users/{id}", web::put().to(update_user))
        .route("/users/{id}", web::delete().to(delete_user))
})
```

**構造体検出:**
```rust
use serde::{Deserialize, Serialize};

#[derive(Serialize)]
struct User {
    id: i64,
    username: String,
    email: String,
    created_at: DateTime<Utc>,
}

#[derive(Deserialize)]
struct CreateUserRequest {
    username: String,
    email: String,
    password: String,
}
```

## HTTPメソッドとレスポンスコードのマッピング

### 標準的なレスポンスコード

| メソッド | 成功コード | 一般的なエラーコード |
|---------|-----------|-------------------|
| GET     | 200       | 404, 401, 403 |
| POST    | 201       | 400, 401, 403, 409 |
| PUT     | 200       | 400, 401, 403, 404 |
| PATCH   | 200       | 400, 401, 403, 404 |
| DELETE  | 204       | 401, 403, 404 |

### エラーレスポンス定義

```yaml
responses:
  "400":
    description: "バリデーションエラー"
    content:
      application/json:
        schema:
          $ref: "#/components/schemas/ValidationError"
  "401":
    description: "認証エラー"
    content:
      application/json:
        schema:
          $ref: "#/components/schemas/Error"
  "403":
    description: "権限エラー"
    content:
      application/json:
        schema:
          $ref: "#/components/schemas/Error"
  "404":
    description: "リソースが見つかりません"
    content:
      application/json:
        schema:
          $ref: "#/components/schemas/Error"
  "409":
    description: "競合エラー（既存リソースと重複）"
    content:
      application/json:
        schema:
          $ref: "#/components/schemas/Error"
  "500":
    description: "サーバーエラー"
    content:
      application/json:
        schema:
          $ref: "#/components/schemas/Error"
```

## 型マッピング

### プログラミング言語からOpenAPIへの型変換

| 言語型 | OpenAPI型 | フォーマット |
|-------|----------|------------|
| string, str, String | string | - |
| int, i32, i64, Integer, Long | integer | int32/int64 |
| float, f32, f64, Float, Double | number | float/double |
| bool, Boolean | boolean | - |
| Date, LocalDate | string | date |
| DateTime, LocalDateTime, timestamp | string | date-time |
| UUID | string | uuid |
| URL, URI | string | uri |
| Email | string | email |
| byte[], Buffer | string | byte |
| binary | string | binary |

### 配列とオブジェクト

```yaml
# 配列
type: array
items:
  type: string

# オブジェクト配列
type: array
items:
  $ref: "#/components/schemas/User"

# オブジェクト
type: object
properties:
  key:
    type: string

# Map/Dictionary
type: object
additionalProperties:
  type: string
```

## ベストプラクティス

### 1. operationId の命名規則

```yaml
# 推奨: camelCase + リソース名 + 動作
operationId: listUsers
operationId: getUser
operationId: createUser
operationId: updateUser
operationId: deleteUser
```

### 2. タグの使用

```yaml
# エンドポイントをリソース別にグループ化
tags:
  - name: users
    description: ユーザー管理
  - name: posts
    description: 投稿管理
  - name: comments
    description: コメント管理
```

### 3. example の追加

```yaml
# 全てのスキーマプロパティに example を追加
properties:
  username:
    type: string
    example: "john_doe"
  email:
    type: string
    format: email
    example: "john@example.com"
```

### 4. description の充実

```yaml
# エンドポイント、パラメータ、スキーマに説明を追加
summary: "ユーザー一覧取得"
description: |
  ページネーション対応でユーザー一覧を取得します。
  limitとoffsetパラメータで取得範囲を指定できます。
```

### 5. 再利用可能なコンポーネント

```yaml
# 共通パラメータ、レスポンス、スキーマはcomponentsで定義
components:
  parameters:
    LimitParam:
      # 定義
  responses:
    NotFound:
      # 定義
  schemas:
    Error:
      # 定義
```

## OpenAPI 3.2 の新機能

### webhooks

```yaml
webhooks:
  newUser:
    post:
      summary: "新規ユーザー作成通知"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/User"
      responses:
        "200":
          description: "Webhook受信確認"
```

### jsonSchemaDialect

```yaml
# JSON Schema Draft 2020-12 を指定可能
jsonSchemaDialect: "https://json-schema.org/draft/2020-12/schema"
```

## バリデーションチェックリスト

生成したOpenAPI仕様書は以下を確認してください：

- [ ] `openapi: 3.2.0` が指定されている
- [ ] `info.title` と `info.version` が存在する
- [ ] `info.contact` は含まれていない
- [ ] `info.license` は含まれていない
- [ ] 全てのパスに最低1つのオペレーションがある
- [ ] 全てのオペレーションに `responses` が定義されている
- [ ] パスパラメータは `required: true` になっている
- [ ] スキーマの `required` フィールドが適切に設定されている
- [ ] YAML構文が正しい（インデント2スペース）
- [ ] 全ての `$ref` が有効なコンポーネントを参照している
