---
name: terraform-infra-analyzer
description: TerraformプロジェクトのAWSインフラにおけるネットワーク接続性と権限設定を分析します。セキュリティグループ、IAMポリシー、NACLなどを解析し、リソース間の通信可否、不要な接続、権限の過不足を検出します。Terraformファイルやtfstateがあるプロジェクトで、インフラのセキュリティレビューやネットワーク接続の検証が必要な場合に使用します。
disable-model-invocation: true
---

# Terraform Infrastructure Analyzer

## 概要

このスキルは、TerraformプロジェクトのAWSインフラを分析し、以下の2つの観点からセキュリティと設定の妥当性を評価します:

1. **ネットワーク接続性**: リソース間で意図した通信ができるか、不要な接続がないか
2. **権限の適切性**: IAMとネットワーク両方の権限が必要十分か（過剰でも不足でもないか）

## ワークフロー

### ステップ1: 環境の特定

プロジェクト内のTerraformファイル（`*.tf`、`terraform.tfstate`）を探索し、分析対象の環境を特定します。

```bash
# Terraformファイルの検索
find . -name "*.tf" -o -name "terraform.tfstate"
```

複数の環境（dev、staging、prodなど）が存在する場合は、ユーザーに分析対象を確認します。

### ステップ2: Terraform状態の取得

リモートバックエンドを使用している場合は、最新の状態を取得します。

```bash
# リモート状態の確認
terraform state pull > current_state.json
```

ローカルの`terraform.tfstate`がある場合は、そちらを使用します。

### ステップ3: ネットワーク接続性分析

`scripts/analyze_connectivity.py`を実行し、以下を分析します:

- セキュリティグループのルール
- NACLの設定
- ルートテーブルの構成
- リソース間の接続可否

```bash
python scripts/analyze_connectivity.py --state terraform.tfstate --output connectivity_report.md
```

**分析内容:**
- ✓ 意図した通信が可能かどうか（例: web → app → db）
- ✗ 不要な接続が開いていないか（例: internet → db）
- 接続マトリクスの生成

### ステップ4: 権限分析

`scripts/analyze_permissions.py`を実行し、IAMとネットワーク権限を分析します:

```bash
python scripts/analyze_permissions.py --state terraform.tfstate --output permissions_report.md
```

**分析内容:**
- IAMロール/ポリシーの過剰な権限（ワイルドカード使用など）
- 不足している可能性がある権限
- ネットワークレベルでのアクセス制御の妥当性

### ステップ5: 結果レポート

2つのレポートを統合し、以下の形式で結果を表示します:

```markdown
# インフラ分析レポート

## ネットワーク接続性
✓ 問題なし: 5件
⚠ 警告: 2件
✗ 問題: 1件

## 権限設定
✓ 適切: 8件
⚠ 過剰な権限: 3件
✗ 不足の可能性: 1件

## 詳細...
```

## トリガー条件

このスキルは以下の場合に使用します:

- ユーザーが「Terraformインフラを分析」「ネットワーク接続を確認」などと依頼した場合
- セキュリティレビューやコンプライアンスチェックが必要な場合
- インフラの権限設定を見直したい場合
- プロジェクト内に`.tf`ファイルや`terraform.tfstate`が存在する場合

## リファレンス

### scripts/analyze_connectivity.py
ネットワーク接続性を分析するPythonスクリプト。tfstateファイルを読み込み、セキュリティグループ、NACL、ルートテーブルを解析します。

### scripts/analyze_permissions.py
IAMとネットワーク権限を分析するPythonスクリプト。過剰な権限や不足している権限を検出します。

### references/aws-connectivity-patterns.md
AWS接続パターンと確認ポイントのリファレンスドキュメント。一般的なアーキテクチャパターンとセキュリティベストプラクティスを記載しています。

## 使用例

**例1: プロジェクト全体の分析**
```
ユーザー: このTerraformプロジェクトのネットワーク接続を分析して
Claude: [環境を特定 → 状態取得 → 両スクリプト実行 → レポート生成]
```

**例2: 特定環境の分析**
```
ユーザー: production環境のIAM権限をチェックして
Claude: [production/を特定 → 権限分析のみ実行 → レポート生成]
```

## 注意事項

- リモートバックエンド使用時は`terraform`コマンドが必要です
- 複数環境がある場合は、ユーザーに確認してから分析を実行します
