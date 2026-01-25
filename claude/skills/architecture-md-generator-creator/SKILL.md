---
name: architecture-md-generator-creator
description: ARCHITECTURE.md生成スキルを作成するメタスキル。「ARCHITECTURE生成スキルを作成」「アーキテクチャドキュメントスキルを生成」等のリクエストで使用。このメタスキル自体はARCHITECTURE.mdを生成せず、生成用のスキルファイルを作成する。
---

# Architecture Md Generator Creator

このメタスキルは、**ARCHITECTURE.md生成用のスキルを作成**するためのツールです。

## 重要な注意事項

⚠️ **このメタスキル自体はARCHITECTURE.mdを生成しません**

- このスキルは`architecture-md-generator`スキルを**作成**します
- 作成されたスキルが実際にARCHITECTURE.mdを生成します
- 2段階のプロセス: (1) スキル作成 → (2) スキル実行

## 生成されるファイル

このスキルを実行すると、対象プロジェクトのルートに以下のファイルが生成されます：

```
.claude/skills/architecture-md-generator/
├── SKILL.md                              # スキル本体
└── references/
    └── architecture-guide.md             # ARCHITECTURE.md構造ガイド
```

生成されたスキルは以下の機能を持ちます:
- プロジェクト分析（言語、フレームワーク、依存関係の検出）
- 外部依存サービスの抽出
- Mermaid形式のシステム構成図生成
- コードマップの作成（ディレクトリ構造）
- ARCHITECTURE.md出力

## ワークフロー

### Phase 1: スキル生成

以下のファイルを作成します:

#### 1. SKILL.md（スキル本体）

テンプレート: `assets/skill-template/SKILL.md.template`

**フロントマター:**
```yaml
---
name: architecture-md-generator
description: ARCHITECTURE.mdを生成。コードベースを分析してシステム構成図、外部依存、コードマップを自動作成。
---
```

**本文:**
- 5ステップワークフロー（分析→依存抽出→構成図生成→コードマップ→出力）
- ARCHITECTURE.md出力フォーマット仕様
- 依存関係ファイル検出パターン

#### 2. references/architecture-guide.md

ARCHITECTURE.md作成のベストプラクティスガイド:
- Overviewセクションの書き方
- Mermaid構成図のパターン
- 外部依存の分類方法
- コードマップの構造

**ファイル生成時の指示:**
```bash
# 出力先ディレクトリを作成
mkdir -p <output_path>/references

# テンプレートから生成
# (このメタスキルのassetsディレクトリを参照)
```

### Phase 3: 使用方法の説明

生成完了後、以下を説明します:

1. **スキルの使用方法:**
   - スキルをインストール後、プロジェクトルートで実行
   - コマンド例: `/architecture-md-generator` または「ARCHITECTURE.mdを生成して」

2. **生成されるARCHITECTURE.mdの構造:**
   ```markdown
   # Architecture

   ## Overview
   [プロジェクトの概要]

   ## System Diagram
   [Mermaid構成図]

   ## External Services

   ## Code Map
   ### Directory Structure
   ```

## 使用例

### 基本的な使用方法

```
ユーザー: ARCHITECTURE生成スキルを作成して
```

→ このメタスキルが起動し、`architecture-md-generator`スキルを生成

### 生成されたスキルの使用

```
ユーザー: ARCHITECTURE.mdを生成して
```

→ `architecture-md-generator`スキルが起動し、ARCHITECTURE.mdを作成

## デザイン原則

1. **生成と実行の分離**
   - メタスキル: スキルファイルの生成のみ
   - 生成スキル: ARCHITECTURE.mdの作成のみ

2. **プロジェクト非依存**
   - 生成されるスキルは汎用的
   - プロジェクト固有の情報は実行時に分析

3. **カスタマイズ可能**
   - テンプレートベースで拡張可能
   - リファレンスガイドで構造を明示

## トラブルシューティング

### スキルが生成されない

- 出力先ディレクトリの書き込み権限を確認
- パスに特殊文字が含まれていないか確認

### 生成されたスキルが動作しない

- SKILL.mdのフロントマターが正しいか確認
- references/ディレクトリが存在するか確認
- パッケージ化スクリプトのパスが正しいか確認

## 参考資料

- `assets/skill-template/` - スキルテンプレート一式
