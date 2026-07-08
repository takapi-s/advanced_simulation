#!/bin/bash
# 姫野ベンチを 1 回実行し、結果をログに保存する
# 使用例:
#   OMP_NUM_THREADS=1 bash scripts/run_benchmark.sh S results/raw/task1_S_t1.log
#   GRID=S THREADS=4 OPT=-O3 bash scripts/run_benchmark.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BIN="${BIN:-bin/himeno_omp}"
GRID="${GRID:-S}"
THREADS="${OMP_NUM_THREADS:-${THREADS:-1}}"
OPT="${OPT:--O2}"
LOG="${1:-}"

export OMP_NUM_THREADS="$THREADS"

if [[ ! -x "$BIN" ]] || [[ "${FORCE_REBUILD:-0}" == "1" ]]; then
  OPT_LEVEL="$OPT" OUTPUT="$BIN" bash scripts/compile.sh
fi

{
  echo "===== Himeno Benchmark ====="
  echo "date:      $(date -Iseconds 2>/dev/null || date)"
  echo "hostname:  $(hostname)"
  echo "grid:      $GRID"
  echo "threads:   $OMP_NUM_THREADS"
  echo "opt:       $OPT"
  if command -v lscpu >/dev/null 2>&1; then
    echo "cpu_model: $(lscpu | awk -F: '/Model name/{gsub(/^ +/,"",$2); print $2; exit}')"
    echo "cpu_cores: $(lscpu | awk -F: '/CPU\\(s\\):/{gsub(/^ +/,"",$2); print $2; exit}')"
  fi
  if [[ -f /proc/meminfo ]]; then
    echo "mem_total: $(awk '/MemTotal/{print $2 " kB"}' /proc/meminfo)"
  fi
  echo "command:   OMP_NUM_THREADS=$OMP_NUM_THREADS $BIN $GRID"
  echo "============================"
  echo ""
  "$BIN" "$GRID"
} | if [[ -n "$LOG" ]]; then
  mkdir -p "$(dirname "$LOG")"
  tee "$LOG"
else
  cat
fi
