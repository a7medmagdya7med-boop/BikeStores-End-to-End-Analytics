# Source Provenance & Transformation Record

The publication candidate was built from user-provided BikeStores SQL sources:

- `BikeStores_Business_Analysis_01.sql` — master instructional/project script (7,080 lines); **not copied wholesale** into this release because it includes unsafe or private training material.
- `BikeStores_Database_Schema.sql` — UTF-16 SSMS export with four DW tables, nine views and sixteen project stored procedures, as well as user/role statements excluded in this release.
- `BikeStores_ETL_Monitoring_Schema.sql` — UTF-16 SSMS export with nine ETL/monitoring/orchestration tables and constraints.
- `BikeStores_Database_Objects_Inventory_Clean.csv` — metadata list; edited inventory included here for reference.
- Previously reviewed Power BI screenshots — reference for KPI figures and published-report status; actual PBIX was not uploaded for direct inspection.

**Release transformations:** DDL snapshots were restricted to `CREATE TABLE` and `ALTER TABLE` batches; SQL user/role setup, original data and personal-path backup labs are omitted. Business analysis Step 1–20 excerpts preserve their staged `REFERENCE` warnings. Stored procedure and view definitions are taken directly from the schema export, marked `REFERENCE` and prefixed with SSMS session directives. Read-only validation queries were authored for reproducibility and are **new examples**, not asserted to be historical exact query files.

**No SQL Server instance was connected or queried to validate execution.** The sources support source-code structural descriptions and previous dashboard snapshots only.
