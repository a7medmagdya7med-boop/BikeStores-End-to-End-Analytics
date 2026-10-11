-- BIKESTORES / VIEW DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [reporting].[vw_Order_Status_Audit].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [reporting].[vw_Order_Status_Audit]
AS
SELECT
    O.order_id AS OrderID,
    O.customer_id AS CustomerID,
    O.store_id AS StoreID,

    CAST(O.order_date AS DATE) AS OrderDate,
    YEAR(O.order_date) AS SalesYear,
    MONTH(O.order_date) AS SalesMonth,

    O.order_status AS OrderStatus,

    CASE O.order_status
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Processing'
        WHEN 3 THEN 'Rejected'
        WHEN 4 THEN 'Completed'
        ELSE 'Unknown'
    END AS OrderStatusName,

    CASE
        WHEN O.order_status = 4 THEN 1
        ELSE 0
    END AS IsCompleted,

    CAST(O.shipped_date AS DATE) AS ShippedDate

FROM sales.orders AS O;
GO
