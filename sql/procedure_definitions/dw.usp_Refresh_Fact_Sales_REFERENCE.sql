-- BIKESTORES / PROCEDURE DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [dw].[usp_Refresh_Fact_Sales].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dw].[usp_Refresh_Fact_Sales]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate dimension coverage
        IF EXISTS (
            SELECT 1
            FROM sales.orders AS O
            INNER JOIN sales.order_items AS OI
                ON O.order_id = OI.order_id
            LEFT JOIN dw.Dim_Date AS D
                ON D.FullDate = O.order_date
            LEFT JOIN dw.Dim_Product AS P
                ON P.ProductID = OI.product_id
            LEFT JOIN dw.Dim_Store AS S
                ON S.StoreID = O.store_id
            WHERE O.order_status = 4
              AND (
                  D.DateKey IS NULL
                  OR P.ProductKey IS NULL
                  OR S.StoreKey IS NULL
              )
        )
        BEGIN
            THROW 50101,
                'Missing dimension members.',
                1;
        END;

        -- Full refresh
        DELETE FROM dw.Fact_Sales;

        INSERT INTO dw.Fact_Sales (
            OrderID,
            ItemID,
            DateKey,
            ProductKey,
            StoreKey,
            Quantity,
            UnitPrice,
            Discount,
            NetRevenue
        )
        SELECT
            O.order_id,
            OI.item_id,
            D.DateKey,
            P.ProductKey,
            S.StoreKey,
            OI.quantity,
            OI.list_price,
            OI.discount,
            CAST(
                OI.quantity *
                OI.list_price *
                (1 - OI.discount)
                AS DECIMAL(19,4)
            )
        FROM sales.orders AS O
        INNER JOIN sales.order_items AS OI
            ON O.order_id = OI.order_id
        INNER JOIN dw.Dim_Date AS D
            ON D.FullDate = O.order_date
        INNER JOIN dw.Dim_Product AS P
            ON P.ProductID = OI.product_id
        INNER JOIN dw.Dim_Store AS S
            ON S.StoreID = O.store_id
        WHERE O.order_status = 4;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
