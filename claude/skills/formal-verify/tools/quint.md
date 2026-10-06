# Quint 検証手順

与えた仕様を Quint でモデル化し、問題がないか検証する。

quintコマンドが存在しないとき、nixが使える場合は nix shell コマンド、使えない場合は https://github.com/quint-co/quint/releases から環境に応じたバイナリをインストールする。

- 状態・定数・アクション・状態遷移の抽出とモデル化
    - 各要素がどの仕様と対応するか明記する
    - カレントディレクトリにqntファイルを出力する
        - Quint を知らないユーザーでもわかるようにすべての式・文を1行ずつコメントで説明する
- `quint typecheck` の後、モード別設定に従って検証する
    - quick では `quint verify` は行わない。網羅的でないことと、網羅的な検証を行うには `quint verify` の実行が必要なことを明記する
    - 検証した範囲（max-steps、max-samples 等）を明記する
- 充足可能性・不変条件・安全性・活性・デッドロック・到達性の検証

## モード別設定

- quick
    - `timeout 120 quint run` で `--max-steps=20 --max-samples=1000` 程度から始める
    - 不変条件ごとに `--invariant` を指定する
- thorough
    - `quint run` を `--max-steps=50 --max-samples=10000` 以上で実行する
    - `quint verify`（Apalache）で不変条件を網羅的に検証する。バックグラウンドで実行し完了を待つ
        - `quint verify` はJavaがなくても実行可能
    - 時相性質は `--temporal` で検証する
    - `quint verify` の範囲（`--max-steps`）を明記する
