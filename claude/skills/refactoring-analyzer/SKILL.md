---
name: refactoring-analyzer
description: |
  プロジェクトのコードを分析し、リファクタリングが必要な箇所を特定して改善提案を行うスキル。
  以下の場合に使用する:
  - コードレビューでリファクタリング候補を洗い出したい時
  - 技術的負債を可視化したい時
  - プロジェクト全体または特定ファイルのコード品質を評価したい時
disable-model-invocation: true
---

# リファクタリング分析スキル

コードベースを体系的に分析し、リファクタリングが必要な箇所を特定して、具体的な改善提案を提供します。

**重要**: このスキルは**分析と提案のみ**を行います。実際のコード修正は行いません。

## 分析ワークフロー

### 1. スコープ確認
- 対象範囲を確認（プロジェクト全体、特定ディレクトリ、特定ファイル）
- 除外パターンを確認（`node_modules/`, `vendor/`, `build/`, `dist/`等）
- 分析の深さを確認（クイックスキャン vs 詳細分析）

### 2. コードベースの探索
- ディレクトリ構造を把握
- 主要ファイルを特定（サイズ、複雑度、変更頻度）
- 言語・フレームワークを識別

### 3. 多角的分析（サブエージェント並列実行）

以下の4つの分析を**サブエージェントで並列実行**します:

#### 3.1 プログラミング原則分析（サブエージェント使用）
- **モデル**: `claude sonnet` or `codex high` or `gemini pro`
- **プロンプトテンプレート**: `references/subagent-templates/principles-analyzer.md`
- **参照ドキュメント**: `references/principles.md`
- **出力形式**: JSON（違反のリスト、重大度、改善提案）

#### 3.2 コードスメル検出（サブエージェント使用）
- **モデル**: `claude haiku` or `gpt mini high` or `gemini flash`
- **プロンプトテンプレート**: `references/subagent-templates/code-smell-detector.md`
- **参照ドキュメント**: `references/code-smells.md`
- **出力形式**: JSON（スメルのリスト、重大度、リファクタリング手法）

#### 3.3 品質メトリクス評価（サブエージェント使用）
- **モデル**: `claude haiku` or `gpt mini high` or `gemini flash`
- **プロンプトテンプレート**: `references/subagent-templates/metrics-evaluator.md`
- **参照ドキュメント**: `references/metrics.md`
- **出力形式**: JSON（メトリクス測定値、閾値超過箇所、改善提案）

#### 3.4 テストコード品質（サブエージェント使用）
- **モデル**: `claude sonnet` or `codex high` or `gemini pro`
- **プロンプトテンプレート**: `references/subagent-templates/test-quality-reviewer.md`
- **参照ドキュメント**: `references/test-smells.md`, `references/principles.md`（テスト原則）
- **出力形式**: JSON（テストスメル、原則違反、テストバランス評価）

### 4. 結果の統合とMarkdownレポートの生成

4つのサブエージェントから返されたJSON結果を統合し、Markdownレポートを生成します:

#### 4.1 サブエージェント結果の統合
各サブエージェントのJSON出力を収集:
- プログラミング原則分析: 原則違反のリスト
- コードスメル検出: コードスメルのリスト
- 品質メトリクス評価: メトリクス測定値
- テストコード品質: テストスメルと原則違反

#### 4.2 レポートファイルの作成
[references/output-format.md](references/output-format.md)の形式に従ってMarkdownレポートを作成:

- 全サブエージェントの結果を統合
- 優先度の割り当て（Critical / High / Medium / Low）
- 問題の明確な説明
- 現在のコード例
- 改善後のコード例
- 改善の効果

#### 4.3 ファイル出力
Writeツールを使用してMarkdownファイルとして保存します:

**ファイル名規則**:
- プロジェクト全体: `refactoring-report-{YYYYMMDD-HHMMSS}.md`
- 特定ディレクトリ: `refactoring-report-{dir-name}-{YYYYMMDD-HHMMSS}.md`
- 特定ファイル: `refactoring-report-{file-name}-{YYYYMMDD-HHMMSS}.md`

**保存場所**:
- デフォルト: カレントディレクトリ
- ユーザー指定がある場合はその場所

**必須セクション**:
1. ヘッダー（分析対象、日時、検出項目数）
2. エグゼクティブサマリー
3. 検出項目サマリー（原則違反、スメル、メトリクス、テスト品質）
4. 詳細（各問題の詳細説明）
5. 推奨実装順序

**オプションセクション**:
- メトリクスサマリー（複雑度分布、ファイルサイズ分布等）
- テストバランス評価（ピラミッド/トロフィー）
- 付録（用語集、参考リンク等）

#### 4.4 出力の確認
レポート生成後、ユーザーに以下を伝えます:
- 生成されたファイルのパス
- 検出項目数の概要（原則違反、スメル、メトリクス、テスト問題）
- 優先度別の内訳

## 分析のベストプラクティス

### DO（推奨）
- **コンテキストを理解する**: プロジェクトの目的、チームの規模、期限を考慮
- **具体的な例を示す**: 必ず現在のコードと改善後のコードを提示
- **影響を説明する**: なぜその変更が価値があるのかを明確に
- **段階的な改善**: 一度に全てを変更せず、優先順位に従う
- **既存のパターンを尊重**: プロジェクト固有の慣習がある場合は考慮

### DON'T（非推奨）
- **過剰な最適化**: パフォーマンスに影響がない箇所での早期最適化
- **スタイルの押し付け**: プロジェクトの一貫性を壊すスタイル変更
- **破壊的変更の提案**: 後方互換性を損なう大規模な変更
- **理論のみの指摘**: 実装例のない抽象的な指摘
- **全件検出**: 重要度の低い問題まで全て報告せず、優先度でフィルタリング

## 言語別の考慮事項

このスキルは言語非依存ですが、以下の特性を考慮します:

### 動的型付け言語（JavaScript, Python, Ruby等）
- 型の曖昧さによる潜在的バグ
- ダックタイピングの適切な使用
- 実行時エラーのリスク
- **テスト**: 型安全性を補うための充実したテストスイート

### 静的型付け言語（Java, C#, TypeScript, Go等）
- 過剰な型階層
- インターフェースの乱用/不足
- ジェネリクスの適切な使用
- **テスト**: モックフレームワークの適切な使用（Mockito, NSubstituteなど）

### 関数型プログラミング（Haskell, Elixir, Scala等）
- 副作用の分離
- イミュータビリティの徹底
- 高階関数の適切な使用
- **テスト**: プロパティベーステスト（QuickCheck, Hypothesis）の活用

### テストフレームワーク別
- **xUnit系（JUnit, NUnit, pytest）**: テストクラスの適切な構造化、フィクスチャ管理
- **BDD系（Cucumber, RSpec, Jest）**: シナリオの粒度
- **モックライブラリ**: モックの過剰使用を避け、スタブで十分な場合は使い分ける

## 使用例

### 例1: プロジェクト全体の分析
```
User: このプロジェクト全体をリファクタリング分析して
Assistant:
  [スコープ確認 → Globで構造を把握]
  [4つのサブエージェントを並列実行]
    - プログラミング原則分析（sonnet）
    - コードスメル検出（haiku）
    - 品質メトリクス評価（haiku）
    - テストコード品質（sonnet）
  [結果を統合 → Markdownレポート生成]

  レポートを生成しました: refactoring-report-20260131-143000.md

  検出項目: 47件
  - 原則違反: 12件 (High: 3, Medium: 6, Low: 3)
  - コードスメル: 15件 (High: 4, Medium: 8, Low: 3)
  - メトリクス問題: 18件 (High: 5, Medium: 9, Low: 4)
  - テスト品質問題: 20件 (High: 4, Medium: 11, Low: 5)

  主要な問題:
  1. UserServiceクラスの単一責任原則違反（High）
  2. 認証ロジックの重複コード（High）
  3. processPaymentメソッドの循環的複雑度25（High）
  4. テスト間の状態共有（High）
```

### 例2: 特定ファイルの詳細分析
```
User: src/services/UserService.tsをリファクタリング分析して
Assistant:
  [ファイルを読み込み → 4つのサブエージェントを並列実行 → 結果統合]

  レポートを生成しました: refactoring-report-UserService-20260131-143500.md

  検出項目: 8件
  - 原則違反: 2件 (High: 1, Medium: 1)
  - コードスメル: 3件 (High: 1, Medium: 2)
  - メトリクス問題: 2件 (Medium: 2)
  - テスト品質問題: 1件 (Medium: 1)
```

### 例3: 特定の問題に焦点を当てた分析
```
User: 重複コードを見つけて
Assistant:
  [DRY原則とDuplicate Codeスメルに焦点を当てたサブエージェント実行]

  レポートを生成しました: refactoring-report-duplicates-20260131-144000.md

  検出項目: 8件の重複コード（High: 3, Medium: 5）
```

## 参照ドキュメント

### 基礎リファレンス
- [プログラミング原則](references/principles.md)
- [コードスメルカタログ](references/code-smells.md)
- [テストスメルカタログ](references/test-smells.md)
- [品質メトリクス](references/metrics.md)
- [出力フォーマット](references/output-format.md)

### サブエージェントテンプレート
- [プログラミング原則分析](references/subagent-templates/principles-analyzer.md)
- [コードスメル検出](references/subagent-templates/code-smell-detector.md)
- [品質メトリクス評価](references/subagent-templates/metrics-evaluator.md)
- [テストコード品質](references/subagent-templates/test-quality-reviewer.md)

## 注意事項

- **このスキルは分析と改善提案のみを行い、実際のコード修正は行いません**
- **分析結果は必ずMarkdownレポートファイルとして出力されます**
- 提案された改善案の全てが必ずしも適用されるべきではありません
- プロジェクトの状況（期限、リソース、優先度）を考慮して判断してください
- 実際にリファクタリングを実施する場合は、テストを実行して動作を確認することを強く推奨します
- レポートファイルは上書きされないようタイムスタンプ付きで保存されます
