#!/bin/bash
# 発展課題: MPI 版のビルドと実行
# 使用例:
#   bash mpi/build_mpi.sh S 1 1 1
#   bash mpi/build_mpi.sh S 2 1 1
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/src"
MPI_DIR="$ROOT/mpi"
BUILD="$MPI_DIR/build"
mkdir -p "$BUILD"

GRID="${1:-S}"
PX="${2:-1}"
PY="${3:-1}"
PZ="${4:-1}"
NP=$((PX * PY * PZ))
LOG="${5:-$ROOT/results/raw/mpi_${GRID}_p${NP}.log}"

if [[ -f /etc/profile ]]; then
  set +u
  # shellcheck disable=SC1091
  . /etc/profile
  set -u
fi

module load intel/2025 2>/dev/null || true
module load intelmpi/2025 2>/dev/null || true

if [[ ! -f "$SRC/paramset.sh" ]]; then
  echo "先に bash scripts/download_sources.sh を実行してください" >&2
  exit 1
fi

cd "$SRC"
bash ./paramset.sh "$GRID" "$PX" "$PY" "$PZ"

cp Makefile.sample Makefile
sed -i 's/^CC = mpicc/CC = mpicc -cc=icx/' Makefile
sed -i 's/^CFLAGS = -O3/CFLAGS = -O3 -std=gnu89/' Makefile

make clean 2>/dev/null || true
make
BIN="$SRC/bmt"
[[ -f "$BIN" ]] || BIN="$SRC/a.out"

{
  echo "===== Himeno MPI Benchmark ====="
  echo "date:      $(date -Iseconds 2>/dev/null || date)"
  echo "hostname:  $(hostname)"
  echo "grid:      $GRID"
  echo "processes: $NP (${PX}x${PY}x${PZ})"
  echo "command:   mpirun -np $NP $BIN"
  echo "================================"
  mpirun -np "$NP" "$BIN"
} | tee "$LOG"
