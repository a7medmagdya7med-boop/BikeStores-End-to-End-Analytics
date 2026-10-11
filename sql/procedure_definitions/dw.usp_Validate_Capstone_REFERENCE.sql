-- BIKESTORES / PROCEDURE DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [dw].[usp_Validate_Capstone].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE
    [dw].[usp_Validate_Capstone]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @SourceRows BIGINT,
        @WarehouseRows BIGINT,
        @SourceRevenue DECIMAL(38,4),
        @WarehouseRevenue DECIMAL(38,4);

    SELECT
        @SourceRows = COUNT_BIG(*),
        @SourceRevenue = COALESCE(
            SUM(
                CAST(
                    OI.quantity *
                    OI.list_price *
                    (1 - OI.discount)
                    AS DECIMAL(19,4)
                )
            ), 0
        )
    FROM sales.orders AS O
    INNER JOIN sales.order_items AS OI
        ON O.order_id = OI.order_id
    WHERE O.order_status = 4;

    SELECT
        @WarehouseRows = COUNT_BIG(*),
        @WarehouseRevenue =
            COALESCE(SUM(NetRevenue), 0)
    FROM dw.Fact_Sales;

    IF @SourceRows <> @WarehouseRows
    BEGIN
        THROW 50102,
            'Source and warehouse row counts differ.',
            1;
    END;

    IF ABS(
        @SourceRevenue - @WarehouseRevenue
    ) > 0.0001
    BEGIN
        THROW 50103,
            'Source and warehouse revenue differ.',
            1;
    END;

    IF EXISTS (
        SELECT 1
        FROM dw.Fact_Sales
        WHERE Quantity <= 0
           OR UnitPrice < 0
           OR Discount NOT BETWEEN 0 AND 1
           OR NetRevenue < 0
    )
    BEGIN
        THROW 50104,
            'Invalid fact values detected.',
            1;
    END;

    SELECT
        'PASS' AS QualityStatus,
        @SourceRows AS ValidatedRows,
        @SourceRevenue AS ValidatedRevenue;
END;
GO
