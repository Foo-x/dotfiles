# 形式仕様/証明言語の早見表

形式言語は「通ったように見えるが実は何も証明/検証していない」状態が起きやすい。`check.sh` で必ず抜け道を検出する。

| 言語 | 処理系 | 採点コマンド | 合格条件 | 抜け道の検出 |
|------|--------|--------------|----------|--------------|
| Alloy | `alloy` / `alloy6`（`type` で確認） | `run`/`check` を CLI で実行 | `check` は反例なし、`run` はインスタンスあり（問題ごとに期待値を決める） | `fact` で矛盾を作り `check` を空虚に通す解答を防ぐため、同じモデルに `run {}` を置き sat を確認 |
| Quint | `quint` | `quint typecheck` → `quint test` / `quint run --invariant=<inv> --max-steps=N` | 型検査・テスト通過、不変条件違反なし | `quint run` は網羅的でないため問題文に明記。初期状態/各アクションが実行可能かも別途確認 |
| Lean | `lake` / `lean` | `lake build`（単一ファイルは `lean <file>`） | エラーなし・`sorry` 警告なし | `#print axioms <定理名>` に `sorryAx` がない。許可する公理（`propext` 等）は問題ごとに決める |
| Dafny | `dafny` | `dafny verify <file>` | エラー・警告なし | `assume`・`{:axiom}`・`{:verify false}`・`{:extern}`・本体のない function/method を grep で検出。`ensures` を弱めていないか、問題側の仕様ファイルと解答を分けて検証 |
| Bend 2 | `bend`（公式 `curl -fsSL https://bend-lang.com/install.sh \| sh`。https://github.com/bendlang/bend） | `bend <file>.bend`（定理証明の検証） | エラーなし | `@unsafe`（安全チェック無効化）と `def f?(..)`（終了検証の無効化）を grep で検出 |

Bend 2 は依存型による証明を持つ関数型言語で、`LAWS.bend`（法則: `law add_zero: for x: Nat {Nat.add(x, 0n) == x : Nat}`）と `PROOF.bend`（証明の実装）に分けて書く。コマンドと構文は README 由来で、バージョンによって変わりうる。一次資料の取得時に `bend guide` で現行の書き方を確認する。

## 出題の作り方

学習者が編集してよい範囲を限定する。仕様（定理文・`ensures`・`check` の対象・不変条件）は問題側で固定し、学習者は実装/証明だけを書く。仕様を書き換えれば何でも通ってしまうため。

- **Alloy**: 学習者は `sig`/`fact`/`pred` を書く。`check`・`run` コマンドは `check.sh` が別ファイルから結合して実行する
- **Quint**: 学習者はアクションと状態更新を書く。不変条件は問題側のファイルに置く
- **Lean**: 学習者は証明（タクティク）を書く。定理文は雛形に固定し、`check.sh` が文の改変を検出する（`#check` で型を比較する等）
- **Dafny**: 学習者は本体・ループ不変条件・補題を書く。`requires`/`ensures` は変更不可とする
- **Bend 2**: 学習者は `PROOF.bend` の証明（`match` による場合分けと再帰呼び出し）を書く。`LAWS.bend` は問題側で固定し、変更不可とする

## 種別ごとの具体例

- **バグ修正**: Alloy は過剰制約（`run` が unsat）と過少制約（`check` に反例）。Quint は不変条件を破るアクション。Lean/Dafny は帰納法の仮定やループ不変条件の不足
- **リファクタリング**: 冗長な証明・仕様の書き直し。旧定義との同値性を Alloy は `check`、Lean は定理（`old = new`）、Quint は同一の不変条件通過で保証する

## 注意

- 反例や証明エラーは英語のまま出る。README に読み方のヒントを1-2行添える
- Lean の Mathlib 依存は重い。基本は標準ライブラリ＋`omega`/`simp`/`induction` で解ける範囲にする
