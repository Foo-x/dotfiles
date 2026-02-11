# 仕様記述記法ガイド

CSP安定失敗モデルに基づく状態機械仕様の記述規約。

---

## 1. 状態変数の記述規約

状態変数はシステムの「記憶」を表す。

### 形式

```
変数名 : 型 = 初期値  -- 値域コメント
```

### 例

```
balance    : Nat  = 0        -- 投入済み金額（円）
products   : Map<ProductId, Nat>  = {A: 3, B: 5}  -- 在庫数
purchasable : Option<ProductId>   = None          -- 購入可能な製品
dispensing  : Bool = false                        -- 排出中フラグ
```

### 規約

- **名前**: スネークケース、意味が明確な名詞
- **型**: `Nat`（自然数）、`Bool`、`Int`、`String`、`Option<T>`、`Set<T>`、`Map<K,V>`
- **初期値**: システム起動時の値を必ず明記
- **値域**: 型だけでは不明な制約をコメントで記述（例: `0 <= balance <= 10000`）

---

## 2. 遷移記法の詳細

### 基本形式

```
イベント名 [ガード条件] / 事後条件
```

### 各要素の詳細

#### イベント

- **UIイベント**: ユーザー操作（例: `press_button(id: ProductId)`）
- **通信イベント**: 外部システムとの通信（例: `payment_confirmed(amount: Nat)`）
- **内部イベント τ**: 外から観測不可（例: 自動タイムアウト、バックグラウンド処理）

#### ガード条件

遷移が発生できるための**事前条件**。

```
[ガード条件の例]
[balance >= price(id)]             -- 残高が価格以上
[products[id] > 0]                 -- 在庫あり
[purchasable = Some(id)]           -- 指定製品が購入可能状態
[dispensing = false]               -- 排出中でない
```

- ガードが常に `true` の場合は省略可
- 複数条件は `∧`（AND）または `∨`（OR）で結合
- 否定は `¬` または `not`

#### 事後条件（プライム記法）

遷移後の状態変数を **`変数名'`**（プライム）で表す。

```
[事後条件の例]
balance' = balance + amount        -- balance を amount だけ増加
dispensing' = true                 -- dispensing を true に更新
products' = products[id ↦ products[id] - 1]  -- 在庫を1減らす
```

**フレーム条件**: 事後条件に言及されていない変数は変化しない（暗黙の不変条件）。

#### 複数変数の同時更新

```
insert_coin(amount: Nat) [amount > 0] /
  balance' = balance + amount
  -- dispensing, products, purchasable は変化なし（フレーム条件）
```

複数変数を更新する場合は改行して列挙：

```
press_button(id: ProductId)
  [balance >= price(id) ∧ products[id] > 0] /
  purchasable' = Some(id)
  dispensing'  = true
```

---

## 3. 状態遷移表のフォーマット

複雑な状態機械では遷移表で整理すると見通しが良い。

### 形式

| 状態 / イベント | `event_a` | `event_b` | `event_c` |
|----------------|-----------|-----------|-----------|
| **状態1**       | `[guard] / postcond` | ✗ | `/ postcond` |
| **状態2**       | ✗ | `[guard] / postcond` | ✗ |

- **✗**: その状態でそのイベントは拒否（失敗集合に含まれる）
- **状態**欄: 状態変数の代表的な値の組み合わせで表現

### 例（自販機の簡略版）

| 状態 | `insert_coin` | `press_button` | `take_product` |
|------|--------------|----------------|----------------|
| **待機中** (`dispensing=false, balance=0`) | `/ balance'=amount` | ✗ | ✗ |
| **選択可能** (`dispensing=false, balance>=price`) | `/ balance'+=amount` | `/ dispensing'=true` | ✗ |
| **排出中** (`dispensing=true`) | ✗ | ✗ | `/ dispensing'=false` |

---

## 4. 画面表示関数のフォーマット（画面表示を持つシステムのみ）

画面表示のないソフトウェア（バックエンドサービス、バッチ処理、ライブラリ等）にはこのセクションは不要。

画面表示は状態変数から表示内容へのマッピング関数として定義する。

```
screen(state) =
  case dispensing = true  => 排出中画面(purchasable)
  case balance > 0        => 選択画面(balance, 購入可能製品一覧)
  default                 => 待機画面
```

### 規約

- **純粋関数**: 状態変数のみを入力とし、副作用なし
- **網羅性**: すべての状態で何らかの画面が定義されていること
- **パラメータ**: 表示する状態変数を明示的に渡す

---

## 5. API設計書の記法（Design by Contract）

コンポーネント間の同期イベントは「シグネチャ + 事前条件 + 事後条件」で定義する。

### 形式

```
operation_name(params) -> ReturnType
  requires: 事前条件（満たされない場合は何をしてもよい）
  ensures:  事後条件（リクエストとレスポンスの関係）
```

### 例

```
dispense(product_id: ProductId) -> DispensingResult
  requires:
    - products[product_id] > 0     -- 在庫あり
    - balance >= price(product_id) -- 残高が価格以上
  ensures:
    - result.success = true
    - products'[product_id] = products[product_id] - 1
    - balance' = balance - price(product_id)
```

### 事前条件の意味

- 事前条件を満たさない場合の動作は**未定義**（クラッシュも許容）
- 呼び出し側（クライアント）が事前条件を満たす責任を持つ

---

## 6. 並行合成の記法

複数コンポーネントを同期イベントで接続して1つの大きな仕様を作る。

### 形式

```
合成後の仕様 = ComponentA [| SyncEvents |] ComponentB

SyncEvents = { イベント名1, イベント名2, ... }
```

### 例

```
VendingMachineSpec = UI [| {press_button, take_product} |] Inventory

UI コンポーネント:
  状態変数: balance, purchasable, dispensing
  イベント: insert_coin（非同期）, press_button（同期）, take_product（同期）

Inventory コンポーネント:
  状態変数: products
  イベント: press_button（同期）, take_product（同期）
```

### 並行合成のルール

| ケース | 動作 |
|--------|------|
| 両コンポーネントが同期イベントで遷移可能 | 同時に遷移（くっつける） |
| 片方が同期イベントで遷移不可 | 合成後も遷移不可（拒否） |
| 非同期イベント | 片方だけで遷移可能 |
| τ | 同期イベントにできない（内部イベントのまま） |

---

## 付録: 記法クイックリファレンス

| 記号 | 意味 |
|------|------|
| `x'` | 遷移後の変数 x |
| `[cond]` | ガード条件 |
| `/` | 事後条件の区切り |
| `τ` | 内部イベント |
| `[| S |]` | 同期イベント集合 S での並行合成 |
| `∧` | AND |
| `∨` | OR |
| `¬` | NOT |
| `⊆` | 部分集合 |
| `↦` | マップの更新（`map[key ↦ value]`） |
