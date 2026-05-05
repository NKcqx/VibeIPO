# HKEX Disclosure URL Patterns

Reference for locating HK IPO documents on hkexnews.

## Common URL patterns

```
# Application Proof / supplemental docs (listing-id era):
https://www1.hkexnews.hk/app/sehk/<YYYY>/<listing-id>/documents/sehk<YYMMDD><nnnnn>_c.pdf
https://www1.hkexnews.hk/app/sehk/<YYYY>/<listing-id>/a<addendum-id>/sehk<YYMMDD><nnnnn>_c.pdf

# Older listed-co announcements:
https://www1.hkexnews.hk/listedco/listconews/sehk/<YYYY>/<MMDD>/<YYYYMMDD><nnnnn>_c.pdf
```

`_c.pdf` = Chinese, no suffix often = English.

## Verification commands

```bash
# Check existence + content type:
curl -sI "<URL>" | head -10
# Expect: HTTP/2 200 + content-type: application/pdf

# Save & inspect first pages:
curl -sL "<URL>" -o /tmp/prospectus.pdf
```

Then use the Read tool on the saved file (the agent's PDF reader handles it).

## Locating documents when URL is unknown

In order of preference:

1. **Web search**: `site:hkexnews.hk "<繁體公司名>" 招股章程 OR "招股書"`.
2. **Indirect aggregators** (only as pointers, never as primary citations):
   - etnet IPO page: `https://www.etnet.com.hk/www/tc/stocks/ipo-info.php?code=<5-digit-code>`
   - AASTOCKS upcoming IPO: `http://hk.aastocks.com/sc/stocks/market/ipo/upcomingipo/company-summary?symbol=<code>`
3. **Manual disclosure search**: visit `https://www.hkexnews.hk` → 「上市公司公告及通告」/ 「IPO 资讯」.

Never rely on third-party PDF mirrors (gearfront, ipo123, etc.) for the citation — only for finding the path; final citation must point to hkexnews.hk.

## Note on Application Proof vs final prospectus

- **Application Proof (申请版本 / 草擬本)**: filed earlier; price/share-count appear as `[編纂]`. Business and financial sections are real.
- **Post-Hearing Information Pack (PHIP)**: after hearing approval; closer to final.
- **Formal Prospectus (招股章程)**: registered with the Companies Registry; this is the version with binding price range and timetable. Look for files dated within a few days of the public-offer start date.

Always state clearly in the report which version you read and the date.
