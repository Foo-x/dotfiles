# コードスメルカタログ

コードの問題を示す兆候（コードスメル）を体系的に分類したカタログです。

## Bloaters（肥大化）

### Long Method（長すぎるメソッド）
**定義**: メソッドやファンクションが長すぎる。
**検出基準**: 50行以上、スクロール必要、複数の責任
**リファクタリング手法**: Extract Method、Replace Temp with Query、Introduce Parameter Object

### Large Class（大きすぎるクラス）
**定義**: 1つのクラスが多すぎる責任を持つ。
**検出基準**: 500行以上、20個以上のフィールド、30個以上のメソッド
**リファクタリング手法**: Extract Class、Extract Subclass、Extract Interface

### Long Parameter List（長すぎる引数リスト）
**定義**: メソッドの引数が多すぎる。
**検出基準**: 4個以上の引数、同じ型の引数が連続
**リファクタリング手法**: Introduce Parameter Object、Preserve Whole Object

### Primitive Obsession（プリミティブ型への執着）
**定義**: ドメイン概念を表現するのにプリミティブ型を使用。
**検出基準**: 電話番号・郵便番号が単なるstring、金額が単なるnumber
**リファクタリング手法**: Replace Data Value with Object、Introduce Value Object

### Data Clumps（データの群れ）
**定義**: 常に一緒に現れるデータのグループ。
**検出基準**: 同じ引数セットの繰り返し、同じフィールドセットの繰り返し、3つ以上のデータが常にセット
**リファクタリング手法**: Extract Class、Introduce Parameter Object

---

## Object-Orientation Abusers（オブジェクト指向の濫用）

### Switch Statements（switch文の乱用）
**定義**: 型コードに基づく複雑なswitch文やif-else連鎖。
**検出基準**: 同じ型チェックが複数箇所、switch文が3箇所以上で繰り返し
**リファクタリング手法**: Replace Conditional with Polymorphism、Replace Type Code with State/Strategy

### Temporary Field（一時的なフィールド）
**定義**: 特定の状況でのみ値が設定されるフィールド。
**検出基準**: nullや空値が多い、特定メソッド実行時のみ使用
**リファクタリング手法**: Extract Class、Replace Method with Method Object

### Refused Bequest（親クラスの拒絶）
**定義**: サブクラスが親クラスのメソッドの一部しか使用しない。
**検出基準**: 親メソッドをオーバーライドして例外スロー、継承が「is-a」でなく「has-a」
**リファクタリング手法**: Replace Inheritance with Delegation、Extract Subclass

---

## Change Preventers（変更の妨害者）

### Divergent Change（発散的変更）
**定義**: 1つのクラスが異なる理由で頻繁に変更される。
**検出基準**: 複数の異なる理由で変更、異なるチームが同じクラスを修正
**リファクタリング手法**: Extract Class、Extract Module
**影響**: 単一責任原則違反、マージコンフリクト増加

### Shotgun Surgery（散弾銃手術）
**定義**: 1つの変更が複数のクラスに影響する。
**検出基準**: 1つの機能追加で10個以上のファイル修正、関連コードが分散
**リファクタリング手法**: Move Method、Move Field、Inline Class
**影響**: 変更漏れリスク、保守コスト増大

---

## Dispensables（不要なもの）

### Dead Code（デッドコード）
**定義**: 使用されていないコード。
**検出基準**: 呼び出されていないメソッド、参照されていない変数、到達不可能なブロック
**リファクタリング手法**: 削除

### Duplicate Code（重複コード）
**定義**: 同じまたは類似したコードが複数箇所に存在。
**検出基準**: 同一コードブロックが2箇所以上、コピー&ペーストの痕跡
**リファクタリング手法**: Extract Method、Pull Up Method、Form Template Method

### Speculative Generality（投機的一般化）
**定義**: 将来必要になるかもという理由だけで作られた抽象化。
**検出基準**: 使用されていない抽象化、単一実装のインターフェース
**リファクタリング手法**: Collapse Hierarchy、Inline Class、Remove Parameter

---

## Couplers（結合の問題）

### Feature Envy（機能への羨望）
**定義**: メソッドが自分のクラスより他クラスのデータに興味を持つ。
**検出基準**: 他クラスのgetterを多用、他クラスのメソッドを頻繁に呼び出し
**リファクタリング手法**: Move Method、Extract Method

### Inappropriate Intimacy（不適切な関係）
**定義**: 2つのクラスが互いの内部実装に深く依存。
**検出基準**: 双方向依存、protectedメンバーへの頻繁なアクセス
**リファクタリング手法**: Move Method/Field、Extract Class、Change Bidirectional Association to Unidirectional

### Message Chains（メッセージチェーン）
**定義**: 長い呼び出しチェーン（Law of Demeter違反）。
**検出基準**: `a.b().c().d()`のような連鎖、3つ以上の「.」が連続
**リファクタリング手法**: Hide Delegate、Extract Method

### Middle Man（仲介者）
**定義**: クラスが単に他クラスへの委譲しかしていない。
**検出基準**: メソッドの大部分が委譲のみ、独自ロジックがほとんどない
**リファクタリング手法**: Remove Middle Man、Inline Method
