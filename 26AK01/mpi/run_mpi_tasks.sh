#!/bin/bash
# 発展課題: MPI プロセス数 1/2/4/8 で測定
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/results/raw"

# プロセス数と分割 (x,y,z) の対応
declare -A PARTITIONS=(
  [1]="1 1 1"
  [2]="2 1 1"
  [4]="2 2 1"
  [8]="2 2 2"
)

for np in 1 2 4 8; do
  read -r px py pz <<< "${PARTITIONS[$np]}"
  bash "$ROOT/mpi/build_mpi.sh" S "$px" "$py" "$pz"
done

bash "$ROOT/scripts/parse_output.sh" "$ROOT/results/raw"/mpi_*.log
