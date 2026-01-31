# FastAPI (Python) パターン

## フレームワーク検出

### 検出条件

以下のいずれかが存在する場合、FastAPIプロジェクトと判定:

1. `requirements.txt` または `pyproject.toml` に `fastapi` の依存関係
2. `main.py`, `app.py` で `from fastapi import FastAPI`

### 検出用 Grep パターン

```bash
# requirements.txt で fastapi を検出
Grep: "fastapi" in requirements.txt, pyproject.toml

# コード内で fastapi を検出
Grep: "from fastapi import|import fastapi" in "*.py"
```

## ルーティング定義パターン

### 1. デコレータベースのルート定義

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/users")
async def get_users():
    return {"users": []}

@app.post("/users")
async def create_user(user: UserCreate):
    return user

@app.get("/users/{user_id}")
async def get_user(user_id: int):
    return {"id": user_id}

@app.put("/users/{user_id}")
async def update_user(user_id: int, user: UserUpdate):
    return user

@app.delete("/users/{user_id}")
async def delete_user(user_id: int):
    return {"deleted": True}
```

**Grep パターン:**
```
pattern: "@(app|router)\.(get|post|put|patch|delete)\s*\(\s*[\"']([^\"']+)[\"']"
output_mode: content
glob: "*.py"
```

### 2. APIRouter を使用したルート定義

```python
from fastapi import APIRouter

router = APIRouter(prefix="/api/v1", tags=["users"])

@router.get("/users")
async def get_users():
    return []

@router.post("/users")
async def create_user(user: UserCreate):
    return user

# メインアプリにマウント
app.include_router(router)
```

**Grep パターン:**
```
# Router定義
pattern: "@router\.(get|post|put|patch|delete)\s*\(\s*[\"']([^\"']+)[\"']"

# include_router でのマウント
pattern: "app\.include_router\s*\(\s*([^,\)]+)"
```

### 3. FastAPI ルーターファイルの典型的な場所

```
app/
├── main.py
├── routers/
│   ├── __init__.py
│   ├── users.py
│   ├── posts.py
│   └── auth.py
└── api/
    └── v1/
        ├── __init__.py
        └── endpoints/
            ├── users.py
            └── items.py
```

**Glob パターン:**
```
routers/**/*.py
app/routers/**/*.py
api/**/endpoints/**/*.py
api/**/routers/**/*.py
```

## Pydantic モデルからのスキーマ抽出

FastAPIは自動的にPydanticモデルをOpenAPIスキーマに変換しますが、
既存コードから抽出する場合:

### 1. 基本的なPydanticモデル

```python
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=100)
    age: Optional[int] = Field(None, ge=0, le=150)

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)

class UserResponse(UserBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True  # Pydantic v2
        # orm_mode = True  # Pydantic v1
```

**Python型 → OpenAPI型マッピング:**

| Python型 | OpenAPI |
|---------|---------|
| `str` | `type: string` |
| `int` | `type: integer` |
| `float` | `type: number` |
| `bool` | `type: boolean` |
| `datetime` | `type: string, format: date-time` |
| `date` | `type: string, format: date` |
| `UUID` | `type: string, format: uuid` |
| `EmailStr` | `type: string, format: email` |
| `HttpUrl` | `type: string, format: uri` |
| `List[T]` | `type: array, items: {...}` |
| `Optional[T]` | スキーマは同じ、requiredから除外 |
| `Union[T1, T2]` | `oneOf: [...]` |

### 2. Field によるバリデーション

```python
from pydantic import BaseModel, Field

class Product(BaseModel):
    name: str = Field(..., min_length=1, max_length=200)
    price: float = Field(..., gt=0, description="商品価格")
    quantity: int = Field(0, ge=0, le=10000)
    tags: list[str] = Field(default_factory=list, max_items=10)
    status: Literal["draft", "published", "archived"] = "draft"
```

**対応するOpenAPIスキーマ:**
```yaml
components:
  schemas:
    Product:
      type: object
      required:
        - name
        - price
      properties:
        name:
          type: string
          minLength: 1
          maxLength: 200
        price:
          type: number
          exclusiveMinimum: true
          minimum: 0
          description: 商品価格
        quantity:
          type: integer
          minimum: 0
          maximum: 10000
          default: 0
        tags:
          type: array
          items:
            type: string
          maxItems: 10
          default: []
        status:
          type: string
          enum:
            - draft
            - published
            - archived
          default: draft
```

## パラメータ抽出

### 1. パスパラメータ

```python
from fastapi import Path

@app.get("/users/{user_id}")
async def get_user(
    user_id: int = Path(..., ge=1, description="ユーザーID")
):
    return {"id": user_id}

@app.get("/posts/{post_id}/comments/{comment_id}")
async def get_comment(post_id: int, comment_id: int):
    return {"post_id": post_id, "comment_id": comment_id}
```

**抽出ルール:**
- `{param_name}` 形式 → OpenAPI の `path` パラメータ
- 型アノテーションから型を抽出
- `Path()` の引数からバリデーションと説明を抽出

### 2. クエリパラメータ

```python
from fastapi import Query

@app.get("/users")
async def get_users(
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりの件数"),
    search: Optional[str] = Query(None, max_length=100)
):
    return {"page": page, "limit": limit}
```

**抽出ルール:**
- 関数引数が `Path`, `Body` でない場合 → クエリパラメータ
- `Query()` の引数から制約と説明を抽出
- デフォルト値がある場合は `required: false`

### 3. リクエストボディ

```python
from fastapi import Body

@app.post("/users")
async def create_user(user: UserCreate):
    return user

@app.post("/items")
async def create_item(
    item: ItemCreate,
    metadata: dict = Body(..., description="追加メタデータ")
):
    return {"item": item, "metadata": metadata}
```

**抽出ルール:**
- Pydanticモデル型の引数 → リクエストボディ
- `Body()` を使用している引数 → リクエストボディ
- モデルから自動的にスキーマ生成

### 4. ヘッダーパラメータ

```python
from fastapi import Header

@app.get("/items")
async def read_items(
    x_api_key: Optional[str] = Header(None, description="APIキー"),
    user_agent: Optional[str] = Header(None)
):
    return {"api_key": x_api_key}
```

### 5. Cookieパラメータ

```python
from fastapi import Cookie

@app.get("/items")
async def read_items(
    session_id: Optional[str] = Cookie(None)
):
    return {"session": session_id}
```

## レスポンススキーマ推定

### 1. 型アノテーションによる明示的定義

```python
from fastapi import FastAPI
from typing import List

@app.get("/users", response_model=List[UserResponse])
async def get_users():
    return []

@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int):
    return UserResponse(...)

@app.post("/users", response_model=UserResponse, status_code=201)
async def create_user(user: UserCreate):
    return UserResponse(...)
```

**抽出ルール:**
- `response_model` パラメータから直接スキーマ抽出 (最優先)
- `status_code` パラメータからステータスコード取得

### 2. 複数のレスポンスモデル

```python
from fastapi import status
from fastapi.responses import JSONResponse

@app.get(
    "/users/{user_id}",
    response_model=UserResponse,
    responses={
        200: {"model": UserResponse, "description": "成功"},
        404: {"model": ErrorResponse, "description": "ユーザーが見つかりません"},
        500: {"model": ErrorResponse, "description": "サーバーエラー"}
    }
)
async def get_user(user_id: int):
    return UserResponse(...)
```

**抽出ルール:**
- `responses` 辞書から全レスポンスパターンを抽出
- 各ステータスコードに対応するモデルと説明を取得

### 3. HTTPException

```python
from fastapi import HTTPException

@app.get("/users/{user_id}")
async def get_user(user_id: int):
    if user_id not in users:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )
    return users[user_id]
```

**抽出ルール:**
- `HTTPException` の `status_code` から追加のレスポンスを推定
- `detail` から基本的なエラースキーマを生成

## 依存性注入からのセキュリティ情報抽出

### 1. OAuth2認証

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_current_user(token: str = Depends(oauth2_scheme)):
    # トークン検証
    return user

@app.get("/users/me", dependencies=[Depends(get_current_user)])
async def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user
```

**OpenAPIセキュリティスキーム:**
```yaml
components:
  securitySchemes:
    OAuth2PasswordBearer:
      type: oauth2
      flows:
        password:
          tokenUrl: /token
          scopes: {}
```

### 2. APIキー認証

```python
from fastapi import Security
from fastapi.security import APIKeyHeader

api_key_header = APIKeyHeader(name="X-API-Key")

async def verify_api_key(api_key: str = Security(api_key_header)):
    if api_key not in valid_api_keys:
        raise HTTPException(status_code=403)
    return api_key

@app.get("/protected", dependencies=[Depends(verify_api_key)])
async def protected_route():
    return {"message": "Protected"}
```

**OpenAPIセキュリティスキーム:**
```yaml
components:
  securitySchemes:
    APIKeyHeader:
      type: apiKey
      in: header
      name: X-API-Key
```

### 3. HTTP Bearer認証

```python
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

async def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    # JWT検証
    return user

@app.get("/protected", dependencies=[Depends(verify_token)])
async def protected_route():
    return {"message": "Protected"}
```

**OpenAPIセキュリティスキーム:**
```yaml
components:
  securitySchemes:
    HTTPBearer:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

## タグとメタデータ

### 1. タグによるグループ化

```python
@app.get("/users", tags=["users"])
async def get_users():
    return []

@app.get("/posts", tags=["posts", "public"])
async def get_posts():
    return []

# ルーターレベルでのタグ
router = APIRouter(prefix="/api/v1", tags=["v1", "users"])
```

### 2. メタデータ

```python
from fastapi import FastAPI

app = FastAPI(
    title="My API",
    description="API の説明",
    version="1.0.0",
    contact={
        "name": "API Support",
        "email": "support@example.com",
    },
    license_info={
        "name": "Apache 2.0",
        "url": "https://www.apache.org/licenses/LICENSE-2.0.html",
    },
)
```

## 実装例

### サンプルコード

```python
# app/routers/users.py
from fastapi import APIRouter, Depends, HTTPException, Query, Path, status
from typing import List, Optional
from app.models import User, UserCreate, UserUpdate, UserResponse
from app.dependencies import get_current_user

router = APIRouter(prefix="/api/users", tags=["users"])

@router.get("/", response_model=List[UserResponse])
async def get_users(
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりの件数"),
    search: Optional[str] = Query(None, max_length=100, description="検索キーワード")
):
    """
    ユーザー一覧取得

    ページネーション付きでユーザー一覧を取得します。
    """
    # 実装
    return users

@router.get(
    "/{user_id}",
    response_model=UserResponse,
    responses={
        404: {"description": "ユーザーが見つかりません"}
    }
)
async def get_user(
    user_id: int = Path(..., ge=1, description="ユーザーID")
):
    """ユーザー詳細取得"""
    user = await User.get(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user

@router.post(
    "/",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(get_current_user)]
)
async def create_user(user: UserCreate):
    """ユーザー作成 (要認証)"""
    return await User.create(user)

@router.put("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int = Path(..., ge=1),
    user: UserUpdate = ...,
    current_user: User = Depends(get_current_user)
):
    """ユーザー更新 (要認証)"""
    return await User.update(user_id, user)

@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_id: int = Path(..., ge=1),
    current_user: User = Depends(get_current_user)
):
    """ユーザー削除 (要認証)"""
    await User.delete(user_id)
```

```python
# app/models.py
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr = Field(..., description="メールアドレス")
    name: str = Field(..., min_length=1, max_length=100, description="ユーザー名")
    age: Optional[int] = Field(None, ge=0, le=150, description="年齢")

class UserCreate(UserBase):
    password: str = Field(..., min_length=8, description="パスワード")

class UserUpdate(BaseModel):
    email: Optional[EmailStr] = None
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    age: Optional[int] = Field(None, ge=0, le=150)

class UserResponse(UserBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
```

## 検出優先順位

1. **Pydantic モデルと型アノテーション** (最優先)
2. **`response_model` パラメータ**
3. **`responses` 辞書**
4. **Path/Query/Body/Header の制約**
5. **docstring**
6. **関数名からの推測** (最終手段)

## FastAPI 特有の機能

### 1. 自動ドキュメント生成

FastAPIは `/docs` (Swagger UI) と `/redoc` (ReDoc) を自動生成しますが、
既存のアプリケーションから抽出する際も同様のメタデータを活用できます。

### 2. OpenAPI スキーマの直接取得

```python
# FastAPI アプリから直接 OpenAPI スキーマを取得可能
openapi_schema = app.openapi()
```

実行中のアプリケーションがある場合、この方法が最も正確です。
