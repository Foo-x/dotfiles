#!/usr/bin/env bash
# Usage: run_alloy.sh <model.als> [出力ディレクトリ]
# Alloy の全コマンド(run/check)を実行し、結果を日本語で要約する。
set -uo pipefail

model="${1:-}"
if [[ -z "$model" || ! -f "$model" ]]; then
  echo "usage: $0 <model.als> [outdir]" >&2
  exit 2
fi
outdir="${2:-${model%.als}-out}"

# コマンド名は環境で異なる(alloy / alloy6)。ALLOY_CMD で上書き可能
if [[ -n "${ALLOY_CMD:-}" ]]; then
  cmd=("$ALLOY_CMD")
elif command -v alloy >/dev/null 2>&1; then
  cmd=(alloy)
elif command -v alloy6 >/dev/null 2>&1; then
  cmd=(alloy6)
elif [[ -n "${ALLOY_JAR:-}" && -f "$ALLOY_JAR" ]] && command -v java >/dev/null 2>&1; then
  cmd=(java -jar "$ALLOY_JAR")
else
  echo "Alloy CLI が見つかりません(alloy / alloy6 / ALLOY_CMD / ALLOY_JAR)" >&2
  exit 3
fi

# サンドボックス等で /tmp が書込不可でも、Alloy の native solver 展開先を確保する
if [[ -n "${TMPDIR:-}" && -w "${TMPDIR}" ]]; then
  export JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS:-} -Djava.io.tmpdir=${TMPDIR}"
fi

log="$(mktemp)"
trap 'rm -f "$log"' EXIT
"${cmd[@]}" exec -f -t text -o "$outdir" "$model" >"$log" 2>&1
rc=$?

# 構文・型エラー時は SAT/UNSAT 行が出ないため生ログを返す
if ! grep -qE '^[0-9]+\. (run|check) ' "$log"; then
  grep -vE '^(Picked up JAVA_TOOL_OPTIONS|[[:space:]]+at )' "$log"
  echo "--- 実行失敗 (rc=$rc): モデルのエラーを修正して再実行してください ---" >&2
  exit 1
fi

echo "コマンド | 結果 | 意味"
echo "--- | --- | ---"
while read -r idx kind name rest; do
  verdict="${rest##* }"
  case "$kind:$verdict" in
    run:SAT)     meaning="充足可能(インスタンスあり)" ;;
    run:UNSAT)   meaning="充足不能(制約が矛盾/過剰、または到達不能)" ;;
    check:SAT)   meaning="反例あり(性質が破れる)" ;;
    check:UNSAT) meaning="反例なし(scope 内で性質が成立)" ;;
    *)           meaning="?" ;;
  esac
  echo "$kind $name | $verdict | $meaning"
done < <(grep -E '^[0-9]+\. (run|check) ' "$log")

echo
echo "出力先: $outdir (check が SAT のものは *-solution-*.txt が反例)"
