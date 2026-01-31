# Laravel (PHP) パターン

## フレームワーク検出

### 検出条件

1. `composer.json` に `laravel/framework` の依存関係
2. `artisan` ファイルの存在
3. `app/Http/Kernel.php` の存在

### 検出用 Grep パターン

```bash
Grep: "laravel/framework" in composer.json
Grep: "Illuminate\\\\Foundation" in "*.php"
```

## ルーティング定義パターン

### 1. routes/api.php での定義

```php
<?php

use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Route;

// リソースルート
Route::apiResource('users', UserController::class);

// 個別ルート
Route::get('/users', [UserController::class, 'index']);
Route::post('/users', [UserController::class, 'store']);
Route::get('/users/{id}', [UserController::class, 'show']);
Route::put('/users/{id}', [UserController::class, 'update']);
Route::patch('/users/{id}', [UserController::class, 'update']);
Route::delete('/users/{id}', [UserController::class, 'destroy']);

// グループ化
Route::prefix('v1')->group(function () {
    Route::apiResource('users', UserController::class);
    Route::apiResource('posts', PostController::class);
});

// ミドルウェア
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('users', UserController::class);
});

// 名前空間
Route::namespace('Api\V1')->prefix('v1')->group(function () {
    Route::apiResource('users', 'UserController');
});
```

**Grep パターン:**
```
pattern: "Route::(get|post|put|patch|delete)\\s*\\(\\s*['\"]([^'\"]+)['\"]"
pattern: "Route::apiResource\\s*\\(\\s*['\"]([^'\"]+)['\"]"
pattern: "Route::resource\\s*\\(\\s*['\"]([^'\"]+)['\"]"
```

### 2. apiResource によるRESTfulルート

`Route::apiResource('users', UserController::class)` は以下のルートを生成:

| HTTPメソッド | URI | コントローラメソッド | 用途 |
|------------|-----|----------------|------|
| GET | /users | index | 一覧取得 |
| POST | /users | store | 作成 |
| GET | /users/{id} | show | 詳細取得 |
| PUT/PATCH | /users/{id} | update | 更新 |
| DELETE | /users/{id} | destroy | 削除 |

### 3. コントローラーファイルの典型的な場所

```
app/
├── Http/
│   └── Controllers/
│       ├── Controller.php
│       ├── UserController.php
│       ├── PostController.php
│       └── Api/
│           └── V1/
│               ├── UserController.php
│               └── PostController.php
```

**Glob パターン:**
```
app/Http/Controllers/**/*Controller.php
```

## コントローラーアクションの解析

### 1. 基本的なコントローラー

```php
<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    /**
     * Display a listing of users.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        $page = $request->query('page', 1);
        $limit = $request->query('limit', 20);

        $users = User::paginate($limit);

        return response()->json([
            'data' => $users->items(),
            'pagination' => [
                'page' => $users->currentPage(),
                'limit' => $users->perPage(),
                'total' => $users->total(),
            ]
        ]);
    }

    /**
     * Display the specified user.
     *
     * @param int $id
     * @return JsonResponse
     */
    public function show(int $id): JsonResponse
    {
        $user = User::findOrFail($id);
        return response()->json($user);
    }

    /**
     * Store a newly created user.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|min:1|max:100',
            'email' => 'required|email|unique:users',
            'age' => 'nullable|integer|min:0|max:150',
        ]);

        $user = User::create($validated);

        return response()->json($user, 201);
    }

    /**
     * Update the specified user.
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $user = User::findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|required|string|min:1|max:100',
            'email' => 'sometimes|required|email|unique:users,email,' . $id,
            'age' => 'nullable|integer|min:0|max:150',
        ]);

        $user->update($validated);

        return response()->json($user);
    }

    /**
     * Remove the specified user.
     *
     * @param int $id
     * @return JsonResponse
     */
    public function destroy(int $id): JsonResponse
    {
        $user = User::findOrFail($id);
        $user->delete();

        return response()->json(null, 204);
    }
}
```

## パラメータ抽出

### 1. パスパラメータ

```php
// {id} がパスパラメータ
public function show($id)
{
    $user = User::find($id);
}

// 型ヒント付き
public function show(int $id)
{
    $user = User::find($id);
}

// モデルバインディング
public function show(User $user)
{
    return response()->json($user);
}

// 複数のパラメータ
// /posts/{post}/comments/{comment}
public function show(int $postId, int $commentId)
{
    // ...
}
```

### 2. クエリパラメータ

```php
public function index(Request $request)
{
    $page = $request->query('page', 1);
    $limit = $request->query('limit', 20);
    $search = $request->query('search');

    // またはinput()
    $page = $request->input('page', 1);

    // または直接アクセス
    $page = $request->page ?? 1;
}
```

### 3. リクエストボディとバリデーション

```php
public function store(Request $request)
{
    // インラインバリデーション
    $validated = $request->validate([
        'name' => 'required|string|min:1|max:100',
        'email' => 'required|email|unique:users',
        'age' => 'nullable|integer|min:0|max:150',
        'status' => 'required|in:active,inactive,pending',
        'tags' => 'array|max:10',
        'tags.*' => 'string',
    ]);

    $user = User::create($validated);
}
```

## Form Request によるバリデーション

### 1. カスタムForm Request

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'min:1', 'max:100'],
            'email' => ['required', 'email', 'unique:users'],
            'age' => ['nullable', 'integer', 'min:0', 'max:150'],
            'password' => ['required', 'string', 'min:8'],
        ];
    }
}

// コントローラーで使用
public function store(StoreUserRequest $request)
{
    $validated = $request->validated();
    $user = User::create($validated);
    return response()->json($user, 201);
}
```

**バリデーションルール → OpenAPI制約:**

| ルール | OpenAPI |
|-------|---------|
| `required` | `required` に追加 |
| `min:1`, `max:100` | 文字列: `minLength/maxLength`, 数値: `minimum/maximum` |
| `email` | `format: email` |
| `url` | `format: uri` |
| `uuid` | `format: uuid` |
| `integer` | `type: integer` |
| `numeric` | `type: number` |
| `boolean` | `type: boolean` |
| `array` | `type: array` |
| `in:val1,val2` | `enum: [val1, val2]` |
| `nullable` | `required` から除外 |
| `sometimes` | `required` から除外 |

## モデルからのスキーマ抽出

### 1. Eloquent モデル

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class User extends Model
{
    protected $fillable = [
        'name',
        'email',
        'age',
        'bio',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'active' => 'boolean',
        'age' => 'integer',
    ];

    // リレーション
    public function posts()
    {
        return $this->hasMany(Post::class);
    }
}
```

### 2. マイグレーションファイル

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->integer('age')->nullable();
            $table->text('bio')->nullable();
            $table->boolean('active')->default(true);
            $table->timestamp('email_verified_at')->nullable();
            $table->timestamps();
        });
    }
};
```

**Laravel型 → OpenAPI型マッピング:**

| Laravel型 | OpenAPI |
|----------|---------|
| `string` | `type: string` |
| `text`, `mediumText`, `longText` | `type: string` |
| `integer`, `bigInteger` | `type: integer` |
| `float`, `double`, `decimal` | `type: number` |
| `boolean` | `type: boolean` |
| `date` | `type: string, format: date` |
| `datetime`, `timestamp` | `type: string, format: date-time` |
| `json`, `jsonb` | `type: object` |

## API Resource によるレスポンススキーマ定義

### 1. API Resource

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'age' => $this->age,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'posts' => PostResource::collection($this->whenLoaded('posts')),
        ];
    }
}

// コントローラーで使用
public function show(User $user)
{
    return new UserResource($user);
}

public function index()
{
    $users = User::paginate();
    return UserResource::collection($users);
}
```

### 2. Resource Collection

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\ResourceCollection;

class UserCollection extends ResourceCollection
{
    public function toArray(Request $request): array
    {
        return [
            'data' => $this->collection,
            'pagination' => [
                'total' => $this->total(),
                'count' => $this->count(),
                'per_page' => $this->perPage(),
                'current_page' => $this->currentPage(),
                'total_pages' => $this->lastPage(),
            ],
        ];
    }
}
```

## レスポンススキーマ推定

### 1. response()->json() からの推定

```php
public function show(int $id)
{
    $user = User::find($id);

    return response()->json([
        'id' => $user->id,
        'name' => $user->name,
        'email' => $user->email,
        'created_at' => $user->created_at,
    ]);
}

// ステータスコード指定
public function store(Request $request)
{
    $user = User::create($validated);
    return response()->json($user, 201);
}

public function destroy(int $id)
{
    User::destroy($id);
    return response()->json(null, 204);
}
```

### 2. Eloquentモデルから自動変換

```php
public function show(User $user)
{
    return response()->json($user);
}

// $hidden と $visible を考慮
```

## 認証とセキュリティ

### 1. Laravel Sanctum (SPA/API認証)

```php
// routes/api.php
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('users', UserController::class);
});

// コントローラー
public function index(Request $request)
{
    $user = $request->user(); // 認証済みユーザー
    // ...
}
```

**OpenAPI セキュリティスキーム:**
```yaml
components:
  securitySchemes:
    sanctum:
      type: http
      scheme: bearer
      bearerFormat: token
```

### 2. Laravel Passport (OAuth2)

```php
Route::middleware('auth:api')->group(function () {
    Route::apiResource('users', UserController::class);
});
```

**OpenAPI セキュリティスキーム:**
```yaml
components:
  securitySchemes:
    oauth2:
      type: oauth2
      flows:
        password:
          tokenUrl: /oauth/token
          scopes:
            read: Read access
            write: Write access
```

### 3. カスタムミドルウェア

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ApiKeyMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        $apiKey = $request->header('X-API-Key');

        if (!$this->isValidApiKey($apiKey)) {
            return response()->json(['error' => 'Invalid API key'], 403);
        }

        return $next($request);
    }
}
```

## L5-Swagger によるOpenAPI自動生成

Laravel用のOpenAPI生成パッケージ:

```php
<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

/**
 * @OA\Info(
 *     title="My API",
 *     version="1.0.0",
 *     description="API description"
 * )
 */
class Controller extends BaseController
{
}

/**
 * @OA\Get(
 *     path="/api/users",
 *     tags={"Users"},
 *     summary="Get list of users",
 *     @OA\Parameter(
 *         name="page",
 *         in="query",
 *         description="Page number",
 *         required=false,
 *         @OA\Schema(type="integer", default=1)
 *     ),
 *     @OA\Response(
 *         response=200,
 *         description="Successful operation",
 *         @OA\JsonContent(
 *             type="object",
 *             @OA\Property(property="data", type="array", @OA\Items(ref="#/components/schemas/User"))
 *         )
 *     )
 * )
 */
public function index(Request $request)
{
    // ...
}

/**
 * @OA\Schema(
 *     schema="User",
 *     type="object",
 *     required={"id", "name", "email"},
 *     @OA\Property(property="id", type="integer", example=1),
 *     @OA\Property(property="name", type="string", example="John Doe"),
 *     @OA\Property(property="email", type="string", format="email", example="john@example.com"),
 *     @OA\Property(property="created_at", type="string", format="date-time")
 * )
 */
```

**注意:** `l5-swagger` を使用している場合、`php artisan l5-swagger:generate` で
OpenAPI仕様を自動生成できます。

## 実装例

```php
<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreUserRequest;
use App\Http\Requests\UpdateUserRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $users = User::paginate($request->input('limit', 20));

        return response()->json([
            'data' => UserResource::collection($users),
            'pagination' => [
                'total' => $users->total(),
                'per_page' => $users->perPage(),
                'current_page' => $users->currentPage(),
                'last_page' => $users->lastPage(),
            ]
        ]);
    }

    public function show(User $user): UserResource
    {
        return new UserResource($user);
    }

    public function store(StoreUserRequest $request): JsonResponse
    {
        $user = User::create($request->validated());

        return response()->json(new UserResource($user), 201);
    }

    public function update(UpdateUserRequest $request, User $user): UserResource
    {
        $user->update($request->validated());

        return new UserResource($user);
    }

    public function destroy(User $user): JsonResponse
    {
        $user->delete();

        return response()->json(null, 204);
    }
}
```

## 検出優先順位

1. **L5-Swagger アノテーション** (最優先)
2. **API Resources**
3. **Form Request バリデーション**
4. **モデルのマイグレーション + $casts**
5. **response()->json() の内容**
6. **routes/api.php + メソッド名からの推測** (最終手段)
