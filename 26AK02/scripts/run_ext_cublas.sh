#!/bin/bash
# NVIDIA GPU (cuBLAS) 上で発展課題をコンパイル・実行
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p bin results/raw

echo "=== Node info ==="
hostname
date
nvidia-smi 2>/dev/null | head -20 || true
echo ""

echo "=== Build cuBLAS ==="
nvcc -O2 -ccbin g++ -I/usr/local/cuda/include \
  src/q_ext_cublas.cu -o bin/q_ext_cublas \
  -L/usr/local/cuda/lib64 -lcublas

LOG="${OUT_DIR:-results/raw}/q_ext_cublas.log"
{
  echo "Timing: wall clock time"
  echo "Trials per n: ${NTRIALS:-5}"
  echo ""
  for n in 4000 8000 12000 16000 20000; do
    echo "########################################"
    echo "# n = $n"
    echo "########################################"
    ./bin/q_ext_cublas "$n" "${NTRIALS:-5}"
    echo ""
  done
} | tee "$LOG"

echo "結果: $LOG"
