# KPI Dictionary — Executive Report

The descriptions below are grounded in the user's observed Power BI report and the uploaded SQL. The **exact PBIX DAX measure expressions were not exported as text**, so the DAX definitions should be verified in Power BI Desktop before claiming code-level parity.

| KPI | Meaning and computation concept | Reporting caveat |
|---|---|---|
| Net Revenue | Sum of line `Quantity × UnitPrice × (1 - Discount)` after discounts | Revenue, **not** margin or profit |
| Total Orders | Distinct `OrderID` from the completed-order fact | Do not confuse with fact row count |
| Average Order Value (AOV) | Net Revenue ÷ distinct completed orders | Use the same filters in numerator and denominator |
| Units Sold | Sum of line `Quantity` | Not number of products or lines |
| Previous Year Revenue | Revenue of the comparable previous period | Depends on date table and filter context |
| YoY Revenue Growth % | `(Current period revenue − previous-year comparable revenue) / previous-year comparable revenue` | Partial years and slicers require care |
| Previous Month Revenue | Revenue of previous month | Depends on connected date table |
| MoM Revenue Growth % | `(Current month revenue − previous month revenue) / previous month revenue` | January should resolve previous December when data exists |

## Previously observed dashboard values

| KPI | Observed snapshot |
|---|---:|
| Net Revenue | $6,662,615.24 |
| Total Orders | 1,445 |
| Average Order Value | $4,610.81 |
| Units Sold | 6,318 |

Arithmetic check: `$6,662,615.24 / 1,445 = $4,610.81` after rounding to two decimals.

No underlying year-by-year numerical trends are included because the complete published PBIX time series is not provided as a data export. Do **not** invent top stores, best-selling products, margins, or causal explanations.
