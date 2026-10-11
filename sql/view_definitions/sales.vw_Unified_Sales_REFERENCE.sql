-- BIKESTORES / VIEW DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [sales].[vw_Unified_Sales].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Step 18 - Query 2
-- Unified Sales Reporting View

CREATE   VIEW [sales].[vw_Unified_Sales]
AS

SELECT
    O.order_id,
    OI.item_id,
    O.order_date,
    O.order_status,

    C.customer_id,
    C.first_name AS Customer_First_Name,
    C.last_name AS Customer_Last_Name,

    ST.store_id,
    ST.store_name,
    ST.city AS Store_City,

    S.staff_id,
    S.first_name AS Staff_First_Name,
    S.last_name AS Staff_Last_Name,

    P.product_id,
    P.product_name,

    B.brand_name,
    CAT.category_name,

    OI.quantity,
    OI.list_price,
    OI.discount,

    OI.quantity * OI.list_price *
    (1 - OI.discount) AS Net_Revenue

FROM sales.order_items AS OI

INNER JOIN sales.orders AS O
    ON OI.order_id = O.order_id

LEFT JOIN sales.customers AS C
    ON O.customer_id = C.customer_id

INNER JOIN sales.stores AS ST
    ON O.store_id = ST.store_id

INNER JOIN sales.staffs AS S
    ON O.staff_id = S.staff_id

INNER JOIN production.products AS P
    ON OI.product_id = P.product_id

INNER JOIN production.brands AS B
    ON P.brand_id = B.brand_id

INNER JOIN production.categories AS CAT
    ON P.category_id = CAT.category_id;
GO
