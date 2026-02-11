# 自販機仕様書 — 完成例

`spec` スキルが生成する仕様書のパターン例。

---

## 1. 機能要求（入力）

| # | 要求 | 性質 |
|---|------|------|
| R1 | 製品Aの価格より多く貨幣を投入し、ボタンを押すと、いつか製品Aを受け取れる | 活性 |
| R2 | 製品Aの価格以上の貨幣を投入した後、ボタンを押せる状態に到達できる | 到達可能性 |
| R3 | 投入貨幣の総額より価格の高い製品は購入可能にならない | 安全性 |

---

## 2. 状態変数定義

| 変数名 | 型 | 初期値 | 説明 |
|--------|-----|--------|------|
| `balance` | `Nat` | `0` | 投入済み金額（円）。0以上。 |
| `products` | `Map<ProductId, Nat>` | `{A: 3, B: 5, ...}` | 製品ごとの在庫数 |
| `purchasable` | `Option<ProductId>` | `None` | 現在購入可能な製品（1つまたはなし） |
| `dispensing` | `Bool` | `false` | 排出中フラグ |

---

## 3. イベント定義

| イベント | 引数 | 種別 | 説明 |
|---------|------|------|------|
| `insert_coin` | `amount: Nat` | 外部（ユーザー） | 貨幣を投入する |
| `press_button` | `id: ProductId` | 外部（ユーザー） | 製品ボタンを押す |
| `dispense` | — | 内部（τ） | 排出機構が動作する（外部から観測不可） |
| `take_product` | — | 外部（ユーザー） | 製品を取り出す |
| `return_change` | — | 外部（ユーザー） | 釣り銭返却ボタンを押す |

---

## 4. 遷移定義

### insert_coin

```
insert_coin(amount: Nat)
  [amount > 0 ∧ dispensing = false] /
  balance' = balance + amount
```

### press_button

```
press_button(id: ProductId)
  [balance >= price(id) ∧ products[id] > 0 ∧ dispensing = false] /
  purchasable' = Some(id)
  dispensing'  = true
```

### dispense（τ — 内部イベント）

```
τ: dispense
  [dispensing = true ∧ purchasable = Some(id)] /
  products'  = products[id ↦ products[id] - 1]
  balance'   = balance - price(id)
  -- dispensing はまだ true のまま（take_product 待ち）
```

### take_product

```
take_product
  [dispensing = true] /
  dispensing'  = false
  purchasable' = None
```

### return_change

```
return_change
  [dispensing = false ∧ balance > 0] /
  balance' = 0
```

---

## 5. 画面表示定義

```
screen(state) =
  case dispensing = true =>
    排出中画面 {
      製品名: purchasable,
      メッセージ: "製品をお取りください"
    }
  case balance > 0 =>
    選択画面 {
      残高表示: balance,
      購入可能製品一覧: { id | balance >= price(id) ∧ products[id] > 0 },
      在庫切れ製品一覧: { id | products[id] = 0 }
    }
  default =>
    待機画面 {
      メッセージ: "貨幣を投入してください",
      製品一覧: products
    }
```

---

## 6. 失敗分析

各安定状態で**拒否されるイベント**の一覧（失敗集合の導出）。

| 安定状態 | 拒否されるイベント | 理由 |
|---------|-----------------|------|
| `balance=0, dispensing=false` | `press_button(*)`, `take_product`, `return_change` | 残高なし・排出中でない |
| `0 < balance < min_price, dispensing=false` | `press_button(*)`, `take_product` | 残高不足で購入不可 |
| `balance >= price(id), dispensing=false` | `take_product` | 排出中でない |
| `dispensing=true` | `insert_coin(*)`, `press_button(*)`, `return_change` | 排出中は操作不可 |

> **デッドロック検出**: すべての安定状態で何らかのイベントが受理されていることを確認する。
> - `dispensing=true` の状態では必ず `take_product` が受理される → デッドロックなし ✓

---

## 7. 機能要求との対応確認

| 要求 | 充足確認 |
|------|---------|
| **R1（活性）**: 価格以上投入+ボタン押下 → いつか製品受け取れる | `press_button` → `τ:dispense` → `take_product` の経路が存在する。`dispense` は τ（弱公平性を仮定）なのでいつか実行される ✓ |
| **R2（到達可能性）**: 価格以上投入後、ボタンを押せる状態に到達できる | `insert_coin(price(A))` 後に `press_button(A)` のガード `balance >= price(A)` が満たされる状態が存在する ✓ |
| **R3（安全性）**: 残高不足の製品は購入可能にならない | `press_button` のガード `balance >= price(id)` により、残高不足時は拒否される ✓ |
