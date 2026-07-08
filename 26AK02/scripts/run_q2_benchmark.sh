#!/bin/bash
# 【2】行列積のベンチマーク (n = 2000, 4000, ..., 10000)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -f /etc/profile ]]; then
  set +u
  # shellcheck disable=SC1091
  . /etc/profile
  set -u
fi

if command -v module >/dev/null 2>&1; then
  module load intel/2025 2>/dev/null || true
fi

OUT_DIR="${OUT_DIR:-results/raw}"
NTrials="${NTRIALS:-5}"
mkdir -p "$OUT_DIR"

bash scripts/compile.sh

LOG="${OUT_DIR}/q2_gemm.log"
{
  echo "=== Node info ==="
  hostname
  date
  lscpu | head -20
  free -h 2>/dev/null || true
  echo ""
  echo "Timing: wall clock time (CLOCK_MONOTONIC)"
  echo "Trials per n: $NTrials"
  echo ""

  for n in 2000 4000 6000 8000 10000; do
    echo "########################################"
    echo "# n = $n"
    echo "########################################"
    ./bin/q2_gemm "$n" "$NTrials"
    echo ""
  done
} | tee "$LOG"

echo "結果: $LOG"
