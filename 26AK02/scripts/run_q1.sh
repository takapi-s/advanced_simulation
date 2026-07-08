#!/bin/bash
# 【1】共役勾配法・固有値問題を実行
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
mkdir -p "$OUT_DIR"

bash scripts/compile.sh

LOG="${OUT_DIR}/q1.log"
{
  echo "=== Node info ==="
  hostname
  date
  lscpu | head -20
  echo ""
  echo "=== q1_cg ==="
  ./bin/q1_cg
  echo ""
  echo "=== q1_eigen ==="
  ./bin/q1_eigen
} | tee "$LOG"

echo "結果: $LOG"
