# Gin (Go) パターン

## フレームワーク検出

### 検出条件

1. `go.mod` に `github.com/gin-gonic/gin` の依存関係
2. `main.go`, `server.go` で `import "github.com/gin-gonic/gin"`

### 検出用 Grep パターン

```bash
Grep: "github.com/gin-gonic/gin" in go.mod
Grep: "github\\.com/gin-gonic/gin" in "*.go"
```

## ルーティング定義パターン

### 1. 基本的なルート定義

```go
package main

import "github.com/gin-gonic/gin"

func main() {
    r := gin.Default()

    r.GET("/users", getUsers)
    r.POST("/users", createUser)
    r.GET("/users/:id", getUser)
    r.PUT("/users/:id", updateUser)
    r.PATCH("/users/:id", patchUser)
    r.DELETE("/users/:id", deleteUser)

    r.Run(":8080")
}

func getUsers(c *gin.Context) {
    c.JSON(200, gin.H{"users": []string{}})
}
```

**Grep パターン:**
```
pattern: "\\.(GET|POST|PUT|PATCH|DELETE)\\s*\\(\\s*\"([^\"]+)\""
output_mode: content
glob: "*.go"
```

### 2. RouterGroup を使用したルート定義

```go
func main() {
    r := gin.Default()

    api := r.Group("/api")
    {
        v1 := api.Group("/v1")
        {
            users := v1.Group("/users")
            {
                users.GET("", getUsers)
                users.POST("", createUser)
                users.GET("/:id", getUser)
                users.PUT("/:id", updateUser)
                users.DELETE("/:id", deleteUser)
            }
        }
    }

    r.Run()
}
```

**Grep パターン:**
```
pattern: "\\.Group\\s*\\(\\s*\"([^\"]+)\""
```

### 3. Ginルーターファイルの典型的な場所

```
project/
├── main.go
├── routes/
│   ├── routes.go
│   ├── users.go
│   ├── posts.go
│   └── auth.go
├── handlers/
│   ├── user_handler.go
│   └── post_handler.go
└── controllers/
    └── user_controller.go
```

**Glob パターン:**
```
routes/**/*.go
handlers/**/*.go
controllers/**/*.go
api/**/*.go
```

## パラメータ抽出

### 1. パスパラメータ

```go
// :id がパスパラメータ
r.GET("/users/:id", func(c *gin.Context) {
    id := c.Param("id")
    c.JSON(200, gin.H{"id": id})
})

// 複数のパラメータ
r.GET("/posts/:postId/comments/:commentId", func(c *gin.Context) {
    postId := c.Param("postId")
    commentId := c.Param("commentId")
    c.JSON(200, gin.H{"postId": postId, "commentId": commentId})
})

// ワイルドカード
r.GET("/files/*filepath", func(c *gin.Context) {
    filepath := c.Param("filepath")
    c.String(200, filepath)
})
```

**抽出ルール:**
- `:paramName` 形式 → OpenAPI の `path` パラメータ
- `*paramName` 形式 → `path` パラメータ (wildcard)
- 型は基本的に `string` (コード内変換から型を推測)

### 2. クエリパラメータ

```go
r.GET("/users", func(c *gin.Context) {
    // デフォルト値あり
    page := c.DefaultQuery("page", "1")

    // デフォルト値なし
    limit := c.Query("limit")

    // 必須チェック
    search, exists := c.GetQuery("search")

    c.JSON(200, gin.H{"page": page, "limit": limit})
})
```

**抽出方法:**
- `c.Query()`, `c.DefaultQuery()`, `c.GetQuery()` を検索
- デフォルト値から `required` を判定

### 3. リクエストボディ

```go
type UserCreateRequest struct {
    Name  string `json:"name" binding:"required,min=1,max=100"`
    Email string `json:"email" binding:"required,email"`
    Age   int    `json:"age" binding:"min=0,max=150"`
}

r.POST("/users", func(c *gin.Context) {
    var req UserCreateRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(400, gin.H{"error": err.Error()})
        return
    }

    c.JSON(201, req)
})
```

## 構造体タグからのスキーマ抽出

### 1. JSON タグと Binding タグ

```go
type User struct {
    ID        uint      `json:"id"`
    Name      string    `json:"name" binding:"required,min=1,max=100"`
    Email     string    `json:"email" binding:"required,email"`
    Age       *int      `json:"age,omitempty" binding:"omitempty,min=0,max=150"`
    Password  string    `json:"-"` // JSONに含めない
    CreatedAt time.Time `json:"created_at"`
}

type UserResponse struct {
    ID        uint      `json:"id" example:"123"`
    Name      string    `json:"name" example:"John Doe"`
    Email     string    `json:"email" example:"john@example.com"`
    CreatedAt time.Time `json:"created_at"`
}
```

**Go型 → OpenAPI型マッピング:**

| Go型 | OpenAPI |
|-----|---------|
| `string` | `type: string` |
| `int`, `int32`, `int64`, `uint`, `uint32`, `uint64` | `type: integer` |
| `float32`, `float64` | `type: number` |
| `bool` | `type: boolean` |
| `time.Time` | `type: string, format: date-time` |
| `[]T`, `[...]T` | `type: array` |
| `map[string]T` | `type: object` |
| `*T` (ポインタ) | スキーマは同じ、required判定に影響 |

**Binding バリデーション → OpenAPI制約:**

| Binding | OpenAPI |
|---------|---------|
| `required` | `required` に追加 |
| `min=1,max=100` | 文字列: `minLength/maxLength`, 数値: `minimum/maximum` |
| `email` | `format: email` |
| `url` | `format: uri` |
| `uuid` | `format: uuid` |
| `omitempty` | `required` から除外 |
| `oneof=red green blue` | `enum: [red, green, blue]` |

### 2. Swag アノテーション (swaggo/swag)

```go
// GetUser godoc
// @Summary      ユーザー詳細取得
// @Description  IDでユーザーを取得
// @Tags         users
// @Accept       json
// @Produce      json
// @Param        id   path      int  true  "User ID"
// @Success      200  {object}  UserResponse
// @Failure      404  {object}  ErrorResponse
// @Router       /users/{id} [get]
func getUser(c *gin.Context) {
    id := c.Param("id")
    // 処理
}

// CreateUser godoc
// @Summary      ユーザー作成
// @Description  新しいユーザーを作成
// @Tags         users
// @Accept       json
// @Produce      json
// @Param        user  body      UserCreateRequest  true  "User data"
// @Success      201   {object}  UserResponse
// @Failure      400   {object}  ErrorResponse
// @Router       /users [post]
// @Security     BearerAuth
func createUser(c *gin.Context) {
    var req UserCreateRequest
    // 処理
}
```

**注意:** `swaggo/swag` を使用している場合、`swag init` で生成された
`docs/swagger.json` または `docs/swagger.yaml` から直接OpenAPI仕様を取得できます。

## レスポンススキーマ推定

### 1. c.JSON からの推定

```go
r.GET("/users/:id", func(c *gin.Context) {
    c.JSON(200, UserResponse{
        ID:        123,
        Name:      "John Doe",
        Email:     "john@example.com",
        CreatedAt: time.Now(),
    })
})

// gin.H (map) からの推定
r.GET("/health", func(c *gin.Context) {
    c.JSON(200, gin.H{
        "status": "ok",
        "timestamp": time.Now(),
    })
})
```

### 2. ステータスコード

```go
// 明示的なステータスコード
c.JSON(201, user)
c.JSON(404, gin.H{"error": "Not found"})
c.Status(204) // No Content

// AbortWithStatusJSON
c.AbortWithStatusJSON(400, gin.H{"error": "Bad request"})
```

## バリデーションライブラリ

### go-playground/validator (Ginデフォルト)

```go
import "github.com/go-playground/validator/v10"

type UserCreateRequest struct {
    Name     string   `json:"name" validate:"required,min=1,max=100"`
    Email    string   `json:"email" validate:"required,email"`
    Age      int      `json:"age" validate:"min=0,max=150"`
    Tags     []string `json:"tags" validate:"max=10,dive,min=1"`
    Status   string   `json:"status" validate:"oneof=active inactive pending"`
    Website  string   `json:"website" validate:"omitempty,url"`
}
```

## ミドルウェアからの認証情報抽出

### 1. JWT認証ミドルウェア

```go
import "github.com/golang-jwt/jwt/v5"

func AuthMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        authHeader := c.GetHeader("Authorization")
        if authHeader == "" {
            c.AbortWithStatusJSON(401, gin.H{"error": "Unauthorized"})
            return
        }

        // Bearer トークン検証
        tokenString := strings.TrimPrefix(authHeader, "Bearer ")
        // JWT検証処理

        c.Next()
    }
}

// 使用
authorized := r.Group("/api")
authorized.Use(AuthMiddleware())
{
    authorized.GET("/users", getUsers)
}
```

**OpenAPI セキュリティスキーム:**
```yaml
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

### 2. APIキー認証

```go
func APIKeyMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        apiKey := c.GetHeader("X-API-Key")
        if !isValidAPIKey(apiKey) {
            c.AbortWithStatusJSON(403, gin.H{"error": "Invalid API key"})
            return
        }
        c.Next()
    }
}
```

**OpenAPI セキュリティスキーム:**
```yaml
components:
  securitySchemes:
    apiKey:
      type: apiKey
      in: header
      name: X-API-Key
```

## 実装例

```go
package main

import (
    "net/http"
    "time"
    "github.com/gin-gonic/gin"
)

type User struct {
    ID        uint      `json:"id"`
    Name      string    `json:"name"`
    Email     string    `json:"email"`
    CreatedAt time.Time `json:"created_at"`
}

type UserCreateRequest struct {
    Name  string `json:"name" binding:"required,min=1,max=100"`
    Email string `json:"email" binding:"required,email"`
    Age   int    `json:"age" binding:"min=0,max=150"`
}

type PaginationResponse struct {
    Data       []User `json:"data"`
    Page       int    `json:"page"`
    Limit      int    `json:"limit"`
    TotalCount int64  `json:"total_count"`
}

type ErrorResponse struct {
    Code    int    `json:"code"`
    Message string `json:"message"`
}

func main() {
    r := gin.Default()

    api := r.Group("/api")
    {
        users := api.Group("/users")
        {
            users.GET("", getUsers)
            users.GET("/:id", getUser)
            users.POST("", createUser)
            users.PUT("/:id", updateUser)
            users.DELETE("/:id", deleteUser)
        }
    }

    r.Run(":8080")
}

func getUsers(c *gin.Context) {
    page := c.DefaultQuery("page", "1")
    limit := c.DefaultQuery("limit", "20")

    // データベースクエリ (省略)

    c.JSON(http.StatusOK, PaginationResponse{
        Data:       []User{},
        Page:       1,
        Limit:      20,
        TotalCount: 0,
    })
}

func getUser(c *gin.Context) {
    id := c.Param("id")

    // データベースクエリ (省略)
    // if not found:
    //   c.JSON(http.StatusNotFound, ErrorResponse{Code: 404, Message: "User not found"})

    c.JSON(http.StatusOK, User{
        ID:        123,
        Name:      "John Doe",
        Email:     "john@example.com",
        CreatedAt: time.Now(),
    })
}

func createUser(c *gin.Context) {
    var req UserCreateRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, ErrorResponse{
            Code:    400,
            Message: err.Error(),
        })
        return
    }

    // ユーザー作成処理

    c.JSON(http.StatusCreated, User{
        ID:        1,
        Name:      req.Name,
        Email:     req.Email,
        CreatedAt: time.Now(),
    })
}

func updateUser(c *gin.Context) {
    id := c.Param("id")
    var req UserCreateRequest

    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, ErrorResponse{
            Code:    400,
            Message: err.Error(),
        })
        return
    }

    // 更新処理

    c.JSON(http.StatusOK, User{})
}

func deleteUser(c *gin.Context) {
    id := c.Param("id")

    // 削除処理

    c.Status(http.StatusNoContent)
}
```

## 検出優先順位

1. **Swag アノテーション** (最優先 - `/docs/swagger.json` 直接利用可能)
2. **構造体の binding タグ**
3. **c.JSON() の引数型**
4. **関数名とパスからの推測** (最終手段)
