-- BIKESTORES / PROCEDURE DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [etl].[usp_Load_Fact_Sales].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Step 25 - Query 8
-- Full Refresh ETL Pipeline

CREATE   PROCEDURE [etl].[usp_Load_Fact_Sales]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        -- 1. Refresh Staging
        TRUNCATE TABLE etl.Staging_Sales;

        INSERT INTO etl.Staging_Sales (
            order_id,
            item_id,
            order_date,
            store_id,
            store_name,
            product_id,
            product_name,
            quantity,
            unit_price,
            discount,
            net_revenue
        )
        SELECT
            O.order_id,
            OI.item_id,
            O.order_date,
            O.store_id,
            ST.store_name,
            OI.product_id,
            P.product_name,
            OI.quantity,
            OI.list_price,
            OI.discount,
            CAST(
                OI.quantity * OI.list_price *
                (1 - OI.discount)
                AS DECIMAL(19,4)
            )
        FROM sales.orders AS O
        INNER JOIN sales.order_items AS OI
            ON O.order_id = OI.order_id
        INNER JOIN sales.stores AS ST
            ON O.store_id = ST.store_id
        INNER JOIN production.products AS P
            ON OI.product_id = P.product_id
        WHERE O.order_status = 4;

        -- 2. Validate Staging
        IF EXISTS (
            SELECT 1
            FROM etl.Staging_Sales
            WHERE quantity <= 0
               OR unit_price < 0
               OR discount NOT BETWEEN 0 AND 1
               OR net_revenue < 0
        )
        BEGIN
            THROW 50025,
                'ETL Data Quality Validation Failed.',
                1;
        END;

        -- 3. Refresh Analytics Table
        TRUNCATE TABLE etl.Fact_Sales;

        INSERT INTO etl.Fact_Sales (
            order_id,
            item_id,
            order_date,
            store_id,
            store_name,
            product_id,
            product_name,
            quantity,
            unit_price,
            discount,
            net_revenue
        )
        SELECT
            order_id,
            item_id,
            order_date,
            store_id,
            store_name,
            product_id,
            product_name,
            quantity,
            unit_price,
            discount,
            net_revenue
        FROM etl.Staging_Sales;

        -- 4. Reconcile Row Counts
        IF (
            SELECT COUNT(*)
            FROM etl.Staging_Sales
        ) <> (
            SELECT COUNT(*)
            FROM etl.Fact_Sales
        )
        BEGIN
            THROW 50026,
                'ETL Row Count Reconciliation Failed.',
                1;
        END;

        COMMIT TRANSACTION;

        -- 5. Report Results
        SELECT
            'SUCCESS' AS Pipeline_Status,
            COUNT(*) AS Loaded_Rows,
            ROUND(SUM(net_revenue), 2)
                AS Total_Revenue,
            SYSDATETIME() AS Completed_At
        FROM etl.Fact_Sales;

    END TRY

    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;
END;
GO
