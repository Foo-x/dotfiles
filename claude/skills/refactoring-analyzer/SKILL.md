---
name: refactoring-analyzer
description: |
  プロジェクトのコードを分析し、リファクタリングが必要な箇所を特定して改善提案を行うスキル。
  以下の場合に使用する:
  - 「リファクタリングして」「コード品質を改善して」と依頼された時
  - コードレビューでリファクタリング候補を洗い出したい時
  - 技術的負債を可視化したい時
  - プロジェクト全体または特定ファイルのコード品質を評価したい時
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

### 3. 多角的分析
以下の観点から分析を実施:

#### 3.1 プログラミング原則の遵守
[references/principles.md](references/principles.md)を参照し、以下を評価:
- **SOLID原則**: 単一責任、オープン・クローズド、リスコフの置換、インターフェース分離、依存性逆転
- **DRY原則**: 重複コードの検出
- **KISS原則**: 不要な複雑性の特定
- **YAGNI原則**: 過剰設計の検出
- **関心の分離**: 責任の混在
- **デメテルの法則**: 不適切な依存関係
- **Composition over Inheritance**: 継承の乱用
- **純粋関数**: 副作用のない、参照透過な関数の推進
- **パッケージ設計原則**:
  - **パッケージ凝集度**: REP（再利用・リリース等価）、CRP（共通再利用）、CCP（共通閉鎖）
  - **パッケージ結合度**: ADP（非循環依存）、SDP（安定依存）、SAP（安定抽象化）

#### 3.2 コードスメルの検出
[references/code-smells.md](references/code-smells.md)を参照し、以下のカテゴリを検出:

**Bloaters（肥大化）**:
- Long Method（長すぎるメソッド）
- Large Class（大きすぎるクラス）
- Long Parameter List（長すぎる引数リスト）
- Primitive Obsession（プリミティブ型への執着）
- Data Clumps（データの群れ）

**Object-Orientation Abusers（オブジェクト指向の濫用）**:
- Switch Statements（switch文の乱用）
- Temporary Field（一時的なフィールド）
- Refused Bequest（親クラスの拒絶）
- Alternative Classes with Different Interfaces（異なるインターフェースを持つ代替クラス）

**Change Preventers（変更の妨害者）**:
- Divergent Change（発散的変更）
- Shotgun Surgery（散弾銃手術）
- Parallel Inheritance Hierarchies（並行継承階層）

**Dispensables（不要なもの）**:
- Dead Code（デッドコード）
- Speculative Generality（投機的一般化）
- Duplicate Code（重複コード）
- Lazy Class（怠惰なクラス）
- Comments（過剰なコメント）

**Couplers（結合の問題）**:
- Feature Envy（機能への羨望）
- Inappropriate Intimacy（不適切な関係）
- Message Chains（メッセージチェーン）
- Middle Man（仲介者）

#### 3.3 品質メトリクス評価
[references/metrics.md](references/metrics.md)を参照し、以下を測定:
- **結合度（Coupling）**: モジュール間の依存度
- **コナーセンス（Connascence）**: モジュール間の依存関係の種類と強度（静的/動的）
- **凝集度（Cohesion）**: モジュール内の関連性
- **循環的複雑度（Cyclomatic Complexity）**: 制御フローの複雑さ
- **認知的複雑度（Cognitive Complexity）**: 理解の困難さ
- **ネストの深さ**: 条件分岐・ループのネスト
- **ファイルサイズ**: 行数、文字数
- **関数/メソッドの長さ**: LOC（Lines of Code）

#### 3.4 テストコード品質
[references/test-smells.md](references/test-smells.md)と[references/principles.md](references/principles.md)のテスト原則を参照し、以下を評価:

**Test Bloaters（テストの肥大化）**:
- Eager Test（過度に詳細なテスト）
- Obscure Test（不明瞭なテスト）
- Long Test（長すぎるテスト）

**Test Logic Smells（テストロジックの問題）**:
- Conditional Test Logic（条件付きテストロジック）
- Assertion Roulette（アサーションルーレット）
- Sensitive Equality（敏感な等価性）

**Test Isolation Smells（テスト分離の問題）**:
- Shared State（共有状態）
- Test Run War（テスト実行戦争）
- Resource Optimism（リソース楽観主義）

**Test Maintainability Smells（テスト保守性の問題）**:
- Test Code Duplication（テストコードの重複）
- Hard-Coded Test Data（ハードコードされたテストデータ）
- Mystery Guest（謎のゲスト）

**Test Double Smells（テストダブルの問題）**:
- Mock Overuse（モックの過剰使用）
- Leaky Mock（漏れやすいモック）

**テスト品質原則**:
- **FIRST原則**: Fast, Isolated, Repeatable, Self-Validating, Timely
- **AAA/Given-When-Then**: テスト構造の明確性
- **テストピラミッド**: 単体/統合/E2Eテストのバランス（バックエンド向け）
- **テスティングトロフィー**: 統合テスト重視のバランス（フロントエンド向け）

### 4. Markdownレポートの生成と出力

分析完了後、必ず以下の手順でMarkdownレポートファイルを生成します:

#### 4.1 レポートファイルの作成
[references/output-format.md](references/output-format.md)の形式に従ってMarkdownレポートを作成:

- 優先度の割り当て（Critical / High / Medium / Low）
- 問題の明確な説明
- 現在のコード例
- 改善後のコード例
- 改善の効果

#### 4.2 ファイル出力
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
3. 検出項目サマリー
4. 詳細（各問題の詳細説明）
5. 推奨実装順序

**オプションセクション**:
- メトリクスサマリー（複雑度分布、ファイルサイズ分布等）
- 付録（用語集、参考リンク等）

#### 4.3 出力の確認
レポート生成後、ユーザーに以下を伝えます:
- 生成されたファイルのパス
- 検出項目数の概要
- 優先度別の内訳

## 優先度の判断基準

### Critical（緊急）
- セキュリティ脆弱性
- データ破損リスク
- 循環依存
- メモリリーク
- テストの完全な欠如（重要機能）

### High（高）
- SOLID原則の重大な違反
- 大規模な重複コード
- 極端に高い複雑度（CC > 15）
- 大きすぎるクラス/メソッド（500行以上）
- Test Run War（並列実行で競合するテスト）
- Shared State（テスト間の状態共有）

### Medium（中）
- 命名の問題
- 中程度の複雑度（CC 10-15）
- データクランプ
- ネストの深さ（4階層以上）
- Switch文の乱用
- Eager Test（複数の関心事を検証）
- Obscure Test（意図が不明瞭）
- Test Code Duplication（テストコードの重複）
- FIRST原則の違反（遅い、非独立、非再現）

### Low（低）
- コメント不足
- マジックナンバー
- 一貫性のないフォーマット
- 軽微な最適化機会
- Hard-Coded Test Data（ハードコードされたテストデータ）
- Assertion Roulette（説明のないアサーション）

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
- **BDD系（Cucumber, RSpec, Jest）**: Given-When-Thenの明確性、シナリオの粒度
- **モックライブラリ**: モックの過剰使用を避け、スタブで十分な場合は使い分ける

## 使用例

### 例1: プロジェクト全体の分析
```
User: このプロジェクト全体をリファクタリング分析して
Assistant:
  [Globで構造を把握 → 主要ファイルをRead → 分析 → Markdownレポート生成]

  レポートを生成しました: refactoring-report-20260131-143000.md

  検出項目: 12件 (Critical: 0, High: 3, Medium: 6, Low: 3)
  主要な問題:
  1. UserServiceクラスの単一責任原則違反
  2. 認証ロジックの重複コード
  3. 複数の高複雑度メソッド
```

### 例2: 特定ファイルの詳細分析
```
User: src/services/UserService.tsをリファクタリング分析して
Assistant:
  [ファイルを読み込み → 詳細分析 → Markdownレポート生成]

  レポートを生成しました: refactoring-report-UserService-20260131-143500.md

  検出項目: 5件 (High: 2, Medium: 2, Low: 1)
```

### 例3: 特定の問題に焦点を当てた分析
```
User: 重複コードを見つけて
Assistant:
  [DRY原則とDuplicate Codeスメルに焦点 → 検出 → Markdownレポート生成]

  レポートを生成しました: refactoring-report-duplicates-20260131-144000.md

  検出項目: 8件の重複コード（High: 3, Medium: 5）
```

## 参照ドキュメント

- [プログラミング原則](references/principles.md) - SOLID, DRY, KISS等の詳細解説、テスト品質原則（FIRST、AAA/Given-When-Then、テストピラミッド、テスティングトロフィー）
- [コードスメルカタログ](references/code-smells.md) - 検出可能なコードスメルの一覧
- [テストスメルカタログ](references/test-smells.md) - テストコード特有のスメル（Test Bloaters, Test Logic, Test Isolation, Test Double等）
- [品質メトリクス](references/metrics.md) - 測定可能な品質指標
- [出力フォーマット](references/output-format.md) - レポートのテンプレートと優先度定義

## 注意事項

- **このスキルは分析と改善提案のみを行い、実際のコード修正は行いません**
- **分析結果は必ずMarkdownレポートファイルとして出力されます**
- 提案された改善案の全てが必ずしも適用されるべきではありません
- プロジェクトの状況（期限、リソース、優先度）を考慮して判断してください
- 実際にリファクタリングを実施する場合は、テストを実行して動作を確認することを強く推奨します
- レポートファイルは上書きされないようタイムスタンプ付きで保存されます
