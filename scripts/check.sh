#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

for page in "$ROOT/index.html" "$ROOT/futakuchi.html" "$ROOT/futakuchi-caremanager.html"; do
  test -s "$page"
  grep -qi '<html lang="ja"' "$page"
  grep -qi '<meta name="viewport"' "$page"
done

grep -qi 'index,follow' "$ROOT/index.html"
grep -qi 'index,follow' "$ROOT/futakuchi.html"
grep -qi 'noindex' "$ROOT/futakuchi-caremanager.html"
grep -q 'Allow: /' "$ROOT/robots.txt"
! grep -q 'Disallow: /' "$ROOT/robots.txt"
! grep -qE '公開前|確認用|仮配置|正式確認前' "$ROOT/futakuchi.html"
! grep -q 'staff-support.jpg' "$ROOT/futakuchi.html"
test -s "$ROOT/futakuchi-pamphlet-review.pdf"
test "$(pdfinfo "$ROOT/futakuchi-pamphlet-review.pdf" | awk '/^Pages:/ {print $2}')" = "2"

node --check "$ROOT/assets/futakuchi-tools.js"
node --check "$ROOT/assets/futakuchi-config.js"

for image in bathroom open-floor exercise-room; do
  test -s "$ROOT/assets/futakuchi/$image.jpg"
done

grep -q '1NP2rkayGXamvUf8ocuT5eG2ZE4mcNRVAk_jqCs2gc80' "$ROOT/assets/futakuchi-config.js"
grep -q 'id="availability"' "$ROOT/futakuchi.html"
grep -q 'id="price"' "$ROOT/futakuchi.html"
grep -q 'id="availability"' "$ROOT/futakuchi-caremanager.html"
grep -q 'id="price"' "$ROOT/futakuchi-caremanager.html"

if grep -R -nE 'api[_-]?key|password|token[[:space:]]*[:=]' "$ROOT" --exclude-dir='.git' --exclude='check.sh' --exclude='check.sh.backup-*'; then
  echo '機密情報の疑いがある文字列を検出しました' >&2
  exit 1
fi

echo 'plateau-futakuchi-review checks: OK'
