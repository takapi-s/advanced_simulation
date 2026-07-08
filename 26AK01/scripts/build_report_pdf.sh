#!/bin/bash
# レポート Markdown を PDF にビルドする
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MD="$ROOT/results/report.md"
HTML="$ROOT/results/report.html"
PDF="$ROOT/results/report.pdf"
CSS="$ROOT/results/report.css"

if command -v pandoc >/dev/null 2>&1; then
  pandoc "$MD" -o "$HTML" --standalone --embed-resources --css "$CSS"
else
  ROOT="$ROOT" python3 <<'PY'
import os
import re
from pathlib import Path
import markdown

root = Path(os.environ["ROOT"])
text = (root / "results" / "report.md").read_text(encoding="utf-8")

title = "レポート"
m = re.match(r"^---\n(.*?)\n---\n", text, re.DOTALL)
if m:
    for line in m.group(1).splitlines():
        if line.startswith("title:"):
            title = line.split(":", 1)[1].strip().strip('"')
    text = text[m.end():]

body = markdown.markdown(text, extensions=["tables", "fenced_code"])
css = (root / "results" / "report.css").read_text(encoding="utf-8")
html = f"""<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="utf-8" />
  <title>{title}</title>
  <style>{css}</style>
</head>
<body>
  <h1>{title}</h1>
  {body}
</body>
</html>
"""
(root / "results" / "report.html").write_text(html, encoding="utf-8")
PY
fi

BROWSER=""
for candidate in google-chrome chromium chromium-browser microsoft-edge msedge; do
  if command -v "$candidate" >/dev/null 2>&1; then
    BROWSER="$candidate"
    break
  fi
done

if [ -z "$BROWSER" ]; then
  for candidate in \
    "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" \
    "/c/Program Files/Microsoft/Edge/Application/msedge.exe"; do
    if [ -x "$candidate" ]; then
      BROWSER="$candidate"
      break
    fi
  done
fi

if [ -z "$BROWSER" ]; then
  echo "PDF 生成用ブラウザが見つかりません。HTML を開いて PDF として保存してください: $HTML"
  exit 1
fi

HTML_URI="file://$HTML"
if command -v cygpath >/dev/null 2>&1; then
  HTML_URI="file://$(cygpath -w "$HTML" | sed 's|\\|/|g')"
fi

"$BROWSER" --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$PDF" "$HTML_URI"

echo "Generated: $PDF"
