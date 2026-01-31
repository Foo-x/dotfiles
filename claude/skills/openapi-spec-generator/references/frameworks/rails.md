# Ruby on Rails パターン

## フレームワーク検出

### 検出条件

1. `Gemfile` に `gem 'rails'` の記述
2. `config/routes.rb` ファイルの存在
3. `config/application.rb` に `Rails::Application`

### 検出用 Grep パターン

```bash
Grep: "gem ['\"]rails['\"]" in Gemfile
Grep: "Rails::Application" in "config/application.rb"
```

## ルーティング定義パターン

### 1. config/routes.rb での定義

```ruby
Rails.application.routes.draw do
  # RESTful リソース
  resources :users

  # ネストしたリソース
  resources :posts do
    resources :comments
  end

  # カスタムアクション
  resources :articles do
    member do
      post :publish
      delete :archive
    end

    collection do
      get :featured
    end
  end

  # 個別ルート
  get '/users/:id', to: 'users#show'
  post '/users', to: 'users#create'
  put '/users/:id', to: 'users#update'
  patch '/users/:id', to: 'users#update'
  delete '/users/:id', to: 'users#destroy'

  # 名前空間
  namespace :api do
    namespace :v1 do
      resources :users
      resources :posts
    end
  end

  # API モード
  namespace :api, defaults: { format: :json } do
    resources :users
  end
end
```

**Grep パターン:**
```
pattern: "(get|post|put|patch|delete)\\s+['\"]([^'\"]+)['\"]"
pattern: "resources\\s+:([a-z_]+)"
pattern: "namespace\\s+:([a-z_]+)"
```

### 2. resources によるRESTfulルート

`resources :users` は以下のルートを生成:

| HTTPメソッド | パス | コントローラ#アクション | 用途 |
|------------|------|---------------------|------|
| GET | /users | users#index | 一覧表示 |
| GET | /users/new | users#new | 新規作成フォーム |
| POST | /users | users#create | 作成 |
| GET | /users/:id | users#show | 詳細表示 |
| GET | /users/:id/edit | users#edit | 編集フォーム |
| PATCH/PUT | /users/:id | users#update | 更新 |
| DELETE | /users/:id | users#destroy | 削除 |

### 3. コントローラーファイルの典型的な場所

```
app/
├── controllers/
│   ├── application_controller.rb
│   ├── users_controller.rb
│   ├── posts_controller.rb
│   └── api/
│       └── v1/
│           ├── users_controller.rb
│           └── posts_controller.rb
```

**Glob パターン:**
```
app/controllers/**/*_controller.rb
```

## コントローラーアクションの解析

### 1. 基本的なコントローラー

```ruby
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = User.page(params[:page]).per(params[:limit] || 20)
    render json: @users
  end

  # GET /users/:id
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/:id
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  def user_params
    params.require(:user).permit(:name, :email, :age)
  end
end
```

## パラメータ抽出

### 1. パスパラメータ

```ruby
# :id がパスパラメータ
def show
  id = params[:id]
  @user = User.find(id)
end

# ネストしたパラメータ
# /posts/:post_id/comments/:id
def show
  post_id = params[:post_id]
  comment_id = params[:id]
end
```

### 2. クエリパラメータ

```ruby
def index
  page = params[:page] || 1
  limit = params[:limit] || 20
  search = params[:search]

  @users = User.where('name LIKE ?', "%#{search}%")
                .page(page)
                .per(limit)
end
```

### 3. リクエストボディ (Strong Parameters)

```ruby
private

def user_params
  params.require(:user).permit(:name, :email, :age, :bio)
end

# ネストした属性
def post_params
  params.require(:post).permit(
    :title,
    :content,
    :published,
    tag_ids: [],
    comments_attributes: [:id, :body, :_destroy]
  )
end
```

## モデルからのスキーマ抽出

### 1. ActiveRecord モデルとバリデーション

```ruby
class User < ApplicationRecord
  # バリデーション
  validates :name, presence: true, length: { minimum: 1, maximum: 100 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :age, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 150 }, allow_nil: true
  validates :status, inclusion: { in: %w[active inactive pending] }

  # 関連
  has_many :posts
  belongs_to :organization, optional: true

  # Enum
  enum role: { user: 0, admin: 1, moderator: 2 }
end
```

**バリデーション → OpenAPI制約:**

| バリデーション | OpenAPI |
|-------------|---------|
| `presence: true` | `required` に追加 |
| `length: { minimum: 1, maximum: 100 }` | `minLength: 1, maxLength: 100` |
| `numericality: { greater_than_or_equal_to: 0 }` | `minimum: 0` |
| `numericality: { less_than_or_equal_to: 150 }` | `maximum: 150` |
| `format: { with: EMAIL_REGEXP }` | `format: email` |
| `inclusion: { in: [...] }` | `enum: [...]` |

### 2. db/schema.rb からの型情報

```ruby
create_table "users", force: :cascade do |t|
  t.string "name", null: false
  t.string "email", null: false
  t.integer "age"
  t.text "bio"
  t.boolean "active", default: true
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false

  t.index ["email"], name: "index_users_on_email", unique: true
end
```

**Rails型 → OpenAPI型マッピング:**

| Rails型 | OpenAPI |
|--------|---------|
| `string` | `type: string` |
| `text` | `type: string` |
| `integer` | `type: integer` |
| `bigint` | `type: integer, format: int64` |
| `float`, `decimal` | `type: number` |
| `boolean` | `type: boolean` |
| `date` | `type: string, format: date` |
| `datetime`, `timestamp` | `type: string, format: date-time` |
| `json`, `jsonb` | `type: object` |

## Serializer によるレスポンススキーマ定義

### 1. ActiveModel::Serializers

```ruby
class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :created_at

  attribute :age, if: :show_age?

  has_many :posts

  def show_age?
    !object.age.nil?
  end
end

# コントローラーで使用
def index
  @users = User.all
  render json: @users, each_serializer: UserSerializer
end
```

### 2. Jbuilder

```ruby
# app/views/users/index.json.jbuilder
json.data do
  json.array! @users do |user|
    json.id user.id
    json.name user.name
    json.email user.email
    json.created_at user.created_at
  end
end

json.pagination do
  json.page @users.current_page
  json.total_pages @users.total_pages
  json.total_count @users.total_count
end
```

## レスポンススキーマ推定

### 1. render json からの推定

```ruby
def show
  render json: {
    id: @user.id,
    name: @user.name,
    email: @user.email,
    created_at: @user.created_at
  }
end

# モデルから自動変換
def index
  render json: @users
end

# ステータスコード指定
def create
  render json: @user, status: :created  # 201
end

def destroy
  head :no_content  # 204
end
```

### 2. ステータスシンボル → HTTPコード

| シンボル | コード |
|---------|--------|
| `:ok` | 200 |
| `:created` | 201 |
| `:no_content` | 204 |
| `:bad_request` | 400 |
| `:unauthorized` | 401 |
| `:forbidden` | 403 |
| `:not_found` | 404 |
| `:unprocessable_entity` | 422 |
| `:internal_server_error` | 500 |

## 認証とセキュリティ

### 1. Devise (認証gem)

```ruby
class ApplicationController < ActionController::API
  before_action :authenticate_user!
end

class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    # 公開エンドポイント
  end
end
```

### 2. JWT認証

```ruby
class ApplicationController < ActionController::API
  before_action :authorize_request

  private

  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end
end
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

### 3. APIキー認証

```ruby
class ApplicationController < ActionController::API
  before_action :require_api_key

  private

  def require_api_key
    api_key = request.headers['X-API-Key']
    unless valid_api_key?(api_key)
      render json: { error: 'Invalid API key' }, status: :forbidden
    end
  end
end
```

## rswag によるOpenAPI自動生成

Rails用のOpenAPI生成gem:

```ruby
# Gemfile
gem 'rswag'

# spec/requests/users_spec.rb
require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/api/users' do
    get 'Retrieves users' do
      tags 'Users'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :limit, in: :query, type: :integer, required: false

      response '200', 'users found' do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  email: { type: :string }
                }
              }
            }
          }

        run_test!
      end
    end

    post 'Creates a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string }
        },
        required: ['name', 'email']
      }

      response '201', 'user created' do
        run_test!
      end
    end
  end
end
```

**注意:** `rswag` を使用している場合、`rake rswag:specs:swaggerize` で
OpenAPI仕様を自動生成できます。

## 実装例

```ruby
# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: [:show, :update, :destroy]

      # GET /api/v1/users
      def index
        @users = User.page(params[:page] || 1).per(params[:limit] || 20)

        render json: {
          data: @users.as_json(only: [:id, :name, :email, :created_at]),
          pagination: {
            page: @users.current_page,
            limit: @users.limit_value,
            total_pages: @users.total_pages,
            total_count: @users.total_count
          }
        }
      end

      # GET /api/v1/users/:id
      def show
        render json: @user
      end

      # POST /api/v1/users
      def create
        @user = User.new(user_params)

        if @user.save
          render json: @user, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/users/:id
      def update
        if @user.update(user_params)
          render json: @user
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/:id
      def destroy
        @user.destroy
        head :no_content
      end

      private

      def set_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      end

      def user_params
        params.require(:user).permit(:name, :email, :age)
      end
    end
  end
end
```

## 検出優先順位

1. **rswag アノテーション** (最優先)
2. **ActiveModel::Serializers**
3. **モデルのバリデーション + db/schema.rb**
4. **Strong Parameters (permit)**
5. **render json の内容**
6. **routes.rb + アクション名からの推測** (最終手段)
