# Alloy 6 チートシート

## 構造
```alloy
open util/ordering[Time]        // 必要な場合のみ
abstract sig Person {}
sig Member extends Person { borrowed: set Book }   // set / one / lone / some
sig Book { var holder: lone Member }               // var = 時間で変化
enum Status { Active, Suspended }
one sig Config { limit: Int }                      // シングルトン
```
- 多重度: `one`(1) / `lone`(0..1) / `some`(1..) / `set`(0..)。フィールド既定は `one`
- `var` を付けた sig / field は時間で変化する。付けないものは不変
- `Int` は bitwidth 依存(既定4bit=-8..7)。オーバーフローに注意し、`for 5 Int` 等で明示する

## 式
| 記法 | 意味 |
|---|---|
| `a.b` | 結合 |
| `a in b` / `a = b` | 部分集合 / 等価 |
| `#s` | 要素数 |
| `no s` / `some s` / `one s` / `lone s` | 空 / 非空 / ちょうど1 / 高々1 |
| `all x: S \| P` / `some x: S \| P` / `no x: S \| P` | 量化 |
| `~r` / `^r` / `*r` | 転置 / 推移閉包 / 反射推移閉包 |
| `a <: r` / `r :> b` | 定義域 / 値域の制限 |
| `r ++ s` | オーバーライド |
| `implies … else …` / `iff` / `and` / `or` / `not` | 論理 |

## 時相論理 (Alloy 6)
| 記法 | 意味 |
|---|---|
| `always P` | 全時点で P |
| `eventually P` | いつか P |
| `after P` | 次の時点で P |
| `P until Q` / `P releases Q` | until / release |
| `historically P` / `once P` / `before P` | 過去方向 |
| `x'` | 次時点での x (var のみ) |
| `P ; Q`(例: `after`) | 使う場合は括弧で優先順位を明示 |

- トレースは無限(ループ付き)。`fact` の中の時相式は初期時点から評価される
- `run/check … for 3 but 1..10 steps` で状態数の範囲を指定できる(既定 `1..10`)

## 状態機械の骨格
```alloy
var sig Open in Door {}              // var sig: 集合自体が変化する

pred init { no Open }
pred openDoor[d: Door] {
  d not in Open                      // 事前条件
  Open' = Open + d                   // 事後条件
  // フレーム条件: 変えないものを明示しないと勝手に変化する
  other' = other
}
pred stutter { Open' = Open }        // 何も起きない遷移

fact Traces {
  init
  always (stutter or (some d: Door | openDoor[d] or closeDoor[d]))
}
```

## コマンド
```alloy
run  name { P } for 4 but 5 Int, exactly 3 Door, 1..12 steps
check Name for 4 but 1..12 steps       // assert Name { … } を検証
```
- `run`: SAT = 充足可能(例が見つかった)/ UNSAT = 充足不能
- `check`: SAT = **反例あり**(性質が破れる)/ UNSAT = scope 内で反例なし(証明ではない)
- `expect 0|1` を付けると期待と結果の食い違いを検出できる: `check Safe for 4 expect 0`

## 命名・構文の落とし穴
- 予約語: `set, one, lone, some, no, all, sum, disj, this, univ, none, iden, Int, seq, let, fun, pred, fact, assert, run, check, open, module, exactly, but, for, and, or, not, implies, iff, else, in, always, eventually, after, before, until, releases, since, triggered, historically, once, var, enum, steps`
- `open` は予約語(module import)。操作名に使うと構文エラーになるため `openDoor` のように具体名にする
- `fact` は無名でよいが、名前を付けるとレポートで参照しやすい
- 文字列は `String`(リテラル可)だが推論力が弱い。列挙は `enum` を使う
- 日付/時刻など順序は `util/ordering` か `Int` で近似する
- コメント: `--` `//` `/* */`
