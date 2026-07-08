#!/bin/bash
# 姫野ベンチ OpenMP 版をコンパイルする
# 使用例:
#   bash scripts/compile.sh
#   bash scripts/compile.sh -O3
#   OPT_LEVEL=-O0 bash scripts/compile.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OPT_LEVEL="${OPT_LEVEL:--O2}"
OUTPUT="${OUTPUT:-bin/himeno_omp}"

if [[ -f /etc/profile ]]; then
  set +u
  # shellcheck disable=SC1091
  . /etc/profile
  set -u
fi

if command -v module >/dev/null 2>&1; then
  module load intel/2025 2>/dev/null || true
fi

CC="${CC:-icx}"
SRC="${SRC:-src/himenoBMTxpa.c}"

if [[ ! -f "$SRC" ]]; then
  echo "ソースが見つかりません: $SRC" >&2
  echo "先に bash scripts/download_sources.sh を実行してください" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

CMD=("$CC" -fopenmp -std=gnu89 "$OPT_LEVEL" -o "$OUTPUT" "$SRC")
echo "COMPILE_CMD=${CMD[*]}"
"${CMD[@]}"

echo "ビルド完了: $OUTPUT"
