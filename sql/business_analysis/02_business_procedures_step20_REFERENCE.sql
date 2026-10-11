-- REVIEW-ONLY EXCERPT FROM BikeStores_Business_Analysis_01.sql, original lines 2510-2929.
-- NOT VERIFIED AS STANDALONE EXECUTABLE SQL; DO NOT RUN THIS FILE WITHOUT REVIEW.
-- Topic: SQL programming and reports.
-- Some examples can change data, settings, permissions or backup files.
-- Original source remains untouched in the user-managed private folder.

USE BikeStores;
GO

-- Step 20 - Query 1
-- First Stored Procedure

CREATE OR ALTER PROCEDURE dbo.usp_Total_Sales
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(DISTINCT O.order_id) AS Total_Orders,

        SUM(OI.quantity) AS Units_Sold,

        ROUND(
            SUM(
                OI.quantity * OI.list_price *
                (1 - OI.discount)
            ), 2
        ) AS Total_Revenue

    FROM sales.orders AS O

    INNER JOIN sales.order_items AS OI
        ON O.order_id = OI.order_id

    WHERE O.order_status = 4;
END;
GO

-- Execute Procedure
EXEC dbo.usp_Total_Sales;
-----------------------------------------

USE BikeStores;
GO

-- Step 20 - Query 2
-- Sales Report with Date Parameters

CREATE OR ALTER PROCEDURE dbo.usp_Sales_By_Date
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(DISTINCT O.order_id) AS Total_Orders,

        SUM(OI.quantity) AS Units_Sold,

        ROUND(
            SUM(
                OI.quantity * OI.list_price *
                (1 - OI.discount)
            ), 2
        ) AS Total_Revenue

    FROM sales.orders AS O

    INNER JOIN sales.order_items AS OI
        ON O.order_id = OI.order_id

    WHERE O.order_status = 4

      AND O.order_date >= @StartDate

      AND O.order_date <
          DATEADD(DAY, 1, @EndDate);
END;
GO
-------------------------------------------------------

EXEC dbo.usp_Sales_By_Date
    @StartDate = '2018-01-01',
    @EndDate = '2018-03-31';

    ------------------------------
    
USE BikeStores;
GO

-- Step 20 - Query 3
-- Optional Store Parameter

CREATE OR ALTER PROCEDURE dbo.usp_Store_Sales
    @StartDate DATE,
    @EndDate DATE,
    @StoreID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ST.store_id,
        ST.store_name,

        COUNT(DISTINCT O.order_id) AS Total_Orders,

        SUM(OI.quantity) AS Units_Sold,

        ROUND(
            SUM(
                OI.quantity * OI.list_price *
                (1 - OI.discount)
            ), 2
        ) AS Total_Revenue

    FROM sales.orders AS O

    INNER JOIN sales.order_items AS OI
        ON O.order_id = OI.order_id

    INNER JOIN sales.stores AS ST
        ON O.store_id = ST.store_id

    WHERE O.order_status = 4

      AND O.order_date >= @StartDate

      AND O.order_date <
          DATEADD(DAY, 1, @EndDate)

      AND (
          @StoreID IS NULL
          OR O.store_id = @StoreID
      )

    GROUP BY
        ST.store_id,
        ST.store_name

    ORDER BY Total_Revenue DESC;
END;
GO
-----------------------------------------------------------

EXEC dbo.usp_Store_Sales
    @StartDate = '2018-01-01',
    @EndDate = '2018-12-31';
    ----------------------------------------------

EXEC dbo.usp_Store_Sales
    @StartDate = '2018-01-01',
    @EndDate = '2018-12-31',
    @StoreID = 1;
    ---------------------------------------------------
    
USE BikeStores;
GO

-- Step 20 - Query 4
-- Validate Date Parameters

CREATE OR ALTER PROCEDURE dbo.usp_Validated_Sales
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @StartDate IS NULL
       OR @EndDate IS NULL
    BEGIN
        THROW 50001,
            'StartDate and EndDate are required.',
            1;
    END;

    IF @StartDate > @EndDate
    BEGIN
        THROW 50002,
            'StartDate cannot be after EndDate.',
            1;
    END;

    SELECT
        COUNT(DISTINCT O.order_id) AS Total_Orders,

        COALESCE(
            SUM(
                OI.quantity * OI.list_price *
                (1 - OI.discount)
            ), 0
        ) AS Total_Revenue

    FROM sales.orders AS O

    INNER JOIN sales.order_items AS OI
        ON O.order_id = OI.order_id

    WHERE O.order_status = 4
      AND O.order_date >= @StartDate
      AND O.order_date <
          DATEADD(DAY, 1, @EndDate);
END;
GO
----------------------------------------------------------


-- Valid Parameters

EXEC dbo.usp_Validated_Sales
    @StartDate = '2018-01-01',
    @EndDate = '2018-12-31';

-- Invalid Parameters
-- Run separately to test the error

EXEC dbo.usp_Validated_Sales
    @StartDate = '2018-12-31',
    @EndDate = '2018-01-01';
    --------------------------------------------
    
USE BikeStores;
GO

-- Step 20 - Query 5
-- Monthly Sales Report Procedure

CREATE OR ALTER PROCEDURE dbo.usp_Monthly_Sales_Report
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @StartDate IS NULL
       OR @EndDate IS NULL
       OR @StartDate > @EndDate
    BEGIN
        THROW 50003,
            'Invalid date range.',
            1;
    END;

    ;WITH Monthly_Sales AS (
        SELECT
            DATEFROMPARTS(
                YEAR(O.order_date),
                MONTH(O.order_date),
                1
            ) AS Sales_Month,

            COUNT(DISTINCT O.order_id)
                AS Total_Orders,

            SUM(OI.quantity)
                AS Units_Sold,

            SUM(
                OI.quantity * OI.list_price *
                (1 - OI.discount)
            ) AS Monthly_Revenue

        FROM sales.orders AS O

        INNER JOIN sales.order_items AS OI
            ON O.order_id = OI.order_id

        WHERE O.order_status = 4

          AND O.order_date >= @StartDate

          AND O.order_date <
              DATEADD(DAY, 1, @EndDate)

        GROUP BY
            YEAR(O.order_date),
            MONTH(O.order_date)
    ),

    Monthly_Analytics AS (
        SELECT
            *,

            LAG(Sales_Month) OVER (
                ORDER BY Sales_Month
            ) AS Previous_Sales_Month,

            LAG(Monthly_Revenue) OVER (
                ORDER BY Sales_Month
            ) AS Previous_Revenue

        FROM Monthly_Sales
    )

    SELECT
        Sales_Month,
        Total_Orders,
        Units_Sold,

        ROUND(Monthly_Revenue, 2)
            AS Monthly_Revenue,

        CASE
            WHEN Previous_Sales_Month =
                 DATEADD(MONTH, -1, Sales_Month)
            THEN ROUND(
                100.0 * (
                    Monthly_Revenue -
                    Previous_Revenue
                ) / NULLIF(Previous_Revenue, 0),
                2
            )
            ELSE NULL
        END AS MoM_Growth_Pct

    FROM Monthly_Analytics

    ORDER BY Sales_Month;
END;
GO

--------------------------------------------------

EXEC dbo.usp_Monthly_Sales_Report
    @StartDate = '2018-01-01',
    @EndDate = '2018-12-31';
    -------------------------------------------------
    
USE BikeStores;
GO

-- Step 20 - Query 6
-- Final Dynamic Sales KPI Report

CREATE OR ALTER PROCEDURE dbo.usp_Sales_KPI_Report
    @StartDate DATE,
    @EndDate DATE,
    @StoreID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @StartDate IS NULL
       OR @EndDate IS NULL
       OR @StartDate > @EndDate
    BEGIN
        THROW 50004,
            'Invalid date parameters.',
            1;
    END;

    IF @EndDate = '9999-12-31'
    BEGIN
        THROW 50005,
            'EndDate exceeds supported range.',
            1;
    END;

    SELECT
        COUNT(DISTINCT O.order_id)
            AS Total_Orders,

        COALESCE(SUM(OI.quantity), 0)
            AS Units_Sold,

        ROUND(
            COALESCE(
                SUM(
                    OI.quantity * OI.list_price *
                    (1 - OI.discount)
                ), 0
            ), 2
        ) AS Total_Revenue,

        ROUND(
            COALESCE(
                SUM(
                    OI.quantity * OI.list_price *
                    (1 - OI.discount)
                ) / NULLIF(
                    COUNT(DISTINCT O.order_id), 0
                ), 0
            ), 2
        ) AS Avg_Order_Value

    FROM sales.orders AS O

    INNER JOIN sales.order_items AS OI
        ON O.order_id = OI.order_id

    WHERE O.order_status = 4

      AND O.order_date >= @StartDate

      AND O.order_date <
          DATEADD(DAY, 1, @EndDate)

      AND (
          @StoreID IS NULL
          OR O.store_id = @StoreID
      );
END;
GO
--------------------------------------------------------

-- All Stores
EXEC dbo.usp_Sales_KPI_Report
    @StartDate = '2018-01-01',
    @EndDate = '2018-12-31';

-- Store 1
EXEC dbo.usp_Sales_KPI_Report
    @StartDate = '2018-01-01',
    @EndDate = '2018-12-31',
    @StoreID = 1;

-- Store 2
EXEC dbo.usp_Sales_KPI_Report
    @StartDate = '2018-01-01',
    @EndDate = '2018-12-31',
    @StoreID = 2;
    --------------------------------------------
    
USE BikeStores;
