---
name: security-review-generator
description: プロジェクトを分析し、最適化されたセキュリティレビュースキルとサブエージェント設定を生成するメタスキル。バックエンド、フロントエンド、インフラに応じた専門レビュースキルを自動生成。このスキル自体はセキュリティレビューを実行せず、レビュー用のスキルファイルを生成する。プロジェクト固有のセキュリティレビュー体制を構築したい時に使用。
disable-model-invocation: true
---

# Security Review Generator スキル

このスキルは、プロジェクトを分析し、そのプロジェクトに最適化されたセキュリティレビュースキルおよびサブエージェント設定を生成する**メタスキル**です。

> **重要**: このスキル自体はセキュリティレビューを実行しません。セキュリティレビューを行うためのスキルファイルを生成します。

## 概要

Security Review Generator は、以下の機能を提供します：

1. **プロジェクト分析**: 技術スタック、フレームワークを自動検出
2. **カスタムスキル生成**: プロジェクト固有のセキュリティレビュースキルを生成
3. **サブエージェント設定生成**: プロジェクトタイプに応じたサブエージェント設定ファイルを生成
4. **レビュー基準のカスタマイズ**: 適用するコンプライアンス、脅威モデル、評価手法を選択可能

## 生成されるファイル

このスキルを実行すると、対象プロジェクトのルートに以下のファイルが生成されます：

### 1. メインスキルファイル
- `.claude/skills/security-review/SKILL.md` - 実際にセキュリティレビューを実行するスキル

### 2. サブエージェント設定（プロジェクトタイプに応じて選択）
- `.claude/skills/security-review/agents/backend-security-agent.md`
- `.claude/skills/security-review/agents/frontend-security-agent.md`
- `.claude/skills/security-review/agents/infrastructure-security-agent.md`
- `.claude/skills/security-review/agents/api-security-agent.md`

### 3. 参照ファイル（必要に応じてコピー）
- `.claude/skills/security-review/references/` - 選択された手法のリファレンス

## 使用方法

```bash
/security-review-generator
```

## ワークフロー

### Phase 1: プロジェクト分析

1. **技術スタック検出**
   - `scripts/analyze_project.py` を実行
   - 言語、フレームワークを特定
   - プロジェクトタイプを判定（Backend/Frontend/Fullstack/Infrastructure）

2. **エントリーポイント特定**
   - メインファイルの検出
   - データフローのマッピング

### Phase 2: 生成オプションの確認

ユーザーに以下の設定を確認（AskUserQuestion）：

#### コンプライアンスフレームワーク（複数選択可）
- **SOC 2**: サービス組織のセキュリティ監査
- **GDPR**: EU一般データ保護規則
- **HIPAA**: 医療情報保護法（米国）
- **PCI DSS**: クレジットカード情報保護基準
- **すべて**: 全チェックを使用
- **なし**: コンプライアンスチェック不要

#### 脅威モデリング手法（複数選択可）
- **STRIDE**: なりすまし、改ざん、否認、情報漏洩、DoS、権限昇格
- **Attack Tree**: 攻撃経路の視覚化と評価
- **PASTA**: 7段階リスクベース脅威モデリング
- **すべて**: 全手法を使用
- **なし**: 脅威モデリング不要

#### リスク評価手法（複数選択可）
- **CVSS v3.1**: 業界標準の脆弱性スコアリング
- **DREAD**: Microsoft方式のリスク評価
- **ビジネス影響度**: CIA + 財務・評判への影響
- **すべて**: 全手法を使用
- **なし**: リスク評価不要

#### 脆弱性チェック項目
- **OWASP Top 10**: Webアプリケーション脆弱性
- **CWE Top 25**: 危険なソフトウェア脆弱性
- **CVE/NVD/GitHub Advisory**: 依存関係の既知脆弱性
- **すべて**: 全チェック項目を使用
- **なし**: 脆弱性チェック不要

### Phase 3: スキルファイル生成

プロジェクト分析結果とユーザー選択に基づいて、カスタマイズされたスキルファイルを生成：

#### 3.1 メインスキル生成

プロジェクト固有の `SKILL.md` を生成：
- 検出された技術スタックに特化したチェック項目
- 選択されたコンプライアンス要件
- 選択された脅威モデル・評価手法
- プロジェクト固有の参照パス

#### 3.2 サブエージェント設定生成

プロジェクトタイプに基づいて必要なサブエージェント設定を生成：

| プロジェクトタイプ | 生成されるサブエージェント |
|------------------|--------------------------|
| Backend | backend-security, api-security |
| Frontend | frontend-security |
| Fullstack | backend-security, frontend-security, api-security |
| Infrastructure | infrastructure-security |
| Fullstack + Infra | 全サブエージェント |

各サブエージェント設定には以下が含まれます：
- 実行プロンプトテンプレート
- チェック項目リスト
- 出力フォーマット仕様
- 使用するリファレンスのパス

### Phase 4: リファレンスファイルのコピー

選択された手法に必要なリファレンスファイルを `.claude/skills/security-review/references/` にコピー：

```
references/
├── stride-methodology.md        # STRIDE選択時
├── attack-tree-patterns.md      # Attack Tree選択時
├── pasta-framework.md           # PASTA選択時
├── scoring-systems.md           # リスク評価手法
├── zero-trust-checklist.md      # 常にコピー
└── compliance-frameworks.md     # コンプライアンス選択時
```

### Phase 5: 使用方法の説明

生成完了後、以下を説明：

1. **生成されたスキルの場所**
2. **スキルの有効化方法**（CLAUDE.md への登録など）
3. **実行方法**
4. **カスタマイズのヒント**

## 生成されるスキルの仕様

### メインスキル（security-review/SKILL.md）の機能

生成されるスキルは以下の機能を持ちます：

1. **並列サブエージェント実行**: Task ツールで複数のセキュリティレビューを並列実行
2. **脆弱性チェック**: OWASP Top 10、CWE、CVE/NVD の動的取得と検証
3. **脅威モデリング**: 選択された手法による分析
4. **リスク評価**: 選択された手法によるスコアリング
5. **レポート生成**: `assets/report-template.md` に基づく詳細レポート

### レポート出力先

生成されたスキルがセキュリティレビューを実行すると、以下のファイルが**プロジェクトルート**に出力されます：

```
{project_root}/
├── security-review-report.md    # メインレポート（エグゼクティブサマリー、技術詳細、改善ロードマップ）
├── security-findings.json       # 発見事項の構造化データ（finding-schema.json 準拠）
├── compliance-mapping.json      # コンプライアンスフレームワークとのマッピング
└── security-roadmap.md          # 優先度付き改善ロードマップ
```

### サブエージェント設定の内容

各サブエージェント設定（`agents/*.md`）には以下が含まれます：

```markdown
# {Agent Name} Security Agent

## 役割
{エージェントの責務の説明}

## チェック項目
{プロジェクト固有のチェックリスト}

## 実行プロンプト
{Task ツールに渡すプロンプトテンプレート}

## 出力フォーマット
{findings.json スキーマに準拠した出力形式}
```

## スクリプト使用方法

### プロジェクト分析

```bash
python scripts/analyze_project.py /path/to/project
```

出力例：
```json
{
  "project_type": "fullstack",
  "languages": ["Python", "JavaScript"],
  "frameworks": ["Django", "React"],
  "entry_points": ["main.py", "index.js"],
  "recommended_subagents": [
    "backend-security",
    "frontend-security",
    "api-security"
  ]
}
```

### サブエージェントプロンプト生成

```bash
python scripts/generate_subagent.py references/subagent-templates backend-security context.json
```

### 脆弱性検索（生成されたスキルで使用）

```bash
# 単一パッケージの検索
python scripts/vulnerability_lookup.py search django 4.2.0

# 依存関係の一括検索
python scripts/vulnerability_lookup.py batch dependencies.json
```

## テンプレートリファレンス

### セキュリティフレームワーク

- `references/stride-methodology.md`: STRIDE 脅威モデリング手法
- `references/attack-tree-patterns.md`: Attack Tree 構築パターン
- `references/pasta-framework.md`: PASTA 7段階プロセス

### スコアリングシステム

- `references/scoring-systems.md`: CVSS v3.1、DREAD、ビジネス影響度評価

### セキュリティ原則

- `references/zero-trust-checklist.md`: Zero Trust 原則チェックリスト

### コンプライアンス

- `references/compliance-frameworks.md`: SOC 2、GDPR、HIPAA、PCI DSS マッピング

### サブエージェントテンプレート

- `references/subagent-templates/backend-security.md`: バックエンドレビュー
- `references/subagent-templates/frontend-security.md`: フロントエンドレビュー
- `references/subagent-templates/infrastructure-security.md`: インフラレビュー
- `references/subagent-templates/api-security.md`: API レビュー

## 出力ディレクトリ構造

スキル実行後にプロジェクトルートに生成される構造：

```
.claude/
└── skills/
    └── security-review/
        ├── SKILL.md                    # メインスキル（セキュリティレビュー実行用）
        ├── agents/
        │   ├── backend-security-agent.md
        │   ├── frontend-security-agent.md
        │   ├── infrastructure-security-agent.md
        │   └── api-security-agent.md
        ├── assets/
        │   ├── finding-schema.json     # 発見事項スキーマ
        │   └── report-template.md      # レポートテンプレート
        └── references/
            ├── stride-methodology.md
            ├── scoring-systems.md
            └── ...（選択された手法のみ）
```

## 実装例

スキル実行時の内部フロー：

```markdown
1. ユーザーがスキルを実行
   ↓
2. プロジェクトパスを取得（デフォルト: カレントディレクトリ）
   ↓
3. analyze_project.py を実行してプロジェクト分析
   ↓
4. ユーザーに生成オプションを確認（AskUserQuestion）
   - コンプライアンスフレームワーク
   - 脅威モデリング手法
   - リスク評価手法
   - 脆弱性チェック項目
   ↓
5. 必要なサブエージェント設定を特定
   ↓
6. メインスキル（SKILL.md）を生成
   - プロジェクト固有の設定を埋め込み
   - 選択された手法のワークフローを構築
   ↓
7. サブエージェント設定ファイルを生成
   - テンプレートをカスタマイズ
   - プロジェクト情報を埋め込み
   ↓
8. 必要なリファレンスファイルをコピー
   ↓
9. 生成結果をユーザーに報告
   - 生成されたファイルの一覧
   - スキルの有効化・実行方法
   ↓
10. （任意）ユーザーが生成されたスキルを実行してセキュリティレビュー開始
```

## カスタマイズ

### 新しいサブエージェントテンプレートの追加

1. `references/subagent-templates/` に新しいテンプレートを追加
2. `scripts/analyze_project.py` で推奨ロジックに追加
3. `scripts/generate_subagent.py` でテンプレート読み込みを確認

### コンプライアンスフレームワークの追加

1. `references/compliance-frameworks.md` に新しいフレームワークを追加
2. `assets/finding-schema.json` の `compliance_mapping` に新しいプロパティを追加
3. Phase 2 の選択肢に追加

### カスタムスコアリングシステムの追加

1. `references/scoring-systems.md` に新しいシステムを追加
2. Phase 2 の選択肢に追加

## ベストプラクティス

### スキル生成時

1. **正確なプロジェクトパス**: 依存関係ファイルが含まれるルートディレクトリを指定
2. **適切な手法選択**: プロジェクト規模とセキュリティ要件に応じて選択
3. **コンプライアンス要件の確認**: 法的要件がある場合は必ず選択

### 生成後

1. **スキルのレビュー**: 生成された SKILL.md を確認し、必要に応じて調整
2. **サブエージェントの調整**: プロジェクト固有のチェック項目を追加
3. **テスト実行**: 小さなスコープでテスト実行してから本番利用

## トラブルシューティング

### スクリプト実行エラー

```bash
chmod +x scripts/*.py
```

### プロジェクト分析が不正確

手動で `context.json` を作成して `generate_subagent.py` に渡すことで、正確な設定を生成できます。

### 生成されたスキルが動作しない

1. 生成された SKILL.md のパス参照を確認
2. リファレンスファイルが正しくコピーされているか確認

## 制限事項

1. **生成のみ**: このスキル自体はセキュリティレビューを実行しない
2. **テンプレートベース**: 完全なカスタマイズには手動編集が必要
3. **言語/フレームワーク依存**: サポートされていない技術スタックは手動設定が必要

## FAQ

**Q: このスキルでセキュリティレビューできますか？**
A: いいえ。このスキルはセキュリティレビューを行うスキルを「生成」します。生成後に、生成されたスキルを実行してください。

**Q: 生成されたスキルはどこに保存されますか？**
A: プロジェクトルートの `.claude/skills/security-review/` に保存されます。

**Q: 既存のスキルを更新できますか？**
A: はい。同じプロジェクトで再実行すると、既存のファイルを上書きするか確認されます。

**Q: 複数のプロジェクト用に異なるスキルを生成できますか？**
A: はい。各プロジェクトで実行すると、それぞれのプロジェクトに最適化されたスキルが生成されます。

## サポート

問題や質問がある場合は、以下のリソースを参照してください：

- [OWASP Top 10](https://owasp.org/Top10/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
