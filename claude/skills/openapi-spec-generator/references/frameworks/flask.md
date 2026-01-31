# Flask (Python) パターン

## フレームワーク検出

### 検出条件

1. `requirements.txt` または `pyproject.toml` に `flask` の依存関係
2. `app.py`, `main.py` で `from flask import Flask`

### 検出用 Grep パターン

```bash
Grep: "flask" in requirements.txt, pyproject.toml
Grep: "from flask import|import flask" in "*.py"
```

## ルーティング定義パターン

### 1. デコレータベースのルート定義

```python
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/users', methods=['GET'])
def get_users():
    return jsonify({"users": []})

@app.route('/users', methods=['POST'])
def create_user():
    data = request.json
    return jsonify(data), 201

@app.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    return jsonify({"id": user_id})

@app.route('/users/<int:user_id>', methods=['PUT', 'PATCH'])
def update_user(user_id):
    return jsonify({"id": user_id})

@app.route('/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    return '', 204
```

**Grep パターン:**
```
pattern: "@(app|bp|blueprint)\\.route\\s*\\(\\s*['\"]([^'\"]+)['\"].*methods\\s*=\\s*\\[([^\\]]+)\\]"
pattern: "@(app|bp|blueprint)\\.(get|post|put|patch|delete)\\s*\\(\\s*['\"]([^'\"]+)['\"]"
```

### 2. Blueprint を使用したルート定義

```python
from flask import Blueprint

users_bp = Blueprint('users', __name__, url_prefix='/api/users')

@users_bp.route('/', methods=['GET'])
def get_users():
    return jsonify([])

@users_bp.route('/<int:user_id>', methods=['GET'])
def get_user(user_id):
    return jsonify({"id": user_id})

# メインアプリに登録
app.register_blueprint(users_bp)
```

**Grep パターン:**
```
pattern: "@(blueprint|bp)\\.route"
pattern: "app\\.register_blueprint\\s*\\("
```

### 3. Flask ルーターファイルの典型的な場所

```
app/
├── __init__.py
├── routes/
│   ├── __init__.py
│   ├── users.py
│   ├── posts.py
│   └── auth.py
└── blueprints/
    ├── api/
    │   └── v1/
    │       ├── users.py
    │       └── posts.py
```

**Glob パターン:**
```
routes/**/*.py
app/routes/**/*.py
blueprints/**/*.py
```

## パラメータ抽出

### 1. パスパラメータ

```python
@app.route('/users/<int:user_id>')
def get_user(user_id):
    return jsonify({"id": user_id})

@app.route('/posts/<string:slug>')
def get_post(slug):
    return jsonify({"slug": slug})

@app.route('/files/<path:filepath>')
def get_file(filepath):
    return send_file(filepath)
```

**型マッピング:**
- `<int:param>` → `type: integer`
- `<float:param>` → `type: number`
- `<string:param>` → `type: string`
- `<path:param>` → `type: string`
- `<uuid:param>` → `type: string, format: uuid`

### 2. クエリパラメータ

```python
@app.route('/users')
def get_users():
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 20, type=int)
    search = request.args.get('search', type=str)
    return jsonify({"page": page, "limit": limit})
```

**抽出方法:**
- `request.args.get()` から抽出
- `type` 引数から型を判定
- デフォルト値から `required` を判定

### 3. リクエストボディ

```python
@app.route('/users', methods=['POST'])
def create_user():
    data = request.json
    name = data.get('name')
    email = data.get('email')
    return jsonify({"name": name, "email": email}), 201

# または request.get_json()
@app.route('/items', methods=['POST'])
def create_item():
    data = request.get_json()
    return jsonify(data), 201
```

## Flask-RESTX / Flask-RESTful によるスキーマ定義

### Flask-RESTX (推奨)

```python
from flask_restx import Api, Resource, fields, Namespace

api = Api(app, version='1.0', title='API', description='API description')
ns = Namespace('users', description='ユーザー操作')

user_model = api.model('User', {
    'id': fields.Integer(required=True, description='ユーザーID'),
    'name': fields.String(required=True, min_length=1, max_length=100),
    'email': fields.String(required=True, description='メールアドレス'),
    'age': fields.Integer(min=0, max=150)
})

@ns.route('/')
class UserList(Resource):
    @ns.doc('list_users')
    @ns.marshal_list_with(user_model)
    def get(self):
        '''ユーザー一覧取得'''
        return []

    @ns.doc('create_user')
    @ns.expect(user_model)
    @ns.marshal_with(user_model, code=201)
    def post(self):
        '''ユーザー作成'''
        return api.payload, 201

api.add_namespace(ns, path='/api/users')
```

**抽出ルール:**
- `api.model()` で定義されたモデルをスキーマに変換
- `@ns.marshal_with()` からレスポンススキーマを特定
- `@ns.expect()` からリクエストスキーマを特定

### Flask-RESTful

```python
from flask_restful import Api, Resource, reqparse, fields, marshal_with

api = Api(app)

user_fields = {
    'id': fields.Integer,
    'name': fields.String,
    'email': fields.String,
    'created_at': fields.DateTime(dt_format='iso8601')
}

parser = reqparse.RequestParser()
parser.add_argument('name', type=str, required=True, location='json')
parser.add_argument('email', type=str, required=True, location='json')
parser.add_argument('age', type=int, location='json')

class UserResource(Resource):
    @marshal_with(user_fields)
    def get(self, user_id):
        return get_user(user_id)

    def post(self):
        args = parser.parse_args()
        return create_user(args), 201

api.add_resource(UserResource, '/api/users/<int:user_id>')
```

## Marshmallow によるスキーマ定義

```python
from marshmallow import Schema, fields, validate

class UserSchema(Schema):
    id = fields.Int(dump_only=True)
    name = fields.Str(required=True, validate=validate.Length(min=1, max=100))
    email = fields.Email(required=True)
    age = fields.Int(validate=validate.Range(min=0, max=150))
    created_at = fields.DateTime(dump_only=True)

user_schema = UserSchema()
users_schema = UserSchema(many=True)

@app.route('/users', methods=['POST'])
def create_user():
    errors = user_schema.validate(request.json)
    if errors:
        return jsonify(errors), 400

    user = user_schema.load(request.json)
    # 処理
    return user_schema.dump(user), 201
```

**Marshmallow → OpenAPI マッピング:**
- `fields.Str` → `type: string`
- `fields.Int` → `type: integer`
- `fields.Float` → `type: number`
- `fields.Bool` → `type: boolean`
- `fields.DateTime` → `type: string, format: date-time`
- `fields.Email` → `type: string, format: email`
- `fields.URL` → `type: string, format: uri`
- `fields.List` → `type: array`
- `dump_only=True` → `readOnly: true`
- `load_only=True` → `writeOnly: true`

## レスポンススキーマ推定

### 1. jsonify からの推定

```python
@app.route('/users/<int:user_id>')
def get_user(user_id):
    return jsonify({
        "id": user_id,
        "name": "John Doe",
        "email": "john@example.com",
        "created_at": datetime.now().isoformat()
    })
```

### 2. ステータスコード

```python
# タプル形式
return jsonify(data), 201
return jsonify({"error": "Not found"}), 404

# make_response
from flask import make_response
response = make_response(jsonify(data), 201)
return response

# abort でエラー
from flask import abort
abort(404, description="User not found")
```

## 認証とセキュリティ

### 1. Flask-JWT-Extended

```python
from flask_jwt_extended import JWTManager, jwt_required, get_jwt_identity

jwt = JWTManager(app)

@app.route('/protected', methods=['GET'])
@jwt_required()
def protected():
    current_user = get_jwt_identity()
    return jsonify(logged_in_as=current_user)
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

### 2. カスタムデコレータ

```python
from functools import wraps

def require_api_key(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        api_key = request.headers.get('X-API-Key')
        if not api_key or api_key not in valid_keys:
            abort(403)
        return f(*args, **kwargs)
    return decorated_function

@app.route('/admin')
@require_api_key
def admin():
    return jsonify({"message": "Admin area"})
```

## 実装例

```python
from flask import Flask, Blueprint, request, jsonify, abort
from marshmallow import Schema, fields, validate

app = Flask(__name__)
users_bp = Blueprint('users', __name__, url_prefix='/api/users')

class UserSchema(Schema):
    id = fields.Int(dump_only=True)
    name = fields.Str(required=True, validate=validate.Length(min=1, max=100))
    email = fields.Email(required=True)
    age = fields.Int(validate=validate.Range(min=0, max=150))
    created_at = fields.DateTime(dump_only=True)

user_schema = UserSchema()
users_schema = UserSchema(many=True)

@users_bp.route('/', methods=['GET'])
def get_users():
    """ユーザー一覧取得"""
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 20, type=int)

    users = User.query.paginate(page=page, per_page=limit)
    return jsonify({
        "data": users_schema.dump(users.items),
        "pagination": {
            "page": page,
            "limit": limit,
            "total": users.total
        }
    })

@users_bp.route('/<int:user_id>', methods=['GET'])
def get_user(user_id):
    """ユーザー詳細取得"""
    user = User.query.get(user_id)
    if not user:
        abort(404, description="User not found")
    return jsonify(user_schema.dump(user))

@users_bp.route('/', methods=['POST'])
def create_user():
    """ユーザー作成"""
    errors = user_schema.validate(request.json)
    if errors:
        return jsonify(errors), 400

    user_data = user_schema.load(request.json)
    # 保存処理
    return jsonify(user_schema.dump(user)), 201

app.register_blueprint(users_bp)
```

## 検出優先順位

1. **Flask-RESTX モデル** (最優先 - OpenAPI自動生成対応)
2. **Marshmallow スキーマ**
3. **Flask-RESTful fields**
4. **型ヒント + docstring**
5. **request.json, jsonify() の内容**
6. **関数名からの推測** (最終手段)
