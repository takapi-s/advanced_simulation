#!/bin/bash
# AMD GPU (rocBLAS) 上で発展課題をコンパイル・実行
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p bin results/raw

echo "=== Node info ==="
hostname
date
rocminfo 2>/dev/null | head -20 || true
rocm-smi 2>/dev/null | head -15 || true
echo ""

echo "=== Build rocBLAS ==="
hipcc -O2 -std=c++17 -I/opt/rocm/include -D__HIP_PLATFORM_AMD__ \
  src/q_ext_rocblas.cpp -o bin/q_ext_rocblas -L/opt/rocm/lib -lrocblas

LOG="${OUT_DIR:-results/raw}/q_ext_rocblas.log"
{
  echo "Timing: wall clock time"
  echo "Trials per n: ${NTRIALS:-5}"
  echo ""
  for n in 4000 8000 12000 16000 20000; do
    echo "########################################"
    echo "# n = $n"
    echo "########################################"
    ./bin/q_ext_rocblas "$n" "${NTRIALS:-5}"
    echo ""
  done
} | tee "$LOG"

echo "結果: $LOG"
