-- BIKESTORES / VIEW DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [reporting].[vw_Store_Dimension].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [reporting].[vw_Store_Dimension]
AS
SELECT
    store_id AS StoreID,
    store_name AS StoreName,
    city AS StoreCity,
    state AS StoreState

FROM sales.stores;
GO
