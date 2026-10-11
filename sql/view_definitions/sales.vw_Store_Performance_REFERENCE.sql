-- BIKESTORES / VIEW DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [sales].[vw_Store_Performance].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Step 18 - Query 3
-- Store Performance View

CREATE   VIEW [sales].[vw_Store_Performance]
AS

SELECT
    store_id,
    store_name,

    COUNT(DISTINCT order_id)
        AS Total_Orders,

    SUM(quantity)
        AS Units_Sold,

    ROUND(
        SUM(Net_Revenue), 2
    ) AS Total_Revenue,

    ROUND(
        SUM(Net_Revenue) /
        NULLIF(
            COUNT(DISTINCT order_id), 0
        ), 2
    ) AS Avg_Order_Value

FROM sales.vw_Unified_Sales

WHERE order_status = 4

GROUP BY store_id, store_name;
GO
