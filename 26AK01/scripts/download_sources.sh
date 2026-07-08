#!/bin/bash
# 姫野ベンチのソースコードを RIKEN から取得する
# 実行: bash scripts/download_sources.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/src"
mkdir -p "$SRC"
cd "$SRC"

BASE="https://i.riken.jp/wp-content/uploads/2015/07"

download_zip() {
  local zip="$1"
  local lzh="$2"
  if [[ -f "$lzh" ]]; then
    echo "[skip] $lzh は既に存在します"
    return 0
  fi
  echo "[get]  $zip"
  if command -v curl >/dev/null 2>&1; then
    curl -fL "$BASE/$zip" -o "$zip"
  elif command -v wget >/dev/null 2>&1; then
    wget -q --show-progress "$BASE/$zip" -O "$zip"
  else
    echo "curl または wget が必要です" >&2
    exit 1
  fi
  unzip -o "$zip"
}

extract_lzh() {
  local archive="$1"
  if command -v lha >/dev/null 2>&1; then
    lha xfi "$archive"
  elif python3 -c "import lhafile" 2>/dev/null; then
    python3 - "$archive" <<'PY'
import lhafile, sys
lha = lhafile.Lhafile(sys.argv[1])
for info in lha.infolist():
    with open(info.filename, "wb") as out:
        out.write(lha.read(info.filename))
PY
  elif command -v 7z >/dev/null 2>&1; then
    7z x -y "$archive"
  else
    echo "lha, python3+lhafile, または 7z で $archive を展開してください" >&2
    exit 1
  fi
}

echo "=== OpenMP 版 (課題 1〜3) ==="
download_zip "himenobmtxp_cc_omp_al.zip" "himenobmtxp_cc_omp_al.lzh"
extract_lzh "himenobmtxp_cc_omp_al.lzh"

echo ""
echo "=== MPI 版 (発展課題・任意) ==="
download_zip "cc_himenobmtxp_mpi.zip" "cc_himenobmtxp_mpi.lzh"
extract_lzh "cc_himenobmtxp_mpi.lzh"

if [[ -f Makefile.sample && ! -f Makefile ]]; then
  cp Makefile.sample Makefile
  sed -i 's/^mpicc/mpicc -cc=icx/' Makefile 2>/dev/null || \
    sed -i '' 's/^mpicc/mpicc -cc=icx/' Makefile
fi

echo ""
echo "完了: $SRC"
ls -la "$SRC"
