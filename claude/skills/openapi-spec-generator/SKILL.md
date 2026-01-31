---
name: openapi-spec-generator
description: プロジェクトを分析してOpenAPI 3.x仕様書を自動生成するスキル。CLAUDE.mdやAGENT.mdからプロジェクト概要を読み取り、使用言語・フレームワークを自動検出してAPIエンドポイントを抽出する。以下の場合に使用:(1) 既存プロジェクトのAPI仕様書を作成したい時、(2) APIドキュメントを自動生成したい時、(3) OpenAPI/Swagger仕様書が必要な時
disable-model-invocation: true
---

# OpenAPI仕様書生成スキル

プロジェクトを分析してOpenAPI 3.2.x形式のAPI仕様書を自動生成します。

## 実行フロー

### Phase 1: プロジェクト概要とフレームワークの把握

**目的:** プロジェクトドキュメントから全体像と使用フレームワークを理解する

1. **プロジェクトドキュメントの検索と読み取り**
   ```bash
   # ドキュメントファイルを探す
   find . -maxdepth 2 \( -name 'AGENTS.md' -o -name 'CLAUDE.md' -o -name 'README.md' \) -type f 2>/dev/null
   ```

   優先順位: `AGENTS.md` > `CLAUDE.md` > `README.md`

   各ファイルを読み込み、以下の情報を抽出:

   **a) 基本情報 (OpenAPI仕様書に使用)**
   - プロジェクト名 → `info.title`
   - プロジェクト説明 → `info.description`
   - バージョン情報 → `info.version`
   - APIのベースURL → `servers[].url`
   - 連絡先情報 → `info.contact`

   **b) 技術スタック情報 (フレームワーク検出に使用)**
   - 使用言語: Node.js, Python, Java, Go, Ruby, PHP 等
   - Webフレームワーク: Express, FastAPI, Flask, Spring Boot, Gin, Echo, Rails, Laravel 等
   - 技術スタックセクション、依存関係セクション、開発環境セクション等から抽出

2. **フレームワーク検出結果の確認**
   - ドキュメントから1つ以上のフレームワークが特定できた場合:
     ```
     ✓ フレームワーク検出: [フレームワーク名] (CLAUDE.md より)
     ```
     → Phase 3へ進む

   - ドキュメントからフレームワークが特定できなかった場合:
     ```
     ⚠ ドキュメントからフレームワークを特定できませんでした
     → Phase 2でフォールバック検出を実行します
     ```
     → Phase 2へ進む

3. **プロジェクト構造のスキャン**
   ```bash
   # ディレクトリ構造を視覚的に把握 (tree が利用可能な場合)
   tree -L 3 -I 'node_modules|venv|.git|__pycache__|vendor|target' 2>/dev/null

   # tree が利用できない場合は find を使用
   find . -maxdepth 3 -type d \
     -not -path '*/node_modules/*' \
     -not -path '*/venv/*' \
     -not -path '*/.git/*' \
     -not -path '*/__pycache__/*' \
     -not -path '*/vendor/*' \
     -not -path '*/target/*' \
     2>/dev/null | head -50

   # 主要なディレクトリ (src, app, routes, api等) の構造を確認
   find . -maxdepth 4 -type d \( -name 'src' -o -name 'app' -o -name 'routes' -o -name 'api' -o -name 'controllers' -o -name 'handlers' \) 2>/dev/null
   ```

4. **出力先の確認**
   - ユーザーに出力ファイル名を確認 (デフォルト: `openapi.yaml`)
   - 既存ファイルがある場合は上書き確認

---

### Phase 2: フレームワーク検出 (フォールバック)

**目的:** Phase 1で特定できなかった場合、設定ファイルからフレームワークを検出する

**注意:** Phase 1でフレームワークが特定できた場合、このPhaseはスキップして Phase 3へ進む

#### 検出対象フレームワークと設定ファイル

| 言語 | フレームワーク | 検出ファイル | 検索パターン |
|-----|------------|------------|------------|
| Node.js | Express | `package.json` | `"express":` |
| Python | FastAPI | `requirements.txt`, `pyproject.toml` | `fastapi` |
| Python | Flask | `requirements.txt`, `pyproject.toml` | `flask` |
| Java | Spring Boot | `pom.xml`, `build.gradle` | `spring-boot-starter-web` |
| Go | Gin | `go.mod` | `github.com/gin-gonic/gin` |
| Go | Echo | `go.mod` | `github.com/labstack/echo` |
| Ruby | Rails | `Gemfile` | `gem ['"]rails['"]` |
| PHP | Laravel | `composer.json` | `laravel/framework` |

#### 検出手順

1. **設定ファイルの検索**
   ```bash
   # 主要な設定ファイルを検索
   find . -maxdepth 2 \( \
     -name 'package.json' -o \
     -name 'requirements.txt' -o \
     -name 'pyproject.toml' -o \
     -name 'pom.xml' -o \
     -name 'build.gradle' -o \
     -name 'go.mod' -o \
     -name 'Gemfile' -o \
     -name 'composer.json' \
   \) -type f 2>/dev/null
   ```

2. **設定ファイルの読み取りと検索**

   見つかった設定ファイルを順に読み込み、フレームワークキーワードを検索:

   - `package.json` → `"express":` を検索 → **Express**
   - `requirements.txt` / `pyproject.toml` → `fastapi` → **FastAPI**
   - `requirements.txt` / `pyproject.toml` → `flask` → **Flask**
   - `pom.xml` / `build.gradle` → `spring-boot-starter-web` → **Spring Boot**
   - `go.mod` → `github.com/gin-gonic/gin` → **Gin**
   - `go.mod` → `github.com/labstack/echo` → **Echo**
   - `Gemfile` → `gem 'rails'` → **Rails**
   - `composer.json` → `laravel/framework` → **Laravel**

3. **検出できなかった場合**

   設定ファイルからも検出できない場合:
   - ユーザーに使用フレームワークを質問
   - または、汎用的なパターンで可能な限り抽出を試みる

---

### Phase 3: リファレンスファイルの読み込み

**目的:** 検出されたフレームワークに対応するリファレンスのみを読み込む

1. **フレームワーク別リファレンスの読み込み**

   Phase 1 または Phase 2 で検出されたフレームワークに応じて、該当するリファレンスファイル**のみ**を読み込む:

   | 検出されたフレームワーク | 読み込むリファレンス |
   |-------------------|-----------------|
   | Express | `references/frameworks/express.md` |
   | FastAPI | `references/frameworks/fastapi.md` |
   | Flask | `references/frameworks/flask.md` |
   | Spring Boot | `references/frameworks/spring-boot.md` |
   | Gin | `references/frameworks/gin.md` |
   | Echo | `references/frameworks/echo.md` |
   | Rails | `references/frameworks/rails.md` |
   | Laravel | `references/frameworks/laravel.md` |

   **重要:** Progressive Disclosure設計に従い、検出されたフレームワークのリファレンス**のみ**を読み込むこと。不要なフレームワーク情報をコンテキストに含めないことで、トークン使用量を最適化する。

2. **OpenAPIスキーマリファレンスの読み込み**

   全フレームワーク共通で `references/openapi-schema.md` を読み込む:
   - OpenAPI 3.2.x の基本構造
   - スキーマ定義方法
   - パラメータとレスポンスの定義
   - セキュリティスキームの定義

3. **読み込み確認**
   ```
   ✓ リファレンス読み込み完了:
     - references/frameworks/[フレームワーク名].md
     - references/openapi-schema.md
   ```

---

### Phase 4: エンドポイント抽出

**目的:** フレームワーク固有のパターンを使用してAPIエンドポイントを抽出する

Phase 3で読み込んだフレームワーク別リファレンスに従い、以下を実行:

#### 4.1 ルーティングファイルの特定

1. **リファレンスの参照**
   - Phase 3で読み込んだリファレンスの「ルーティング定義ファイルの典型的な場所」セクションを確認
   - リファレンスに記載されたGlobパターンを使用

2. **ファイルの検索**
   ```bash
   # リファレンスに記載されたGlobパターンで検索
   Glob: "<リファレンスに記載されたパターン>"
   ```

#### 4.2 エンドポイント定義の検索

1. **リファレンスの参照**
   - リファレンスの「ルーティング定義パターン」セクションを確認
   - リファレンスに記載されたGrepパターンを使用

2. **エンドポイントの抽出**
   ```bash
   # リファレンスに記載されたGrepパターンでルーティング定義を抽出
   Grep: "<リファレンスに記載されたパターン>"
   ```

#### 4.3 主要なルーティングファイルの読み込み

検出されたファイルの中から、最も重要と思われるファイル(3-5個程度)を選択して読み込む:

```bash
Read: <ルーティングファイルパス>
```

---

### Phase 5: スキーマ情報の抽出

**目的:** リクエスト/レスポンスのスキーマを推定する

Phase 3で読み込んだフレームワーク別リファレンスに従い、以下を実行:

#### 5.1 型定義・モデルファイルの検索

1. **リファレンスの参照**
   - リファレンスの「パラメータ抽出」「レスポンススキーマ推定」セクションを確認
   - リファレンスに記載された型定義ファイルの場所とパターンを使用

2. **モデルファイルの検索**
   ```bash
   # リファレンスに記載されたGlobパターンで検索
   Glob: "<リファレンスに記載されたパターン>"

   # リファレンスに記載されたGrepパターンで型定義を抽出
   Grep: "<リファレンスに記載されたパターン>"
   ```

#### 5.2 バリデーション定義の検索

1. **リファレンスの参照**
   - リファレンスの「バリデーション」セクションを確認
   - リファレンスに記載された検出優先順位に従う

2. **バリデーション情報の抽出**
   - リファレンスに記載されたバリデーションライブラリパターンを使用
   - リファレンスの型マッピング表を参照してOpenAPIスキーマに変換

#### 5.3 主要なモデルファイルの読み込み

重要なモデル/スキーマファイル(3-5個程度)を読み込む。

---

### Phase 6: OpenAPI仕様書の生成

**目的:** 収集した情報を基にOpenAPI 3.2.x形式のYAMLを生成する

#### 6.1 基本構造の作成

```yaml
openapi: 3.2.0
info:
  title: <プロジェクト名>
  version: <バージョン>
  description: <プロジェクト説明>
  contact:
    name: <連絡先名>
    email: <メールアドレス>

servers:
  - url: <ベースURL>
    description: <環境説明>

paths:
  # ここにエンドポイントを追加

components:
  schemas:
    # ここにスキーマ定義を追加
  securitySchemes:
    # ここにセキュリティスキームを追加

security:
  # グローバルセキュリティ設定
```

#### 6.2 エンドポイントの追加

抽出した各エンドポイントに対して:

1. **HTTPメソッドとパスを定義**
   ```yaml
   paths:
     /api/users:
       get:
         summary: ユーザー一覧取得
         operationId: getUsers
         tags:
           - Users
   ```

2. **パラメータを追加**
   - パスパラメータ (`/users/:id` → `{id}`)
   - クエリパラメータ (`?page=1&limit=20`)
   - ヘッダーパラメータ

3. **リクエストボディを追加** (POST/PUT/PATCH)
   ```yaml
   requestBody:
     required: true
     content:
       application/json:
         schema:
           $ref: '#/components/schemas/UserCreateRequest'
   ```

4. **レスポンスを追加**
   ```yaml
   responses:
     '200':
       description: 成功
       content:
         application/json:
           schema:
             $ref: '#/components/schemas/UserResponse'
     '400':
       description: バリデーションエラー
       content:
         application/json:
           schema:
             $ref: '#/components/schemas/Error'
   ```

#### 6.3 コンポーネントスキーマの定義

抽出したモデル/型定義を基に、再利用可能なスキーマを定義:

```yaml
components:
  schemas:
    User:
      type: object
      required:
        - id
        - name
        - email
      properties:
        id:
          type: integer
          description: ユーザーID
        name:
          type: string
          minLength: 1
          maxLength: 100
          description: ユーザー名
        email:
          type: string
          format: email
          description: メールアドレス
        age:
          type: integer
          minimum: 0
          maximum: 150
          description: 年齢
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
          description: エラーコード
        message:
          type: string
          description: エラーメッセージ
```

#### 6.4 セキュリティスキームの定義

認証方式を検出した場合、適切なセキュリティスキームを追加:

```yaml
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

security:
  - bearerAuth: []
```

#### 6.5 ファイル出力

生成したYAMLを指定されたファイル名で保存:

```bash
Write: <出力ファイル名>
```

---

## 型マッピング参考表

### 言語別型 → OpenAPI型

詳細は各フレームワークのリファレンスファイルを参照してください。

**基本的なマッピング:**

| 概念 | OpenAPI |
|-----|---------|
| 文字列 | `type: string` |
| 整数 | `type: integer` |
| 浮動小数点数 | `type: number` |
| 真偽値 | `type: boolean` |
| 日付 | `type: string, format: date` |
| 日時 | `type: string, format: date-time` |
| メールアドレス | `type: string, format: email` |
| UUID | `type: string, format: uuid` |
| 配列 | `type: array, items: {...}` |
| オブジェクト | `type: object, properties: {...}` |

---

## ベストプラクティス

### 1. 情報の優先順位

以下の順序で情報を信頼する:

1. **明示的な型定義・アノテーション** (TypeScript型、Pydantic、Java DTO等)
2. **バリデーションライブラリ** (Zod, Joi, javax.validation等)
3. **フレームワークの自動生成機能** (FastAPI自動ドキュメント、Springdoc等)
4. **コード内の実装** (レスポンス内容、変数名)
5. **推測** (関数名、ファイル名から)

### 2. 不明な情報の扱い

- スキーマが不明な場合、`type: object` とする
- 説明が不明な場合、空の文字列ではなく省略する
- エンドポイントが多すぎる場合(50以上)、主要なものに絞る

### 3. セキュリティ

- 認証が必要なエンドポイントには適切な `security` を設定
- APIキー、パスワード等の機密情報を examples に含めない

### 4. YAMLフォーマット

- インデントは2スペース
- 配列は `- ` で表記
- 文字列に特殊文字がある場合は引用符で囲む

---

## トラブルシューティング

### フレームワークが検出されない場合

1. ユーザーに使用しているフレームワークを確認
2. 手動でリファレンスファイルを読み込み
3. 汎用的なパターンでエンドポイントを検索

### エンドポイントが見つからない場合

1. ルーティングファイルの場所をユーザーに確認
2. より広範なGlobパターンで検索
3. コード内で `@app.`, `@router.`, `Route::` 等を検索

### スキーマ情報が不足している場合

1. 基本的なスキーマ(id, name等)のみを定義
2. ユーザーに追加情報を質問
3. 後で手動で編集できることを伝える

---

## 制限事項

- GraphQL、gRPCは未対応(RESTful APIのみ)
- 認証フローの詳細な定義は手動編集が必要な場合がある
- 複雑なスキーマ(再帰的定義等)は簡略化される場合がある
- カスタムバリデーションロジックは反映されない場合がある

---

## 参考リソース

- [OpenAPI 3.2 Specification](https://spec.openapis.org/oas/v3.2.0.html)
- [Swagger Editor](https://editor.swagger.io/)
- [Redoc](https://github.com/Redocly/redoc)
- [OpenAPI Generator](https://openapi-generator.tech/)
