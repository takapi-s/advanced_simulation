#!/bin/bash
# 26AK02 ソースをコンパイルする
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

export CC="${CC:-icx}"
export CFLAGS="${CFLAGS:--O2 -std=c11 -Wall -Wextra}"
export LDFLAGS="${LDFLAGS:--qmkl}"

if [[ -n "${MKLROOT:-}" ]]; then
  export MKL_CFLAGS="-I${MKLROOT}/include"
fi

echo "CC=$CC"
echo "CFLAGS=$CFLAGS"
echo "LDFLAGS=$LDFLAGS"
make clean all
echo "ビルド完了: bin/"
