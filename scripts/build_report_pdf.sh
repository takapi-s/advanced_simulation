#!/bin/bash
# レポート Markdown を PDF にビルドする
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MD="$ROOT/results/report.md"
HTML="$ROOT/results/report.html"
PDF="$ROOT/results/report.pdf"
CSS="$ROOT/results/report.css"

pandoc "$MD" \
  -o "$HTML" \
  --standalone \
  --embed-resources \
  --css "$CSS"

EDGE=""
for candidate in msedge microsoft-edge; do
  if command -v "$candidate" >/dev/null 2>&1; then
    EDGE="$candidate"
    break
  fi
done

if [ -z "$EDGE" ]; then
  for candidate in \
    "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" \
    "/c/Program Files/Microsoft/Edge/Application/msedge.exe"; do
    if [ -x "$candidate" ]; then
      EDGE="$candidate"
      break
    fi
  done
fi

if [ -z "$EDGE" ]; then
  echo "Edge が見つかりません。HTML を開いて PDF として保存してください: $HTML"
  exit 1
fi

"$EDGE" --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$PDF" "file://$(cygpath -w "$HTML" 2>/dev/null | sed 's|\\|/|g' || echo "$HTML")"

echo "Generated: $PDF"
