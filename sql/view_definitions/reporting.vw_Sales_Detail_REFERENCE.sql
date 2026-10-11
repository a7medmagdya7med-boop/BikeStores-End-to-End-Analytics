-- BIKESTORES / VIEW DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [reporting].[vw_Sales_Detail].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [reporting].[vw_Sales_Detail]
AS
SELECT
    O.order_id AS OrderID,
    O.customer_id AS CustomerID,
    O.store_id AS StoreID,
    O.staff_id AS StaffID,

    CAST(O.order_date AS DATE) AS OrderDate,
    YEAR(O.order_date) AS SalesYear,
    MONTH(O.order_date) AS SalesMonth,
    DATEPART(QUARTER, O.order_date) AS SalesQuarter,

    O.order_status AS OrderStatus,

    OI.item_id AS ItemID,
    OI.product_id AS ProductID,
    OI.quantity AS Quantity,
    OI.list_price AS UnitPrice,
    OI.discount AS DiscountRate,

    CAST(
        OI.quantity
        * OI.list_price
        * (1 - OI.discount)
        AS DECIMAL(19,4)
    ) AS NetRevenue

FROM sales.orders AS O

INNER JOIN sales.order_items AS OI
    ON O.order_id = OI.order_id

WHERE O.order_status = 4;
GO
