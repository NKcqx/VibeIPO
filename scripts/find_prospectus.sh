#!/usr/bin/env bash
# find_prospectus.sh — download a HK IPO prospectus PDF from hkexnews and save metadata
#
# Two modes:
#   1) Direct download (preferred):
#        scripts/find_prospectus.sh <code> <hkexnews-url> [zh|en]
#   2) Auto-search (best-effort, often fails because hkexnews is SPA):
#        scripts/find_prospectus.sh <code> [zh|en]
#
# Examples:
#   scripts/find_prospectus.sh 01236 https://www1.hkexnews.hk/app/sehk/2025/107918/documents/sehk25120104095_c.pdf zh
#   scripts/find_prospectus.sh 01236 zh

set -uo pipefail

if [ $# -lt 1 ]; then
  cat >&2 <<EOF
Usage:
  $0 <code> <hkexnews-url> [zh|en]      # direct download (recommended)
  $0 <code> [zh|en]                     # auto-search (may fail)

Examples:
  $0 01236 https://www1.hkexnews.hk/app/sehk/2025/107918/documents/sehk25120104095_c.pdf zh
  $0 01609 zh
EOF
  exit 1
fi

CODE="$1"
shift

URL=""
LANG="zh"

# Parse remaining args
for arg in "$@"; do
  case "$arg" in
    http*) URL="$arg" ;;
    zh|en) LANG="$arg" ;;
  esac
done

CODE_5=$(printf "%05d" "$((10#${CODE}))")
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
OUT_DIR="${OUT_DIR:-./prospectus}"
mkdir -p "$OUT_DIR"

# === Mode 1: direct URL given ===
if [ -n "$URL" ]; then
  echo "→ Direct download mode."
  echo "  URL: $URL"
else
  # === Mode 2: best-effort auto-search ===
  echo "→ Auto-search mode (may fail; hkexnews is SPA, IPO pages often don't expose direct PDF links)."
  AASTOCKS_URL="http://hk.aastocks.com/sc/stocks/market/ipo/upcomingipo/company-summary?symbol=${CODE_5}"
  echo "  Trying AASTOCKS: $AASTOCKS_URL"

  HTML=$(curl -sL -A "$UA" "$AASTOCKS_URL")
  PDF_URLS=$(echo "$HTML" | grep -oE 'https?://[^"'"'"' ]*hkexnews[^"'"'"' ]*\.pdf' | sort -u)

  if [ -z "$PDF_URLS" ]; then
    cat >&2 <<EOF
✗ No hkexnews PDF link found in AASTOCKS HTML for ${CODE_5}.

This is normal — hkexnews IPO pages use JS to render PDF links.

How to find the URL manually:
  1. Web search: site:hkexnews.hk "<繁體公司名>" 招股章程
     (look for files dated near the public-offer start date)
  2. Or browse:  https://www.hkexnews.hk → search by company name
  3. Or check etnet:  https://www.etnet.com.hk/www/tc/stocks/ipo-info.php?code=${CODE_5}
     (the "招股书 中文版/英文版" buttons link to hkexnews PDFs)

Once you have the URL, re-run this script in direct mode:
  $0 ${CODE_5} <hkexnews-url> ${LANG}
EOF
    exit 2
  fi

  echo "Found candidate PDF URLs:"
  echo "$PDF_URLS" | sed 's/^/  /'

  if [ "$LANG" = "zh" ]; then
    URL=$(echo "$PDF_URLS" | grep -E '_c\.pdf$' | head -1)
    [ -z "$URL" ] && URL=$(echo "$PDF_URLS" | head -1)
  else
    URL=$(echo "$PDF_URLS" | grep -vE '_c\.pdf$' | head -1)
    [ -z "$URL" ] && URL=$(echo "$PDF_URLS" | head -1)
  fi
  echo "→ Selected: $URL"
fi

# === Verify URL ===
echo "→ Verifying URL ..."
HEAD_OUT=$(curl -sI -A "$UA" "$URL")
STATUS=$(echo "$HEAD_OUT" | head -1 | awk '{print $2}')
CTYPE=$(echo "$HEAD_OUT" | grep -i '^content-type:' | head -1 | tr -d '\r' | sed 's/^[Cc]ontent-[Tt]ype: //')
LMOD=$(echo "$HEAD_OUT" | grep -i '^last-modified:' | head -1 | tr -d '\r' | sed 's/^[Ll]ast-[Mm]odified: //')
SIZE_HDR=$(echo "$HEAD_OUT" | grep -i '^content-length:' | head -1 | tr -d '\r' | awk '{print $2}')

echo "  Status:        $STATUS"
echo "  Content-Type:  ${CTYPE:-unknown}"
echo "  Last-Modified: ${LMOD:-unknown}"
echo "  Size (hdr):    ${SIZE_HDR:-unknown} bytes"

if [ "$STATUS" != "200" ]; then
  echo "✗ Non-200 response. The URL may be stale (hkexnews replaces application proofs without notice)." >&2
  exit 3
fi

if ! echo "$CTYPE" | grep -qi pdf; then
  echo "⚠ Content-Type is not PDF. Proceeding anyway..." >&2
fi

# === Download ===
OUT_FILE="$OUT_DIR/${CODE_5}_${LANG}.pdf"
echo "→ Downloading to $OUT_FILE ..."
curl -sL -A "$UA" "$URL" -o "$OUT_FILE"
ACTUAL_SIZE=$(wc -c < "$OUT_FILE")
SIZE_HUMAN=$(awk -v s="$ACTUAL_SIZE" 'BEGIN { printf "%.1f MB", s/1024/1024 }')
echo "✓ Saved: $OUT_FILE ($SIZE_HUMAN)"

# === Save metadata ===
META_FILE="$OUT_DIR/${CODE_5}_${LANG}.meta.txt"
cat > "$META_FILE" <<EOF
code: ${CODE_5}
lang: ${LANG}
url: ${URL}
status: ${STATUS}
content_type: ${CTYPE}
last_modified: ${LMOD}
fetched_at: $(date '+%Y-%m-%d %H:%M:%S %Z')
size_bytes: ${ACTUAL_SIZE}
size_human: ${SIZE_HUMAN}
EOF
echo "✓ Metadata: $META_FILE"
echo ""
echo "Done. Cite this file in your analysis report."
