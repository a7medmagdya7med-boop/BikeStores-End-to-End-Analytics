# Data Quality & Reconciliation

## Scope and evidence

Two validation layers exist:

1. **SQL Server:** source scripts include warehouse validation procedures, a SQL monitoring table and `monitoring.usp_Run_Data_Quality`. The SQL monitoring procedure checks quantity, discount and missing product dimension members.
2. **Power BI:** the DW Health dashboard contains DAX checks for missing/unexpected orders, duplicate line keys, orphan dimension keys, recomputed revenue and composite PASS/FAIL/score measures. Exact DAX source text must be exported from PBIX separately if code-level documentation is desired.

## Observed dashboard QA snapshot

| Check | Observed result |
|---|---:|
| Completed Source Orders | 1,445 |
| Warehouse Orders | 1,445 |
| Order Difference | 0 |
| Missing / Unexpected Orders | 0 / 0 |
| DW Fact Rows | 4,214 |
| Unique Order Items | 4,214 |
| Duplicate Fact Rows | 0 |
| Orphan Date / Store / Product Rows | 0 / 0 / 0 |
| Net Revenue | $6,662,615.24 |
| Recalculated Revenue | $6,662,615.24 |
| Revenue Difference | $0.00 |
| Invalid Sales Rows | 0 |
| Overall Dashboard Status | PASS |
| Dashboard Data Quality Score | 100% |

**Interpretation:** on the tested report snapshot, the defined checks produced the values above. Neither `PASS` nor `100%` is a universal guarantee of database correctness, and `100%` should not be called a record-level accuracy rate unless the DAX definition supports that claim.

## Reproducible read-only checks

- [`sql/read_only/01_source_business_kpis.sql`](../sql/read_only/01_source_business_kpis.sql): business scope and source metrics.
- [`sql/read_only/02_dw_quality_reconciliation.sql`](../sql/read_only/02_dw_quality_reconciliation.sql): source-to-warehouse lines/orders/revenue and warehouse invalids/orphans.
- [`sql/read_only/03_pipeline_monitoring.sql`](../sql/read_only/03_pipeline_monitoring.sql): inspect monitoring and orchestration logs.

All scripts are for an authorized BikeStores database copy and have not been re-executed against the live database during publication preparation.

## Additional validation needed before deployment

- Compare source and DW at the **same data snapshot**.
- Check uniqueness of `(OrderID, ItemID)` and exact order-key coverage, not only counts.
- Verify dates, orphan dimension references and acceptable price/discount ranges.
- Confirm that dashboard filters do not accidentally narrow global warehouse integrity checks.
- Store validation timestamp, source version, report version and refresh status.
- Test deliberate failure cases **in a sandbox** to confirm FAIL logic; avoid mutating production facts.
