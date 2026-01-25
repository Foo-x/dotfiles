---
name: openapi-spec-generator
description: OpenAPI 3.2仕様書生成スキルを作成するメタスキル。「OpenAPI生成スキルを作成」「API仕様書スキルを生成」等のリクエストで使用。
---

# OpenAPI 3.2 API仕様書生成スキル（メタスキル）

## 概要

このメタスキルは、**汎用的なOpenAPI仕様書生成スキル**を作成します。

**このメタスキルの出力物:**
- OpenAPI仕様書生成スキル

**使用タイミング:**
- 「OpenAPI仕様書生成スキルを作成して」
- 「API仕様書スキルを生成して」
- 「OpenAPI生成スキルを作って」
- 「API仕様書スキルを作成して」

## ワークフロー

### 1. スキルファイルの生成

OpenAPI仕様書生成スキルを作成します。

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
1. SKILL.mdテンプレートを作成
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
- スキル名は`openapi-generator`形式
- 出力ディレクトリは既存のものを上書きしない

### 生成されるスキルの制約
- OpenAPI 3.2仕様に完全準拠
- `info.contact`フィールドは含めない
- `info.license`フィールドは含めない
- YAML形式で出力（JSONは非推奨）

### ベストプラクティス
- プロジェクト固有の情報（言語、フレームワーク、ファイルパス、バージョン等）はスキルに含めない（CLAUDE.mdから提供されるため）

## トラブルシューティング

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
