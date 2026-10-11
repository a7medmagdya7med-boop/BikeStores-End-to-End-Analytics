# Reproducibility, Security & Limitations

## Current verification boundary

- Provided: T-SQL master file, two SSMS **schema-only** exports, SQL object inventory, and reported Power BI dashboard outputs.
- Verified in source text: 13 table definitions (four DW, nine ETL/monitoring/orchestration), DW foreign keys, ETL/procedure definitions, selected views.
- **Not** verified here: executing all scripts in a new clean database, end-to-end pipeline completion, independent live SQL KPI results, authentication/gateway refresh success, or sharing permissions.
- Operational `sales.*` and `production.*` source-table DDL and a full source data snapshot are **not included** in the uploaded schema exports.

## Why schema snapshots are reference-only

- They are DDL, not executable instructions for production.
- They do not include all operational dependencies or source data.
- The main schema includes views and stored procedures whose dependencies require an existing BikeStores OLTP database.
- The original main script contains training snippets, data-changing operations, local paths, user/role definitions and non-SQL outline text. Those are intentionally not included wholesale in the public release.
- The exposed procedure definitions can refresh and delete/reload data **if invoked**; DO NOT execute without code review.

## Refresh and publishing

The report was published to Power BI Service and viewed there, but the current data source is SQL Server LocalDB `(localdb)\MSSQLLocalDB`. Neither on-premises data gateway availability nor scheduled refresh success has been demonstrated. The report should be presented as a historical BI portfolio snapshot until a supported refresh solution is configured and tested.

## Publication checklist

- Review the copyright/license status of BikeStores sample data and third-party resources.
- Keep secrets, passwords, credentials, `.bak` files, connection strings and unapproved datasets out of public GitHub.
- Review and redact screenshots for account names, addresses or private URLs.
- Verify any intended public Power BI sharing URL and sharing permissions before adding it.
- Verify reported numbers on the same data snapshot (and note test date).
- Choose an explicit LICENSE only after selecting licensing terms; none is assumed here.
- Use a private repository for the first upload until content review is complete.
