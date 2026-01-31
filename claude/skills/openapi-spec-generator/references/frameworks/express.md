# Express (Node.js) パターン

## フレームワーク検出

### 検出条件

以下のいずれかが存在する場合、Expressプロジェクトと判定:

1. `package.json` に `express` の依存関係
2. `app.js`, `server.js`, `index.js` で `require('express')` または `import express`

### 検出用 Grep パターン

```bash
# package.json で express を検出
Grep: "\"express\":" in package.json

# コード内で express を検出
Grep: "(require\('express'\)|import.*express)" in "*.js,*.ts"
```

## ルーティング定義パターン

### 1. 基本的なルート定義

```javascript
// app.METHOD(path, handler)
app.get('/users', (req, res) => { ... })
app.post('/users', (req, res) => { ... })
app.put('/users/:id', (req, res) => { ... })
app.patch('/users/:id', (req, res) => { ... })
app.delete('/users/:id', (req, res) => { ... })
```

**Grep パターン:**
```
pattern: "app\.(get|post|put|patch|delete)\s*\(\s*['\"]([^'\"]+)['\"]"
output_mode: content
glob: "*.js,*.ts"
```

### 2. Router を使用したルート定義

```javascript
const router = express.Router();

router.get('/', (req, res) => { ... });
router.post('/', (req, res) => { ... });

// マウント
app.use('/api/users', router);
```

**Grep パターン:**
```
# Router定義
pattern: "router\.(get|post|put|patch|delete)\s*\(\s*['\"]([^'\"]+)['\"]"

# app.use でのマウント
pattern: "app\.use\s*\(\s*['\"]([^'\"]+)['\"]"
```

### 3. Express Router ファイルの典型的な場所

```
routes/
├── index.js
├── users.js
├── api/
│   ├── v1/
│   │   ├── users.js
│   │   └── posts.js
│   └── index.js
└── auth.js
```

**Glob パターン:**
```
routes/**/*.js
routes/**/*.ts
src/routes/**/*.js
src/routes/**/*.ts
```

## パラメータ抽出

### 1. パスパラメータ

```javascript
// :id がパスパラメータ
app.get('/users/:id', (req, res) => {
  const id = req.params.id;
});

app.get('/posts/:postId/comments/:commentId', (req, res) => {
  const { postId, commentId } = req.params;
});
```

**抽出ルール:**
- `:paramName` 形式 → OpenAPI の `path` パラメータ
- 型は基本的に `string` (数値の場合もコード内検証で判断)

### 2. クエリパラメータ

```javascript
// ?page=1&limit=10
app.get('/users', (req, res) => {
  const page = req.query.page;
  const limit = req.query.limit;
});
```

**抽出方法:**
- `req.query.*` を検索
- 型はデフォルト値やバリデーションから推定

### 3. リクエストボディ

```javascript
// JSON bodyparser 必要
app.post('/users', (req, res) => {
  const { name, email, age } = req.body;
});
```

**抽出方法:**
- `req.body.*` のプロパティを検索
- TypeScript の場合、型定義から自動抽出

## レスポンススキーマ推定

### 1. JSONレスポンス

```javascript
app.get('/users/:id', (req, res) => {
  res.json({
    id: req.params.id,
    name: 'John Doe',
    email: 'john@example.com',
    createdAt: new Date()
  });
});
```

**推定ルール:**
- `res.json()`, `res.send()` の引数から構造を推定
- 文字列リテラルはサンプル値として除外
- 変数名から型を推測 (例: `createdAt` → `date-time`)

### 2. ステータスコード

```javascript
// 明示的なステータスコード
res.status(201).json({ ... });
res.status(404).send('Not found');

// デフォルトは200
res.json({ ... });
```

**抽出パターン:**
```
pattern: "res\.status\s*\(\s*(\d{3})\s*\)"
```

### 3. エラーハンドリング

```javascript
// エラーミドルウェア
app.use((err, req, res, next) => {
  res.status(err.status || 500).json({
    error: {
      message: err.message,
      code: err.code
    }
  });
});
```

## TypeScript サポート

### 型定義からのスキーマ抽出

```typescript
interface CreateUserRequest {
  name: string;
  email: string;
  age?: number;
}

interface UserResponse {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

app.post('/users', (req: Request<{}, {}, CreateUserRequest>, res) => {
  const user: UserResponse = { ... };
  res.json(user);
});
```

**抽出方法:**
1. インターフェース/型定義を検索
2. ジェネリック型パラメータから型を特定
3. OpenAPIスキーマに変換

**TypeScript 型 → OpenAPI 型マッピング:**

| TypeScript | OpenAPI |
|-----------|---------|
| `string` | `type: string` |
| `number` | `type: number` |
| `boolean` | `type: boolean` |
| `Date` | `type: string, format: date-time` |
| `string[]` | `type: array, items: {type: string}` |
| `T \| null` | `type: [T, "null"]` |
| `enum` | `type: string, enum: [...]` |

## バリデーションライブラリからのスキーマ抽出

### 1. express-validator

```javascript
const { body, param, query } = require('express-validator');

app.post('/users', [
  body('email').isEmail(),
  body('age').isInt({ min: 0, max: 150 }),
  body('name').isLength({ min: 1, max: 100 })
], (req, res) => { ... });
```

**抽出ルール:**
- `body()` → リクエストボディプロパティ
- `param()` → パスパラメータ
- `query()` → クエリパラメータ
- バリデータから型と制約を推定

### 2. Joi

```javascript
const Joi = require('joi');

const userSchema = Joi.object({
  name: Joi.string().min(1).max(100).required(),
  email: Joi.string().email().required(),
  age: Joi.number().integer().min(0).max(150)
});

app.post('/users', (req, res) => {
  const { error, value } = userSchema.validate(req.body);
});
```

**抽出ルール:**
- Joi スキーマから直接 OpenAPI スキーマに変換

### 3. Zod

```typescript
import { z } from 'zod';

const CreateUserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().min(0).max(150).optional()
});

app.post('/users', (req, res) => {
  const data = CreateUserSchema.parse(req.body);
});
```

**抽出ルール:**
- Zod スキーマから OpenAPI スキーマに変換
- `@anatine/zod-openapi` のようなライブラリパターンも検出

## ミドルウェアからの認証情報抽出

### 1. JWT認証

```javascript
const jwt = require('jsonwebtoken');

const authenticateJWT = (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  // ...
};

app.get('/protected', authenticateJWT, (req, res) => { ... });
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

```javascript
const apiKeyAuth = (req, res, next) => {
  const apiKey = req.header('X-API-Key');
  // ...
};
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

### サンプルコード

```javascript
// routes/users.js
const express = require('express');
const router = express.Router();

/**
 * @route GET /api/users
 * @description ユーザー一覧取得
 * @access Public
 */
router.get('/', async (req, res) => {
  const { page = 1, limit = 20 } = req.query;

  const users = await User.find()
    .limit(limit * 1)
    .skip((page - 1) * limit);

  res.json({
    data: users,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total: await User.countDocuments()
    }
  });
});

/**
 * @route GET /api/users/:id
 * @description ユーザー詳細取得
 * @access Public
 */
router.get('/:id', async (req, res) => {
  const user = await User.findById(req.params.id);

  if (!user) {
    return res.status(404).json({
      error: {
        code: 404,
        message: 'User not found'
      }
    });
  }

  res.json(user);
});

/**
 * @route POST /api/users
 * @description ユーザー作成
 * @access Private
 */
router.post('/', authenticateJWT, async (req, res) => {
  const { name, email } = req.body;

  const user = new User({ name, email });
  await user.save();

  res.status(201).json(user);
});

module.exports = router;
```

### 対応する OpenAPI 仕様

```yaml
paths:
  /api/users:
    get:
      summary: ユーザー一覧取得
      description: ユーザー一覧取得
      tags:
        - Users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
      responses:
        '200':
          description: 成功
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

    post:
      summary: ユーザー作成
      description: ユーザー作成
      tags:
        - Users
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - name
                - email
              properties:
                name:
                  type: string
                email:
                  type: string
                  format: email
      responses:
        '201':
          description: 作成成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'

  /api/users/{id}:
    get:
      summary: ユーザー詳細取得
      description: ユーザー詳細取得
      tags:
        - Users
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: 成功
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '404':
          description: ユーザーが見つかりません
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
```

## 検出優先順位

1. **TypeScript型定義** (最優先)
2. **バリデーションライブラリ** (Zod > Joi > express-validator)
3. **JSDoc コメント**
4. **コード内の実装** (res.json() の内容)
5. **ファイル名・関数名からの推測** (最終手段)
