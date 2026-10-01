---
name: dafny-implement
description: >
  仕様を Dafny で実装し、dafny verify で仕様どおりであることを機械的に証明する。
disable-model-invocation: true
---

与えた仕様を Dafny で実装し、`dafny verify` が通るようにしてください。

dafnyコマンドが存在しないとき、nixが使える場合は nix shell コマンド、使えない場合は https://dafny.org/latest/Installation の手順で環境に応じたバイナリをインストールしてください。

- 仕様の形式化
    - 曖昧な記述や未定義の境界条件（空入力、オーバーフロー、重複等）があるときは実装前に指摘し、ユーザーに確認する
    - 各契約がどの仕様と対応するか明記する
- 実装
    - 仕様（function / predicate による参照定義）と実装（method）を分け、ensures で両者の一致を証明する
    - カレントディレクトリにdfyファイルを出力する
        - Dafny を知らないユーザーでもわかるように1行ずつコメントで説明する
- 検証
    - `dafny verify <file>` がエラー・警告なしで通るまで修正する
    - 失敗時はループ不変条件・decreases・補題（lemma）・assert の追加などで証明を補う
    - ensures を弱める、`assume`・`{:axiom}`・`{:verify false}`・`{:extern}`・本体のない function/method で証明を回避しない
        - 仕様どおりに証明できない場合は、仕様の欠陥か実装・証明の不足かを切り分けて報告する
    - 実行したコマンドと結果（verified 数・エラー数）を明記する
- Dafny で表現できなかった/近似した部分（非決定性、I/O、並行性、浮動小数点等）の明示
- 仕様修正案の提示（修正自体は行わない）
