-- Read-only: compare the completed order source against the warehouse fact.
-- The same source snapshot and filter scope are required for comparable results.
USE [BikeStores];
GO
WITH SourceMetrics AS (
    SELECT
        COUNT_BIG(*) AS SalesLines,
        COUNT(DISTINCT O.order_id) AS Orders,
        CAST(SUM(CAST(OI.quantity * OI.list_price * (1 - OI.discount) AS DECIMAL(19, 4))) AS DECIMAL(19, 2)) AS NetRevenue
    FROM sales.orders AS O
    JOIN sales.order_items AS OI ON O.order_id = OI.order_id
    WHERE O.order_status = 4
),
WarehouseMetrics AS (
    SELECT
        COUNT_BIG(*) AS SalesLines,
        COUNT(DISTINCT OrderID) AS Orders,
        CAST(SUM(NetRevenue) AS DECIMAL(19, 2)) AS NetRevenue
    FROM dw.Fact_Sales
)
SELECT
    S.SalesLines AS SourceSalesLines, W.SalesLines AS WarehouseSalesLines,
    S.SalesLines - W.SalesLines AS SalesLineDifference,
    S.Orders AS SourceOrders, W.Orders AS WarehouseOrders,
    S.Orders - W.Orders AS OrderDifference,
    S.NetRevenue AS SourceNetRevenue, W.NetRevenue AS WarehouseNetRevenue,
    CAST(S.NetRevenue - W.NetRevenue AS DECIMAL(19, 2)) AS RevenueDifference
FROM SourceMetrics AS S
CROSS JOIN WarehouseMetrics AS W;
GO
SELECT
    (SELECT COUNT_BIG(*) FROM dw.Fact_Sales WHERE Quantity <= 0 OR UnitPrice < 0 OR Discount NOT BETWEEN 0 AND 1 OR NetRevenue < 0) AS InvalidSalesRows,
    (SELECT COUNT_BIG(*) FROM dw.Fact_Sales AS F LEFT JOIN dw.Dim_Date AS D ON F.DateKey = D.DateKey WHERE D.DateKey IS NULL) AS OrphanDateRows,
    (SELECT COUNT_BIG(*) FROM dw.Fact_Sales AS F LEFT JOIN dw.Dim_Product AS P ON F.ProductKey = P.ProductKey WHERE P.ProductKey IS NULL) AS OrphanProductRows,
    (SELECT COUNT_BIG(*) FROM dw.Fact_Sales AS F LEFT JOIN dw.Dim_Store AS S ON F.StoreKey = S.StoreKey WHERE S.StoreKey IS NULL) AS OrphanStoreRows;
GO
