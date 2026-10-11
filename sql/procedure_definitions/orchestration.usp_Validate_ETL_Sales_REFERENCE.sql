-- BIKESTORES / PROCEDURE DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [orchestration].[usp_Validate_ETL_Sales].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE
    [orchestration].[usp_Validate_ETL_Sales]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @StagingRows BIGINT,
        @FactRows BIGINT,
        @StagingRevenue DECIMAL(38,4),
        @FactRevenue DECIMAL(38,4);

    -- Check invalid values
    IF EXISTS (
        SELECT 1
        FROM etl.Fact_Sales
        WHERE quantity <= 0
           OR unit_price < 0
           OR discount NOT BETWEEN 0 AND 1
           OR net_revenue < 0
    )
    BEGIN
        THROW 50041,
            'Invalid values found in ETL Fact Sales.',
            1;
    END;

    -- Calculate metrics
    SELECT
        @StagingRows = COUNT_BIG(*),
        @StagingRevenue =
            COALESCE(SUM(net_revenue), 0)
    FROM etl.Staging_Sales;

    SELECT
        @FactRows = COUNT_BIG(*),
        @FactRevenue =
            COALESCE(SUM(net_revenue), 0)
    FROM etl.Fact_Sales;

    -- Row count validation
    IF @StagingRows <> @FactRows
    BEGIN
        THROW 50042,
            'Row count reconciliation failed.',
            1;
    END;

    -- Revenue validation
    IF ABS(
        @StagingRevenue - @FactRevenue
    ) > 0.0001
    BEGIN
        THROW 50043,
            'Revenue reconciliation failed.',
            1;
    END;

    SELECT
        'PASS' AS ValidationStatus,
        @FactRows AS ValidatedRows,
        @FactRevenue AS TotalRevenue;
END;
GO
