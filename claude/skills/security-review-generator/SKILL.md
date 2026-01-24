---
name: security-review-generator
description: プロジェクトを分析し、最適化されたセキュリティレビュースキルとサブエージェントを生成。バックエンド、フロントエンド、インフラに応じた専門レビューを実施。SOC2/GDPR等のコンプライアンス要件を確認し、OWASP Top 10/CWE/CVE/NVD/GitHub Advisory チェック、STRIDE/Attack Tree/PASTA分析、CVSS/DREAD/ビジネス影響度評価を実行。Zero Trust原則に従う。セキュリティ監査、脆弱性評価、コンプライアンスチェック時に使用。
---

# Security Review Generator スキル

このスキルは、プロジェクトを包括的に分析し、適切なセキュリティレビューを自動的に実行します。

## 概要

Security Review Generator は、以下の機能を提供します：

1. **プロジェクト分析**: 技術スタック、フレームワーク、依存関係を自動検出
2. **専門サブエージェント生成**: プロジェクトタイプに応じたセキュリティレビューエージェントを生成
3. **包括的セキュリティ分析**: OWASP Top 10、CWE、CVE/NVD、脅威モデリング（STRIDE、Attack Tree、PASTA）
4. **コンプライアンスチェック**: SOC 2、GDPR、HIPAA、PCI DSS対応
5. **リスク評価**: CVSS、DREAD、ビジネス影響度分析
6. **詳細レポート生成**: 優先度付き改善ロードマップと ROI 分析

## 使用方法

```bash
/security-review-generator
```

または、特定のプロジェクトパスを指定：

```bash
/security-review-generator /path/to/project
```

## ワークフロー

### Phase 1: プロジェクト分析

1. **技術スタック検出**
   - `scripts/analyze_project.py` を実行
   - 言語、フレームワーク、依存関係を特定
   - プロジェクトタイプを判定（Backend/Frontend/Fullstack/Infrastructure）

2. **エントリーポイント特定**
   - メインファイルの検出
   - データフローのマッピング

### Phase 2: コンプライアンス確認

ユーザーに適用可能なコンプライアンスフレームワークを確認：

- **SOC 2**: サービス組織のセキュリティ監査
- **GDPR**: EU一般データ保護規則
- **HIPAA**: 医療情報保護法（米国）
- **PCI DSS**: クレジットカード情報保護基準

### Phase 3: サブエージェント生成と並列実行

プロジェクトタイプに基づいて専門サブエージェントを生成し、Task ツールで並列実行：

1. **Backend Security Reviewer**
   - 認証・認可のチェック
   - インジェクション攻撃対策
   - データ保護と暗号化
   - API セキュリティ

2. **Frontend Security Reviewer**
   - XSS 対策
   - CSRF 対策
   - セキュアな認証フロー
   - Third-party スクリプトのセキュリティ

3. **Infrastructure Security Reviewer**
   - コンテナセキュリティ（Docker/Kubernetes）
   - IaC セキュリティ（Terraform/CloudFormation）
   - クラウドセキュリティ（AWS/Azure/GCP）
   - CI/CD パイプラインセキュリティ

4. **API Security Reviewer**
   - 認証・認可
   - レート制限
   - 入力検証
   - OWASP API Top 10

### Phase 4: セキュリティ分析（並列実行）

#### 4.1 脅威モデリング

**STRIDE 分析**:
- Spoofing（なりすまし）
- Tampering（改ざん）
- Repudiation（否認）
- Information Disclosure（情報漏洩）
- Denial of Service（サービス拒否）
- Elevation of Privilege（権限昇格）

**Attack Tree 分析**:
- 攻撃経路の視覚化
- 攻撃コストと成功率の評価
- 防御策の優先順位付け

**PASTA フレームワーク**:
1. Define Objectives（目的の定義）
2. Define Technical Scope（技術範囲の定義）
3. Application Decomposition（アプリケーション分解）
4. Threat Analysis（脅威分析）
5. Vulnerability Analysis（脆弱性分析）
6. Attack Modeling（攻撃モデリング）
7. Risk and Impact Analysis（リスクと影響の分析）

#### 4.2 脆弱性チェック

**OWASP Top 10 動的取得**:

WebFetchツールを使用して最新のOWASP Top 10情報を取得:
- 最新版一覧: https://owasp.org/Top10/ (常に最新版にリダイレクト)
- 取得したページからカテゴリリンクを抽出し、各カテゴリ詳細も取得
- セッション内でキャッシュして再利用

**CWE 動的取得**:

WebFetchツールを使用して最新のCWE情報を取得:
- Top 25最新版: https://cwe.mitre.org/top25/
- CWE詳細API: https://cwe-api.mitre.org/api/v1/cwe/weakness/{id}
- セッション内でキャッシュして再利用

#### 4.3 依存関係スキャン

- `scripts/vulnerability_lookup.py` を使用
- CVE/NVD データベース検索
- GitHub Advisory Database 検索
- 既知の脆弱性のレポート生成

#### 4.4 Zero Trust 検証

すべてのコンポーネントで Zero Trust 原則を検証：

1. **明示的な検証（Verify Explicitly）**
   - すべてのアクセスで認証・認可を実施
   - すべてのデータポイントで検証

2. **最小権限アクセス（Least Privilege Access）**
   - Just-In-Time（JIT）およびJust-Enough-Access（JEA）
   - リスクベースの適応型ポリシー

3. **侵害を想定（Assume Breach）**
   - セグメンテーション
   - エンドツーエンド暗号化
   - 継続的な監視

### Phase 5: リスク評価

#### 5.1 CVSS v3.1 スコアリング

各脆弱性に対して CVSS スコアを算出：

- Attack Vector（AV）
- Attack Complexity（AC）
- Privileges Required（PR）
- User Interaction（UI）
- Scope（S）
- Confidentiality Impact（C）
- Integrity Impact（I）
- Availability Impact（A）

スコア範囲：
- 9.0-10.0: Critical
- 7.0-8.9: High
- 4.0-6.9: Medium
- 0.1-3.9: Low

#### 5.2 DREAD リスク評価

- Damage（損害の可能性）: 0-10
- Reproducibility（再現性）: 0-10
- Exploitability（悪用の容易さ）: 0-10
- Affected users（影響を受けるユーザー）: 0-10
- Discoverability（発見の容易さ）: 0-10

#### 5.3 ビジネス影響度分析

- **機密性（Confidentiality）**: Critical/High/Medium/Low
- **完全性（Integrity）**: Critical/High/Medium/Low
- **可用性（Availability）**: Critical/High/Medium/Low
- **財務影響**: 潜在的な金銭的損失の計算
- **評判への影響**: ブランド価値への影響評価

#### 5.4 対策コスト vs リスク評価

- 対策実装コストの算出
- リスク軽減額の計算
- ROI（投資対効果）の分析
- 優先度マトリクスの作成

### Phase 6: レポート生成

#### 6.1 発見事項の統合

すべてのサブエージェントからの発見事項を統合：

- 重複の排除
- 優先度順にソート
- JSON スキーマに準拠したデータ構造化（`assets/finding-schema.json`）

#### 6.2 コンプライアンスマッピング

発見事項を各コンプライアンスフレームワークの要件にマッピング：

```markdown
| 発見事項 | SOC 2 | GDPR | HIPAA | PCI DSS |
|---------|-------|------|-------|---------|
| SEC-001 | CC6.1 | Art.32 | §164.312 | Req 6.5.1 |
```

#### 6.3 改善ロードマップ生成

優先度付き改善計画を作成：

**Phase 1: 即時対応（1-2週間）**
- P0 優先度の脆弱性
- Critical 重要度の問題

**Phase 2: 短期対応（1-2ヶ月）**
- P1 優先度の脆弱性
- High 重要度の問題

**Phase 3: 中期対応（3-6ヶ月）**
- P2 優先度の脆弱性
- Medium 重要度の問題

**Phase 4: 長期対応（6-12ヶ月）**
- P3 優先度の脆弱性
- Low 重要度の問題、戦略的改善

#### 6.4 最終レポート作成

`assets/report-template.md` に基づいてレポートを生成：

1. **エグゼクティブサマリー**
   - 主要な発見事項
   - 総合リスクレベル
   - 即座の対応が必要な項目

2. **技術的詳細**
   - 各発見事項の詳細
   - 再現手順
   - 修正方法

3. **リスク評価**
   - リスクマトリクス
   - ビジネス影響分析

4. **改善ロードマップ**
   - フェーズ別の対応計画
   - 工数とコストの見積もり
   - ROI 分析

5. **コンプライアンスマッピング**
   - 各フレームワークとの対応表

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
  "dependencies": {
    "pip": ["django", "djangorestframework"],
    "npm": ["react", "axios"]
  },
  "recommended_subagents": [
    "backend-security",
    "frontend-security",
    "api-security"
  ]
}
```

### サブエージェント生成

```bash
python scripts/generate_subagent.py references/subagent-templates backend-security context.json
```

### 脆弱性検索

```bash
# 単一パッケージの検索
python scripts/vulnerability_lookup.py search django 4.2.0

# 依存関係の一括検索
python scripts/vulnerability_lookup.py batch dependencies.json
```

## リファレンスファイル

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

## 出力ファイル

### レポート

デフォルトでは、以下のファイルが生成されます：

- `security-review-report.md`: メインレポート
- `findings.json`: 発見事項の JSON データ
- `compliance-mapping.json`: コンプライアンスマッピング
- `roadmap.md`: 改善ロードマップ

### 発見事項スキーマ

すべての発見事項は `assets/finding-schema.json` に準拠した JSON 形式で保存されます。

## 実装例

スキル実行時の内部フロー：

```markdown
1. ユーザーがスキルを実行
   ↓
2. プロジェクトパスを取得（デフォルト: カレントディレクトリ）
   ↓
3. analyze_project.py を実行
   ↓
4. ユーザーにコンプライアンス要件を確認（AskUserQuestion）
   - SOC 2が必要か？
   - GDPRが必要か？
   - HIPAAが必要か？
   - PCI DSSが必要か？
   ↓
5. 推奨サブエージェントを生成
   ↓
6. Task ツールで複数のサブエージェントを並列実行
   - Backend Security Reviewer
   - Frontend Security Reviewer
   - Infrastructure Security Reviewer
   - API Security Reviewer
   ↓
7. 各サブエージェントが発見事項を報告
   ↓
8. 発見事項を統合・重複排除
   ↓
9. リスク評価（CVSS、DREAD、ビジネス影響度）
   ↓
10. コンプライアンスマッピング
   ↓
11. 改善ロードマップ生成
   ↓
12. 最終レポート作成
   ↓
13. ユーザーにレポートを提示
```

## カスタマイズ

### 新しいサブエージェントの追加

1. `references/subagent-templates/` に新しいテンプレートを追加
2. `scripts/analyze_project.py` で推奨ロジックに追加

### コンプライアンスフレームワークの追加

1. `references/compliance-frameworks.md` に新しいフレームワークを追加
2. `assets/finding-schema.json` の `compliance_mapping` に新しいプロパティを追加

### カスタムスコアリングシステムの追加

1. `references/scoring-systems.md` に新しいシステムを追加
2. レポートテンプレートに統合

## ベストプラクティス

### スキル実行前

1. **プロジェクトのバックアップ**: レビュー前にバックアップを取得
2. **依存関係の最新化**: `npm install` または `pip install` を実行
3. **テスト環境での実行**: 本番環境ではなくテスト環境で実行

### レビュー中

1. **False Positive の確認**: 自動検出された脆弱性を手動で確認
2. **コンテキストの考慮**: フレームワークの組み込み保護機能を考慮
3. **優先順位の調整**: ビジネス要件に基づいて優先順位を調整

### レビュー後

1. **即座の対応**: P0 優先度の脆弱性を即座に修正
2. **定期的なレビュー**: 四半期ごとまたはメジャーリリース前に実行
3. **継続的改善**: DevSecOps パイプラインに統合

## トラブルシューティング

### 依存関係のインストールエラー

```bash
# Python依存関係
pip install -r requirements.txt

# Node.js依存関係（該当する場合）
npm install
```

### スクリプト実行エラー

スクリプトに実行権限を付与：

```bash
chmod +x scripts/*.py
```

### サブエージェントが起動しない

1. テンプレートファイルの存在確認
2. プロジェクト分析結果の確認
3. Task ツールのログを確認

## 制限事項

1. **自動スキャンの限界**: すべての脆弱性を検出できるわけではない
2. **False Positive**: 一部の発見事項は誤検知の可能性がある
3. **ビジネスロジックの脆弱性**: カスタムビジネスロジックの脆弱性は手動レビューが必要
4. **ゼロデイ脆弱性**: 既知の脆弱性のみ検出可能

## FAQ

**Q: どのくらいの時間がかかりますか？**
A: プロジェクトサイズによりますが、小規模プロジェクトで5-10分、大規模プロジェクトで30-60分程度です。

**Q: レビュー結果は保存されますか？**
A: はい、カレントディレクトリに `security-review-report.md` および関連ファイルが保存されます。

**Q: 複数のプロジェクトを一度にレビューできますか？**
A: 現在は1プロジェクトずつのレビューを推奨していますが、スクリプトを直接実行することで複数プロジェクトに対応可能です。

**Q: コンプライアンス認証を取得できますか？**
A: このスキルはコンプライアンス要件への準拠をチェックしますが、認証取得には専門の監査機関が必要です。

**Q: CI/CD パイプラインに統合できますか？**
A: はい、スクリプトを直接実行することで CI/CD に統合可能です。

## サポート

問題や質問がある場合は、以下のリソースを参照してください：

- [OWASP Top 10](https://owasp.org/Top10/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
