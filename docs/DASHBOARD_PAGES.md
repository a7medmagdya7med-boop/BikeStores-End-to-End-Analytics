# Power BI — Dashboard Pages & Screenshots

The user confirmed a seven-page Power BI report and verified that its executive overview opens in Power BI Service. The full seven-tab name list and high-resolution clean screenshots have not been supplied as a curated set for this release.

## Confirmed page themes from the project history

| Page/theme | Purpose |
|---|---|
| Executive Overview | Revenue, orders, AOV and key sales performance |
| Store Performance Analytics | Store-based comparison and filters |
| Time Intelligence & Sales Trends | Revenue trends, prior-year comparisons, MoM and YoY |
| Revenue Growth Diagnostics | Period variance and revenue-growth drivers |
| DW \| Executive Overview | Metrics from the warehouse fact/dimensions |
| DW Health & Data Quality | PASS/FAIL cards, reconciliation and key integrity checks |
| Remaining seventh tab | Name to verify from PBIX; do not assign an invented label |

The outline above is a topic inventory, not an asserted page order. The original PBIX is the source of truth for page labels.

## Add authorized screenshots

Save full-page captures to `screenshots/` using meaningful names. Before uploading: collapse editing panes, choose a consistent 16:9 view, check that visuals are readable, remove account/profile details and verify permission to share underlying numbers.

A Power BI Service report URL has not been included because a shareable, permission-safe URL was not provided. A successful publish **does not mean** a public link is available.

## PBIX handling

`.gitignore` excludes `.pbix` by default. Add it only after examining embedded data, connection information, sharing rights and file size, and deciding that publication is appropriate. A PDF of the report can be a useful additional noninteractive artifact when sharing is authorized.
