-- BIKESTORES / VIEW DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [sales].[vw_sales_summary].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [sales].[vw_sales_summary]
AS

SELECT
    o.order_id,
    o.order_date,

    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,

    s.store_id,
    s.store_name,

    st.staff_id,
    CONCAT(st.first_name, ' ', st.last_name) AS staff_name,

    SUM(
        oi.quantity * oi.list_price * (1 - oi.discount)
    ) AS revenue,

    CASE o.order_status
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Processing'
        WHEN 3 THEN 'Rejected'
        WHEN 4 THEN 'Completed'
        ELSE 'Unknown'
    END AS status_label

FROM sales.orders AS o

LEFT JOIN sales.customers AS c
    ON o.customer_id = c.customer_id

JOIN sales.stores AS s
    ON o.store_id = s.store_id

JOIN sales.staffs AS st
    ON o.staff_id = st.staff_id

JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id

GROUP BY
    o.order_id,
    o.order_date,
    c.customer_id,
    c.first_name,
    c.last_name,
    s.store_id,
    s.store_name,
    st.staff_id,
    st.first_name,
    st.last_name,
    o.order_status;
GO
