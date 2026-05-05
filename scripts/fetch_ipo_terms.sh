#!/usr/bin/env bash
# fetch_ipo_terms.sh — pull deal terms for a HK IPO from etnet + AASTOCKS
# Usage: scripts/fetch_ipo_terms.sh <5-digit-code>
# Example: scripts/fetch_ipo_terms.sh 01609

set -uo pipefail
# NB: not using -e because grep returns non-zero on no-match, which is normal here

if [ $# -lt 1 ]; then
  echo "Usage: $0 <5-digit-stock-code>" >&2
  echo "Example: $0 01609" >&2
  exit 1
fi

CODE="$1"
# Normalize to 5-digit zero-padded
CODE_5=$(printf "%05d" "$((10#${CODE}))")
# AASTOCKS uses unpadded; etnet uses padded
CODE_RAW="$((10#${CODE}))"

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"

OUT_DIR="${OUT_DIR:-./ipo_terms}"
mkdir -p "$OUT_DIR"
TS=$(date +%Y%m%d_%H%M%S)
RAW_DIR="$OUT_DIR/${CODE_5}_${TS}"
mkdir -p "$RAW_DIR"

ETNET_URL="https://www.etnet.com.hk/www/tc/stocks/ipo-info.php?code=${CODE_5}"
AASTOCKS_URL="http://hk.aastocks.com/sc/stocks/market/ipo/upcomingipo/company-summary?symbol=${CODE_5}"

echo "→ Fetching etnet: $ETNET_URL"
curl -sL -A "$UA" "$ETNET_URL" -o "$RAW_DIR/etnet.html"

echo "→ Fetching AASTOCKS: $AASTOCKS_URL"
curl -sL -A "$UA" "$AASTOCKS_URL" -o "$RAW_DIR/aastocks.html"

# Extract key fields from etnet HTML using grep + sed
extract_field() {
  local file="$1"
  local pattern="$2"
  local n="${3:-1}"
  grep -oE "$pattern" "$file" 2>/dev/null | sed -n "${n}p" || echo "未取得"
}

echo ""
echo "=========================================="
echo "  IPO Terms — Stock Code ${CODE_5}.HK"
echo "  Fetched: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "=========================================="

grab() { (grep -oE "$1" "$2" 2>/dev/null || true) | head -1; }

# Company name (etnet <title>)
NAME=$(grep -oE '<title>[^<]+</title>' "$RAW_DIR/etnet.html" 2>/dev/null | head -1 | sed -E 's|<[^>]+>||g; s/ - 基本資料.*//' || echo "")
echo "Name (etnet):     ${NAME:-未取得}"

# Price — match $NN.NN[ - $NN.NN] (also handle full-width)
PRICE=$(grep -oE '\$[0-9]+\.[0-9]+([[:space:]]*[-–][[:space:]]*\$[0-9]+\.[0-9]+)?' "$RAW_DIR/etnet.html" 2>/dev/null | head -1)
echo "Price:            ${PRICE:-未取得}"

# Lot size — typically appears as e.g. "200股" or "50股"
LOT=$(grep -oE '[0-9]{2,4}股' "$RAW_DIR/etnet.html" 2>/dev/null | sort -u | head -1)
echo "Lot:              ${LOT:-未取得}"

# Entry fee — like $4,974.67 or $6,060.51
FEE=$(grep -oE '\$[0-9]{1,3},[0-9]{3}\.[0-9]{2}' "$RAW_DIR/etnet.html" 2>/dev/null | head -1)
echo "Entry fee:        ${FEE:-未取得}"

# All YYYY/MM/DD dates (招股 + 上市) in order of appearance
echo "Key dates (etnet, in order):"
grep -oE '20[0-9]{2}/[0-9]{2}/[0-9]{2}' "$RAW_DIR/etnet.html" 2>/dev/null | head -8 | sed 's/^/  - /' || echo "  未取得"

# From AASTOCKS — extract clean table cells around key markers
echo ""
echo "Sponsors / underwriters / cornerstones (AASTOCKS):"
# AASTOCKS uses sponsor.aspx links with text spans that survive grep
grep -oE '保荐人.aspx[^"]*"[^>]*>[^<]+' "$RAW_DIR/aastocks.html" 2>/dev/null | sed -E 's|.*>||' | sort -u | head -5 | sed 's/^/  保荐人: /'

# Cornerstones — AASTOCKS lists them as "基金"/"公司" rows in 机构性投资者 table
echo ""
echo "  Cornerstones (机构性投资者, raw cells):"
python3 -c "
import re, sys
with open('$RAW_DIR/aastocks.html', encoding='utf-8') as f:
    html = f.read()
# Find 机构性投资者 section
m = re.search(r'机构性投资者(.*?)同期新股', html, re.DOTALL)
if m:
    section = m.group(1)
    rows = re.findall(r'<td[^>]*>([^<]+)</td>', section)
    rows = [r.strip() for r in rows if r.strip() and not r.strip().startswith('只供')]
    for r in rows[:15]:
        print('    -', r)
else:
    print('    (no cornerstone table found)')
" 2>/dev/null || echo "    (python3 not available; check $RAW_DIR/aastocks.html manually)"

echo ""
echo "Raw HTML saved to: $RAW_DIR"
echo ""
echo "Manual links to verify (open in browser):"
echo "  etnet:    $ETNET_URL"
echo "  AASTOCKS: $AASTOCKS_URL"
echo ""
echo "If extraction looks wrong, re-grep manually:"
echo "  grep -i '招股价\\|发售价\\|每手\\|入场费\\|绿鞋\\|超额' $RAW_DIR/etnet.html"
echo ""
