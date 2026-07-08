#!/bin/bash
# 姫野ベンチの標準出力から CPU 時間・ループ回数・MFLOPS を抽出する
# 使用例: bash scripts/parse_output.sh results/raw/task1_S_t1.log
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <logfile>..." >&2
  exit 1
fi

printf "%-40s %12s %15s %12s\n" "file" "cpu_sec" "loop_executed" "mflops"
printf "%-40s %12s %15s %12s\n" "----" "-------" "--------------" "------"

for f in "$@"; do
  cpu="$(grep -Eo 'cpu[[:space:]]*:[[:space:]]*[0-9.]+' "$f" | tail -1 | grep -Eo '[0-9.]+$' || true)"
  if [[ -z "$cpu" ]]; then
    cpu="$(grep -Eo 'cpu[[:space:]]*:[[:space:]]*[0-9.]+ sec' "$f" | tail -1 | grep -Eo '[0-9.]+' || true)"
  fi

  loop="$(grep -E 'Loop executed for[[:space:]]+[0-9]+' "$f" | tail -1 | sed -E 's/.*Loop executed for[[:space:]]+([0-9]+).*/\1/' || true)"

  mflops="$(grep -E 'MFLOPS measured[[:space:]]*:' "$f" | tail -1 | grep -Eo '[0-9.]+$' || true)"
  if [[ -z "$mflops" ]]; then
    # 一部の配布物は GFLOPS 表記
    gflops="$(grep -E 'GFLOPS measured[[:space:]]*:' "$f" | tail -1 | grep -Eo '[0-9.]+$' || true)"
    if [[ -n "$gflops" ]]; then
      mflops="$(awk "BEGIN {printf \"%.4f\", $gflops * 1000}")"
    fi
  fi

  printf "%-40s %12s %15s %12s\n" "$(basename "$f")" "${cpu:--}" "${loop:--}" "${mflops:--}"
done
