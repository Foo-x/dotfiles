---
name: asyncapi-spec-generator-creator
description: AsyncAPI 3.0仕様書生成スキルを作成するメタスキル。「AsyncAPI生成スキルを作成」「イベントドリブンAPI仕様書スキルを生成」等のリクエストで使用。
---

# AsyncAPI仕様書生成スキル作成メタスキル

## 概要

このメタスキルは、AsyncAPI 3.0仕様書を生成する専用のスキルファイルを作成します。

**出力物:**
- プロジェクト固有のAsyncAPI仕様書生成スキル（`SKILL.md`）
- AsyncAPI 3.0スキーマリファレンス（`references/`配下にコピー）

**注意:** このメタスキル自体はAsyncAPI仕様書を生成しません。仕様書生成用のスキルファイルを作成します。

## 使用タイミング

以下のリクエストで使用してください:

- 「AsyncAPI生成スキルを作成」
- 「イベントドリブンAPI仕様書スキルを生成」
- 「非同期API仕様書生成スキルを作る」
- 「Kafka/AMQP/MQTT API仕様スキルを生成」

## ワークフロー

### 1. スキルファイル生成

AsyncAPI仕様書生成スキルを作成します。

**生成するスキルファイルの構成:**

このスキルを実行すると、対象プロジェクトのルートに以下のファイルが生成されます：

```
.claude/skills/asyncapi-spec-generator/
├── SKILL.md                    # AsyncAPI生成スキル
└── references/
    └── asyncapi-30-schema.md    # AsyncAPI 3.0スキーマリファレンス（共通）
```

**SKILL.mdの内容:**

```yaml
---
name: asyncapi-spec-generator
description: AsyncAPI 3.0仕様書を生成し、非同期API（Kafka/AMQP/MQTT等）のイベント駆動アーキテクチャを文書化
---

# AsyncAPI 3.0仕様書生成スキル

## 概要
このスキルは、コードベースからAsyncAPI 3.0仕様書を生成します。

## ワークフロー

### フェーズ1: コードベース分析
1. イベントハンドラー/サブスクライバーの検出
2. チャネル・オペレーション構造の理解
3. メッセージスキーマの抽出

### フェーズ2: 仕様書生成
1. AsyncAPI 3.0ドキュメント構築
2. channels/operations/messagesセクション記述
3. プロトコル別バインディング追加

### フェーズ3: レビュー・出力
1. バリデーションチェック実施
2. YAML形式で出力
3. 改善提案の提示

## 制約事項
- AsyncAPI 3.0仕様に準拠
- `info.contact`フィールドは含めない
- `info.license`フィールドは含めない

## リファレンス

このスキルは以下のリファレンスを使用します:
- `references/asyncapi-30-schema.md`: AsyncAPI 3.0スキーマ定義
```

### 2. リファレンスファイルのコピー

```bash
cp /home/foox/.dotfiles/claude/skills/asyncapi-spec-generator-creator/references/asyncapi-30-schema.md \
   <出力ディレクトリ>/references/
```

### 3. 完了メッセージ

生成後、以下の情報を提供します:

```
✓ AsyncAPI仕様書生成スキルを作成しました

生成場所: <出力ディレクトリ>/SKILL.md

使用方法:
1. ターミナルで実行: `/asyncapi-spec-generator`
2. または直接呼び出し: 「AsyncAPI仕様書を生成して」
```

## 制約事項

### 必須フィールド

生成するスキルは以下のフィールドを**除外**します:

- `info.contact`
- `info.license`

これらは必要に応じて手動で追加してください。

### 出力フォーマット

- **形式**: YAML形式のみ対応
- **バージョン**: AsyncAPI 3.0.0固定
- **エンコーディング**: UTF-8

## トラブルシューティング

### スキル生成後に使用できない

**原因:** スキルの再読み込みが必要

**解決策:**
Claude Codeを再起動

### リファレンスファイルが見つからない

**原因:** コピーに失敗している

**解決策:**
```bash
cp /home/foox/.dotfiles/claude/skills/asyncapi-spec-generator-creator/references/asyncapi-30-schema.md \
   <出力ディレクトリ>/references/
```

## 使用例

### ステップ1: スキル作成（このメタスキル）

```
ユーザー: AsyncAPI生成スキルを作成して

Claude: 以下の情報を入力してください:
- スキル名: [asyncapi-spec-generator]
- 出力ディレクトリ: [./claude/skills/asyncapi-spec-generator/]
- 対象プロトコル: Kafka, AMQP

Claude: ✓ AsyncAPI仕様書生成スキルを作成しました
```

### ステップ2: 仕様書生成（生成されたスキル）

```
ユーザー: /asyncapi-spec-generator

Claude: コードベースを分析してAsyncAPI仕様書を生成します...

[仕様書がYAML形式で出力される]
```

## リファレンス

- `references/asyncapi-30-schema.md`: AsyncAPI 3.0スキーマ定義・フレームワーク検出パターン・ベストプラクティス
