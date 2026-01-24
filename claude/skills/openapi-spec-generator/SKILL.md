---
name: openapi-spec-generator
description: プロジェクトを分析し、そのプロジェクト専用のOpenAPI 3.2仕様書生成スキルを作成するメタスキル。言語、フレームワークを検出し、カスタマイズされたスキルファイルを出力。「OpenAPI生成スキルを作成」「API仕様書スキルを生成」等のリクエストで使用。
---

# OpenAPI 3.2 API仕様書生成スキル（メタスキル）

## 概要

このメタスキルは、プロジェクトのコードベースを分析し、**そのプロジェクト専用のOpenAPI仕様書生成スキル**を作成します。フレームワーク、エンドポイントパターンを検出し、プロジェクトに最適化されたスキルファイルとリファレンスを生成します。

**このメタスキルの出力物:**
- プロジェクト専用のOpenAPI仕様書生成スキル
- フレームワーク固有のパターン定義（references/）

**使用タイミング:**
- 「このプロジェクト用のOpenAPI仕様書生成スキルを作成して」
- 「API仕様書スキルを生成して」
- 「プロジェクト専用のOpenAPI生成スキルを作って」
- 「カスタムAPI仕様書スキルを作成して」

## ワークフロー

### 1. 対象プロジェクトの分析

まず、対象プロジェクトのディレクトリ構造を分析し、使用されているフレームワークと技術スタックを検出します。

**検出対象フレームワーク:**
- **Node.js**: Express, Fastify, Koa, NestJS, Hono
- **Python**: FastAPI, Flask, Django REST Framework, Starlette
- **Go**: Gin, Echo, Chi, Fiber, Gorilla Mux
- **Java/Kotlin**: Spring Boot, Ktor, Micronaut
- **Ruby**: Rails, Sinatra, Grape
- **PHP**: Laravel, Symfony, Slim
- **Rust**: Actix-web, Rocket, Axum, Warp
- **.NET**: ASP.NET Core

**実行手順:**
1. `Glob`ツールで`package.json`, `requirements.txt`, `go.mod`, `pom.xml`, `Gemfile`, `composer.json`, `Cargo.toml`, `*.csproj`を検索
2. 設定ファイルを`Read`して依存関係を確認
3. 言語とフレームワークを抽出

### 2. スキルファイルの生成

分析結果を基に、OpenAPI仕様書生成スキルを作成します。

**生成するスキルファイルの構成:**

生成されるスキルは以下の構造を持ちます：

```
.claude/skills/openapi-generator/
├── SKILL.md                    # OpenAPI生成スキル
└── references/
    └── openapi-32-schema.md    # OpenAPI 3.2スキーマリファレンス（共通）
```

**SKILL.mdの内容:**
```yaml
---
name: openapi-generator
description: OpenAPI 3.2仕様書をYAML形式で生成。REST APIエンドポイントとスキーマを自動検出。
---

# OpenAPI 3.2仕様書生成スキル

## 概要
このスキルは、コードベースからOpenAPI 3.2仕様書を生成します。

## プロジェクト情報
- **言語**: [検出された言語]
- **フレームワーク**: [検出されたフレームワーク]

## ワークフロー
1. コードベースを分析してエンドポイントを動的に検出
2. コードベースを分析して型定義・スキーマを動的に抽出
3. コードベースを分析して認証方式を動的に検出
4. OpenAPI 3.2仕様書を生成
5. YAML形式で出力（openapi.yaml）

## 制約事項
- OpenAPI 3.2仕様に準拠
- `info.contact`フィールドは含めない
- `info.license`フィールドは含めない

## リファレンス
OpenAPI 3.2仕様の詳細は`references/openapi-32-schema.md`を参照してください。
```

**生成手順:**
1. 言語とフレームワーク情報を埋め込んだSKILL.mdテンプレートを作成
2. openapi-32-schema.md（共通リファレンス）をコピー

### 3. スキルディレクトリの出力

生成したスキルファイルをディレクトリとして出力します。

**出力先:**
- デフォルト: `.claude/skills/openapi-generator/`
- ユーザー指定があれば別のディレクトリ名を使用

**実行手順:**
1. `Bash`ツールでディレクトリを作成（`mkdir -p`）
2. `Write`ツールでSKILL.mdを作成
3. `Bash`ツールでopenapi-32-schema.mdをコピー
4. 生成完了メッセージと使用方法を表示

## 制約事項

### スキル生成の制約
- フレームワークが検出できない場合はエラーメッセージを表示
- スキル名は`openapi-generator`形式
- 出力ディレクトリは既存のものを上書きしない

### 生成されるスキルの制約
- OpenAPI 3.2仕様に完全準拠
- `info.contact`フィールドは含めない
- `info.license`フィールドは含めない
- YAML形式で出力（JSONは非推奨）

### ベストプラクティス
- 言語とフレームワーク情報のみをスキルに含める
- 実装詳細（ファイルパス、バージョン等）はスキルに含めない

## トラブルシューティング

### フレームワークが検出されない場合
1. サポート対象フレームワークのリストを確認
2. 設定ファイル（`package.json`, `requirements.txt`等）が存在するか確認
3. プロジェクトルートから実行しているか確認

### エンドポイントが見つからない場合
1. ルート定義ファイルを手動で確認
2. 非標準的なディレクトリ構造の場合、ユーザーに情報提供を依頼

### 生成されたスキル実行時にスキーマが見つからない場合
1. 型定義ファイルの場所を確認

### 生成後の使用方法
1. 生成されたスキルディレクトリを確認
2. 生成されたスキルを実行して、実際のopenapi.yamlを生成
3. 必要に応じてSKILL.mdをカスタマイズ

## 使用例

### 基本的な使用フロー

```
# 1. メタスキルを実行（このスキル）
ユーザー: 「OpenAPI生成スキルを作成して」
→ .claude/skills/openapi-generator/ ディレクトリが生成される

# 2. 生成されたスキルを使用
ユーザー: 「openapi-generator スキルを使ってAPI仕様書を作成して」
→ openapi.yaml が生成される
```
