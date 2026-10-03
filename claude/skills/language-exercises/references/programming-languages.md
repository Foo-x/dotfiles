# 汎用言語の早見表

テストは追加依存の少ない標準ツールを使う。`check.sh NN` は下表の「1問の採点」を `exercises/NN-*` に対して実行する。

| 言語 | 処理系 | 初期化 | 1問の採点 | 未実装マーカー |
|------|--------|--------|-----------|----------------|
| Python | `python3` | 不要 | `python3 -m unittest discover -s exercises/NN-*` | `raise NotImplementedError` |
| TypeScript | `node`（22+） | 不要（`--experimental-strip-types`） | `node --test exercises/NN-*/` | `throw new Error("TODO")` |
| Go | `go` | `go mod init exercises` | `go test ./exercises/NN-*/` | `panic("TODO")` |
| Rust | `cargo` | `cargo new --lib`（問題ごとに crate） | `cargo test --manifest-path exercises/NN-*/Cargo.toml` | `todo!()` |
| Haskell | `ghc`/`cabal` | `cabal init` | `cabal test` または `runghc exercises/NN-*/Test.hs` | `error "TODO"` |
| Java | `java`（21+） | 不要 | `java exercises/NN-*/Test.java`（単一ファイル実行。`assert` 代わりに例外を投げる） | `throw new UnsupportedOperationException()` |
| Kotlin | `kotlinc`/`gradle` | `gradle init` | `gradle test` | `TODO()` |
| C# | `dotnet` | `dotnet new xunit` | `dotnet test exercises/NN-*` | `throw new NotImplementedException()` |

## 注意

- 未実装マーカーで落ちるテストは「失敗」であって「コンパイルエラー」ではないようにする（雛形がコンパイル/型検査を通ること）。コンパイルエラーでは学習者が何を直すべきかわからない
- 出力予測問題は `ANSWER.txt` と、問題コードの実出力を比較する。実出力は `solutions/` 側のスクリプトで生成し、`ANSWER.txt` の正解を `exercises/` に置かない
- 実行時間が長くなる処理（ネットワーク、sleep、乱数）は問題に含めない。再現性がなくなる
