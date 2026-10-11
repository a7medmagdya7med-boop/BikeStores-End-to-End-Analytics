-- Read-only: BikeStores completed-order KPI reconciliation.
-- Run in SSMS against an authorized copy of the original BikeStores database.
-- Source orders are limited to order_status = 4, matching the warehouse load logic.
USE [BikeStores];
GO
SELECT
    COUNT(DISTINCT O.order_id) AS CompletedOrders,
    COUNT_BIG(*) AS CompletedOrderLines,
    SUM(CAST(OI.quantity AS BIGINT)) AS UnitsSold,
    CAST(SUM(CAST(OI.quantity * OI.list_price * (1 - OI.discount) AS DECIMAL(19, 4))) AS DECIMAL(19, 2)) AS NetRevenue
FROM sales.orders AS O
JOIN sales.order_items AS OI ON O.order_id = OI.order_id
WHERE O.order_status = 4;
GO
