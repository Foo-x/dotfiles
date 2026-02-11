# テストケース生成ウォークスルー例

3つの具体例を通してテストケース生成のプロセスを示す。

## 目次

1. [例1: 自販機（基本的なテストケース導出）](#例1-自販機)
2. [例2: ログインフロー（境界値テスト）](#例2-ログインフロー)
3. [例3: ECカート（並行合成の同期イベント）](#例3-ecカート)

---

## 例1: 自販機

### 仕様（状態機械）

```
状態変数: total: Int = 0
状態: {idle, waiting}

遷移:
  idle   --[coin(v)]           / total' = v       --> waiting
  waiting --[coin(v)]           / total' = total + v --> waiting
  waiting --[button_A] [total >= 150] / total' = 0  --> idle
  waiting --[cancel]            / total' = 0       --> idle
```

**機能要求:**
1. 活性: 150円以上投入してbutton_Aを押すと、商品Aを受け取れる（いつかidle に戻る）
2. 到達可能性: waiting状態に到達できる
3. 安全性: 150円未満の状態でbutton_Aは購入可能にならない

### Step 2: トレース集合の導出

代表的なトレース（`total` の値付き）:
```
ε               （idle, total=0）
⟨coin(100)⟩     （waiting, total=100）
⟨coin(200)⟩     （waiting, total=200）
⟨coin(100), coin(50)⟩  （waiting, total=150）
⟨coin(100), coin(50), button_A⟩  → idle（ガード真: total=150 >= 150）
⟨coin(200), button_A⟩   → idle（ガード真: total=200 >= 150）
⟨coin(100), cancel⟩     → idle（total=0）
⟨coin(100), coin(50), cancel⟩ → idle（total=0）
```

失敗集合（代表例）:
```
(ε, {button_A, button_B, cancel})  # idle では投入以外拒否
(⟨coin(100)⟩, {button_A})          # total=100 < 150 でbutton_A拒否
```

### Step 3: 機能要求の確認

| 性質 | 要求 | 検証トレース候補 |
|-----|------|---------------|
| 活性 | 150円以上投入→button_Aでidleに戻る | `⟨coin(200), button_A⟩` |
| 到達可能性 | waiting状態に到達可能 | `⟨coin(100)⟩` |
| 安全性 | 150円未満でbutton_A購入不可 | `⟨coin(100), button_A⟩` → 拒否 |

### テストケース一覧

#### 受理テストケース（トレース集合内）

| ID | トレース | 検証する性質 | サンプリング理由 |
|----|---------|------------|----------------|
| A-01 | `⟨coin(200), button_A⟩` | 活性: 購入完了 | ビジネスクリティカルフロー |
| A-02 | `⟨coin(100), coin(50), button_A⟩` | 活性: 複数コイン購入 | ループ繰り返し(2回) |
| A-03 | `⟨coin(150), button_A⟩` | 到達可能性 + 境界値 | 価格ちょうどで購入 |
| A-04 | `⟨coin(100)⟩` | 到達可能性: waiting | ガード偽側の到達 |
| A-05 | `⟨coin(200), cancel⟩` | 活性: キャンセル | キャンセルフロー |

#### 拒否テストケース（トレース集合外）

| ID | トレース | 検証する性質 | 拒否される理由 |
|----|---------|------------|--------------|
| R-01 | `⟨coin(100), button_A⟩` | 安全性: 価格未満で購入不可 | ガード条件違反 (total=100 < 150) |
| R-02 | `⟨button_A⟩` | 安全性: 初期状態でのボタン押下 | 失敗集合: idle でbutton_A拒否 |
| R-03 | `⟨coin(149), button_A⟩` | 安全性: 境界値直前 | ガード条件違反 (total=149 < 150) |
| R-04 | `⟨cancel⟩` | 安全性: 初期状態でのキャンセル | 失敗集合: idle でcancel拒否 |

#### カバレッジサマリ

| 指標 | 値 |
|-----|---|
| 状態カバレッジ | 2/2 状態（100%） |
| 遷移カバレッジ | 4/4 遷移（100%） |
| 活性要求カバレッジ | 1/1 要求（100%） |
| 安全性要求カバレッジ | 1/1 要求（100%） |

---

## 例2: ログインフロー

### 仕様（状態機械）

```
状態変数: attempt_count: Int = 0
状態: {input_form, checking, logged_in, locked}

遷移:
  input_form --[submit(id, pw)] / attempt_count' = attempt_count --> checking
  checking   --[τ: auth_success]                                 --> logged_in
  checking   --[τ: auth_fail] [attempt_count < 2] / attempt_count' = attempt_count + 1 --> input_form
  checking   --[τ: auth_fail] [attempt_count >= 2]               --> locked
  logged_in  --[logout]                                          --> input_form
```

**機能要求:**
1. 到達可能性: 正しいID・PWで logged_in に到達できる
2. 活性: ログイン後、いつかログアウトしてinput_formに戻れる
3. 安全性: 3回失敗するとロックされ、それ以上ログインを試みられない

### トレース集合（τ除去済み）

```
ε
⟨submit(ok, ok)⟩               → logged_in（τ: auth_success）
⟨submit(bad, bad)⟩              → input_form（attempt_count=1）
⟨submit(bad, bad), submit(bad, bad)⟩ → input_form（attempt_count=2）
⟨submit(bad, bad), submit(bad, bad), submit(bad, bad)⟩ → locked（attempt_count=2 >= 2）
⟨submit(ok, ok), logout⟩        → input_form
```

### 境界値分析: attempt_count

```
ガード: [attempt_count < 2]（失敗時に再試行可能）
      [attempt_count >= 2]（失敗時にロック）

境界値:
  attempt_count = 0: 失敗→再試行（ガード真）
  attempt_count = 1: 失敗→再試行（ガード真）
  attempt_count = 2: 失敗→ロック（ガード偽）
```

### テストケース一覧

#### 受理テストケース（トレース集合内）

| ID | トレース | 検証する性質 | サンプリング理由 |
|----|---------|------------|----------------|
| A-01 | `⟨submit(ok, ok)⟩` | 到達可能性: logged_in | ビジネスクリティカルフロー |
| A-02 | `⟨submit(ok, ok), logout⟩` | 活性: ログアウト | ログアウトフロー |
| A-03 | `⟨submit(bad, bad), submit(ok, ok)⟩` | 到達可能性: 1回失敗後ログイン | ガード真分岐 (attempt=0) |
| A-04 | `⟨submit(bad, bad), submit(bad, bad), submit(ok, ok)⟩` | 到達可能性: 2回失敗後ログイン | 境界値 (attempt=1→2, ガード真最後) |
| A-05 | `⟨submit(bad, bad), submit(bad, bad), submit(bad, bad)⟩` | 到達可能性: locked | ガード偽分岐 (attempt=2) |

#### 拒否テストケース（トレース集合外）

| ID | トレース | 検証する性質 | 拒否される理由 |
|----|---------|------------|--------------|
| R-01 | `⟨submit(bad, bad), submit(bad, bad), submit(bad, bad), submit(ok, ok)⟩` | 安全性: ロック後ログイン不可 | locked状態でsubmit拒否 |
| R-02 | `⟨logout⟩` | 安全性: 未ログインでのログアウト | input_form でlogout拒否 |
| R-03 | `⟨submit(bad, bad), submit(bad, bad), submit(bad, bad), submit(bad, bad)⟩` | 安全性: ロック後再試行不可 | locked状態でsubmit拒否 |

#### カバレッジサマリ

| 指標 | 値 |
|-----|---|
| 状態カバレッジ | 4/4 状態（100%） |
| 遷移カバレッジ | 5/5 遷移（100%） |
| 活性要求カバレッジ | 1/1 要求（100%） |
| 安全性要求カバレッジ | 1/1 要求（100%） |
| 境界値カバレッジ | attempt∈{0,1,2} 全カバー |

---

## 例3: ECカート

### 仕様（並行合成）

2つのコンポーネントを並行合成してテスト対象を構成する。

#### コンポーネントA: カート

```
状態変数: quantity: Int = 0
状態: {empty, has_item}

遷移:
  empty    --[add_item(n)]  / quantity' = n         --> has_item
  has_item --[add_item(n)]  / quantity' = quantity + n --> has_item
  has_item --[checkout]     [quantity > 0]            --> empty（購入完了）
  has_item --[remove_item]  / quantity' = 0           --> empty
```

#### コンポーネントB: 在庫

```
状態変数: stock: Int = 5
状態: {in_stock, out_of_stock}

遷移:
  in_stock     --[add_item(n)] [stock >= n] / stock' = stock - n --> in_stock
  in_stock     --[add_item(n)] [stock < n]                       --> out_of_stock（エラー状態）
  in_stock     --[checkout]    / stock' = stock                  --> in_stock
  out_of_stock --[remove_item]                                   --> in_stock（在庫は変わらず）
```

#### 並行合成 Cart ‖_{add_item, checkout, remove_item} Inventory

同期イベント: `add_item`, `checkout`, `remove_item`

合成後の代表状態遷移:
```
初期状態: (empty, in_stock, quantity=0, stock=5)

⟨add_item(3)⟩:
  Cart: empty→has_item (quantity=3)
  Inventory: in_stock→in_stock (stock=5-3=2)
  合成後: (has_item, in_stock, quantity=3, stock=2)

⟨add_item(3), checkout⟩:
  Cart: has_item→empty (quantity=0)
  Inventory: in_stock→in_stock (stock=2)
  合成後: (empty, in_stock, quantity=0, stock=2)

⟨add_item(6)⟩（stock=5 < 6）:
  Inventory: in_stock→out_of_stock（拒否、片方がブロック）
  → 合成全体として add_item(6) は拒否（Inventoryが遷移できない）
```

**機能要求:**
1. 到達可能性: 在庫がある商品をカートに追加してチェックアウトできる
2. 安全性: 在庫数を超えた数量の商品を追加できない

### テストケース一覧

#### 受理テストケース（トレース集合内）

| ID | トレース | 検証する性質 | サンプリング理由 |
|----|---------|------------|----------------|
| A-01 | `⟨add_item(1), checkout⟩` | 到達可能性: 購入完了 | ビジネスクリティカルフロー |
| A-02 | `⟨add_item(5), checkout⟩` | 到達可能性: 在庫全量購入 | 境界値 (stock=5, quantity=5) |
| A-03 | `⟨add_item(1), add_item(2), checkout⟩` | 活性: 複数追加後購入 | 並行合成の同期点（複数add_item） |
| A-04 | `⟨add_item(3), remove_item⟩` | 到達可能性: 削除→空カート | remove_itemフロー |
| A-05 | `⟨add_item(2), add_item(3), checkout⟩` | 到達可能性: 在庫境界値 (2+3=5=stock) | 境界値（在庫ちょうど） |

#### 拒否テストケース（トレース集合外）

| ID | トレース | 検証する性質 | 拒否される理由 |
|----|---------|------------|--------------|
| R-01 | `⟨add_item(6)⟩` | 安全性: 在庫超過 | Inventoryが遷移できない（並行合成のブロック） |
| R-02 | `⟨add_item(3), add_item(3)⟩` | 安全性: 追加後に在庫超過 | stock=2 < add_item(3) |
| R-03 | `⟨checkout⟩` | 安全性: 空カートでチェックアウト | Cart: empty状態でcheckout拒否 |
| R-04 | `⟨add_item(5), add_item(1)⟩` | 安全性: 在庫完売後の追加 | stock=0 < add_item(1) |

#### カバレッジサマリ

| 指標 | 値 |
|-----|---|
| Cart状態カバレッジ | 2/2 状態（100%） |
| Inventory状態カバレッジ | 2/2 状態（100%） |
| 同期イベントカバレッジ | 3/3（add_item, checkout, remove_item） |
| 到達可能性要求カバレッジ | 1/1 要求（100%） |
| 安全性要求カバレッジ | 1/1 要求（100%） |
| 境界値カバレッジ | stock境界(n=stock, n=stock+1)カバー |
