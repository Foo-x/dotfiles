# Echo (Go) パターン

## フレームワーク検出

### 検出条件

1. `go.mod` に `github.com/labstack/echo` の依存関係
2. `main.go`, `server.go` で `import "github.com/labstack/echo/v4"`

### 検出用 Grep パターン

```bash
Grep: "github.com/labstack/echo" in go.mod
Grep: "github\\.com/labstack/echo" in "*.go"
```

## ルーティング定義パターン

### 1. 基本的なルート定義

```go
package main

import (
    "net/http"
    "github.com/labstack/echo/v4"
)

func main() {
    e := echo.New()

    e.GET("/users", getUsers)
    e.POST("/users", createUser)
    e.GET("/users/:id", getUser)
    e.PUT("/users/:id", updateUser)
    e.PATCH("/users/:id", patchUser)
    e.DELETE("/users/:id", deleteUser)

    e.Start(":8080")
}

func getUsers(c echo.Context) error {
    return c.JSON(http.StatusOK, map[string]interface{}{"users": []string{}})
}
```

**Grep パターン:**
```
pattern: "\\.(GET|POST|PUT|PATCH|DELETE)\\s*\\(\\s*\"([^\"]+)\""
output_mode: content
glob: "*.go"
```

### 2. Group を使用したルート定義

```go
func main() {
    e := echo.New()

    api := e.Group("/api")
    {
        v1 := api.Group("/v1")
        {
            users := v1.Group("/users")
            users.GET("", getUsers)
            users.POST("", createUser)
            users.GET("/:id", getUser)
            users.PUT("/:id", updateUser)
            users.DELETE("/:id", deleteUser)
        }
    }

    e.Start(":8080")
}
```

**Grep パターン:**
```
pattern: "\\.Group\\s*\\(\\s*\"([^\"]+)\""
```

### 3. Echoルーターファイルの典型的な場所

```
project/
├── main.go
├── routes/
│   ├── routes.go
│   ├── users.go
│   └── posts.go
├── handlers/
│   ├── user_handler.go
│   └── post_handler.go
```

**Glob パターン:**
```
routes/**/*.go
handlers/**/*.go
api/**/*.go
```

## パラメータ抽出

### 1. パスパラメータ

```go
// :id がパスパラメータ
e.GET("/users/:id", func(c echo.Context) error {
    id := c.Param("id")
    return c.JSON(http.StatusOK, map[string]string{"id": id})
})

// 複数のパラメータ
e.GET("/posts/:postId/comments/:commentId", func(c echo.Context) error {
    postId := c.Param("postId")
    commentId := c.Param("commentId")
    return c.JSON(http.StatusOK, map[string]string{
        "postId": postId,
        "commentId": commentId,
    })
})

// ワイルドカード
e.GET("/files/*", func(c echo.Context) error {
    filepath := c.Param("*")
    return c.String(http.StatusOK, filepath)
})
```

**抽出ルール:**
- `:paramName` 形式 → OpenAPI の `path` パラメータ
- `*` 形式 → `path` パラメータ (wildcard)

### 2. クエリパラメータ

```go
e.GET("/users", func(c echo.Context) error {
    // 通常のクエリパラメータ
    page := c.QueryParam("page")

    // デフォルト値付き
    limit := c.QueryParam("limit")
    if limit == "" {
        limit = "20"
    }

    // 配列パラメータ
    tags := c.QueryParams()["tag"]

    return c.JSON(http.StatusOK, map[string]interface{}{
        "page": page,
        "limit": limit,
        "tags": tags,
    })
})
```

**抽出方法:**
- `c.QueryParam()`, `c.QueryParams()` を検索
- デフォルト値チェックから `required` を判定

### 3. リクエストボディ

```go
type UserCreateRequest struct {
    Name  string `json:"name" validate:"required,min=1,max=100"`
    Email string `json:"email" validate:"required,email"`
    Age   int    `json:"age" validate:"min=0,max=150"`
}

e.POST("/users", func(c echo.Context) error {
    req := new(UserCreateRequest)
    if err := c.Bind(req); err != nil {
        return c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
    }

    if err := c.Validate(req); err != nil {
        return c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
    }

    return c.JSON(http.StatusCreated, req)
})
```

### 4. ヘッダーパラメータ

```go
e.GET("/users", func(c echo.Context) error {
    apiKey := c.Request().Header.Get("X-API-Key")
    auth := c.Request().Header.Get("Authorization")

    return c.JSON(http.StatusOK, map[string]string{"key": apiKey})
})
```

## 構造体タグからのスキーマ抽出

### 1. JSON タグと Validate タグ

```go
type User struct {
    ID        uint      `json:"id"`
    Name      string    `json:"name" validate:"required,min=1,max=100"`
    Email     string    `json:"email" validate:"required,email"`
    Age       *int      `json:"age,omitempty" validate:"omitempty,min=0,max=150"`
    CreatedAt time.Time `json:"created_at"`
}

type UserResponse struct {
    ID        uint      `json:"id"`
    Name      string    `json:"name"`
    Email     string    `json:"email"`
    CreatedAt time.Time `json:"created_at"`
}
```

**Go型 → OpenAPI型マッピング:**
- Ginと同じマッピングを使用

**Validate タグ → OpenAPI制約:**
- go-playground/validator を使用 (Ginと同様)

### 2. Echoswagger アノテーション

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
func getUser(c echo.Context) error {
    id := c.Param("id")
    // 処理
}
```

## レスポンススキーマ推定

### 1. c.JSON からの推定

```go
e.GET("/users/:id", func(c echo.Context) error {
    return c.JSON(http.StatusOK, UserResponse{
        ID:        123,
        Name:      "John Doe",
        Email:     "john@example.com",
        CreatedAt: time.Now(),
    })
})

// map からの推定
e.GET("/health", func(c echo.Context) error {
    return c.JSON(http.StatusOK, map[string]interface{}{
        "status": "ok",
        "timestamp": time.Now(),
    })
})
```

### 2. ステータスコード

```go
// 明示的なステータスコード
c.JSON(http.StatusCreated, user)       // 201
c.JSON(http.StatusNotFound, err)       // 404
c.NoContent(http.StatusNoContent)      // 204

// echo.NewHTTPError
return echo.NewHTTPError(http.StatusBadRequest, "Invalid request")
```

## バリデーション

### カスタムバリデータ

```go
import "github.com/go-playground/validator/v10"

type CustomValidator struct {
    validator *validator.Validate
}

func (cv *CustomValidator) Validate(i interface{}) error {
    if err := cv.validator.Struct(i); err != nil {
        return err
    }
    return nil
}

func main() {
    e := echo.New()
    e.Validator = &CustomValidator{validator: validator.New()}
}
```

## ミドルウェアからの認証情報抽出

### 1. JWT認証ミドルウェア

```go
import (
    "github.com/labstack/echo/v4/middleware"
    "github.com/golang-jwt/jwt/v5"
)

func main() {
    e := echo.New()

    // JWT ミドルウェア
    config := middleware.JWTConfig{
        SigningKey: []byte("secret"),
    }

    api := e.Group("/api")
    api.Use(middleware.JWTWithConfig(config))
    {
        api.GET("/users", getUsers)
    }
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
func APIKeyMiddleware() echo.MiddlewareFunc {
    return func(next echo.HandlerFunc) echo.HandlerFunc {
        return func(c echo.Context) error {
            apiKey := c.Request().Header.Get("X-API-Key")
            if !isValidAPIKey(apiKey) {
                return echo.NewHTTPError(http.StatusForbidden, "Invalid API key")
            }
            return next(c)
        }
    }
}

api := e.Group("/api")
api.Use(APIKeyMiddleware())
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
    "github.com/labstack/echo/v4"
    "github.com/labstack/echo/v4/middleware"
)

type User struct {
    ID        uint      `json:"id"`
    Name      string    `json:"name"`
    Email     string    `json:"email"`
    CreatedAt time.Time `json:"created_at"`
}

type UserCreateRequest struct {
    Name  string `json:"name" validate:"required,min=1,max=100"`
    Email string `json:"email" validate:"required,email"`
    Age   int    `json:"age" validate:"min=0,max=150"`
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
    e := echo.New()
    e.Use(middleware.Logger())
    e.Use(middleware.Recover())

    api := e.Group("/api")
    {
        users := api.Group("/users")
        users.GET("", getUsers)
        users.GET("/:id", getUser)
        users.POST("", createUser)
        users.PUT("/:id", updateUser)
        users.DELETE("/:id", deleteUser)
    }

    e.Start(":8080")
}

func getUsers(c echo.Context) error {
    page := c.QueryParam("page")
    if page == "" {
        page = "1"
    }

    limit := c.QueryParam("limit")
    if limit == "" {
        limit = "20"
    }

    return c.JSON(http.StatusOK, PaginationResponse{
        Data:       []User{},
        Page:       1,
        Limit:      20,
        TotalCount: 0,
    })
}

func getUser(c echo.Context) error {
    id := c.Param("id")

    // データベースクエリ (省略)
    // if not found:
    //   return c.JSON(http.StatusNotFound, ErrorResponse{Code: 404, Message: "User not found"})

    return c.JSON(http.StatusOK, User{
        ID:        123,
        Name:      "John Doe",
        Email:     "john@example.com",
        CreatedAt: time.Now(),
    })
}

func createUser(c echo.Context) error {
    req := new(UserCreateRequest)
    if err := c.Bind(req); err != nil {
        return c.JSON(http.StatusBadRequest, ErrorResponse{
            Code:    400,
            Message: err.Error(),
        })
    }

    if err := c.Validate(req); err != nil {
        return c.JSON(http.StatusBadRequest, ErrorResponse{
            Code:    400,
            Message: err.Error(),
        })
    }

    return c.JSON(http.StatusCreated, User{
        ID:        1,
        Name:      req.Name,
        Email:     req.Email,
        CreatedAt: time.Now(),
    })
}

func updateUser(c echo.Context) error {
    id := c.Param("id")
    req := new(UserCreateRequest)

    if err := c.Bind(req); err != nil {
        return c.JSON(http.StatusBadRequest, ErrorResponse{
            Code:    400,
            Message: err.Error(),
        })
    }

    if err := c.Validate(req); err != nil {
        return c.JSON(http.StatusBadRequest, ErrorResponse{
            Code:    400,
            Message: err.Error(),
        })
    }

    return c.JSON(http.StatusOK, User{})
}

func deleteUser(c echo.Context) error {
    id := c.Param("id")

    // 削除処理

    return c.NoContent(http.StatusNoContent)
}
```

## 検出優先順位

1. **Swagger アノテーション** (最優先)
2. **構造体の validate タグ**
3. **c.JSON() の引数型**
4. **関数名とパスからの推測** (最終手段)
