# SQL Files: safety classification

| Folder | Content | Execute? |
|---|---|---|
| `read_only/` | New SELECT-only source and reconciliation queries | On an authorized copy after review |
| `business_analysis/` | Original Step 1–20 analysis/training reference excerpts (may contain DDL) | **No**, browse as reference only |
| `schema_snapshots/` | Extracted 13-table DDL: `CREATE TABLE` / `ALTER TABLE` | **No**, reference until test plan approved |
| `procedure_definitions/` | Stored procedure definitions exported from SQL Server | **No**, `CREATE PROCEDURE` changes objects; body may delete/reload rows if later called |
| `view_definitions/` | Views exported from SQL Server | **No** without dependency review |

No file here claims to rebuild the full database from a blank instance. The operational OLTP tables/data and full source creation scripts are not included. See [`docs/REPRODUCIBILITY_AND_LIMITATIONS.md`](../docs/REPRODUCIBILITY_AND_LIMITATIONS.md).
