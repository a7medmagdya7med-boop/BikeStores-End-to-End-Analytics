-- BIKESTORES / VIEW DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [sales].[vw_Customer_Orders].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Step 18 - Query 5
-- Modify Customer Orders View

CREATE   VIEW [sales].[vw_Customer_Orders]
AS

SELECT
    O.order_id,
    O.order_date,
    O.order_status,

    C.customer_id,
    C.first_name,
    C.last_name,
    C.email AS Customer_Email,
    C.city,
    C.state

FROM sales.orders AS O

LEFT JOIN sales.customers AS C
    ON O.customer_id = C.customer_id;
GO
