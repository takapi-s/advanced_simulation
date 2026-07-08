#!/bin/bash
# 課題 1〜3 をまとめて実行（計算ノード上で実行すること）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

RAW="$ROOT/results/raw"
mkdir -p "$RAW"

echo "=== 課題1: グリッドサイズ S/M/L (threads=1) ==="
for g in S M L; do
  OMP_NUM_THREADS=1 OPT=-O2 GRID="$g" \
    bash scripts/run_benchmark.sh "$RAW/task1_${g}_t1.log"
done

echo ""
echo "=== 課題2: 最適化オプション (grid=S, threads=1) ==="
for opt in -O0 -O1 -O2 -O3; do
  tag="${opt//-}"
  OMP_NUM_THREADS=1 OPT="$opt" GRID=S FORCE_REBUILD=1 \
    bash scripts/run_benchmark.sh "$RAW/task2_${tag}_t1.log"
done

echo ""
echo "=== 課題3: スレッド数 1/2/4/8 (grid=S, -O2) ==="
for t in 1 2 4 8; do
  OMP_NUM_THREADS="$t" OPT=-O2 GRID=S \
    bash scripts/run_benchmark.sh "$RAW/task3_t${t}.log"
done

echo ""
echo "=== 結果サマリ ==="
bash scripts/parse_output.sh "$RAW"/task1_*.log
bash scripts/parse_output.sh "$RAW"/task2_*.log
bash scripts/parse_output.sh "$RAW"/task3_*.log
