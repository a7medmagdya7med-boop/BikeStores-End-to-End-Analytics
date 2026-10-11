-- BIKESTORES / PROCEDURE DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [dw].[usp_Production_Quality_Gate].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE
    [dw].[usp_Production_Quality_Gate]
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Invalid fact values
    IF EXISTS (
        SELECT 1
        FROM dw.Fact_Sales
        WHERE Quantity <= 0
           OR UnitPrice < 0
           OR Discount NOT BETWEEN 0 AND 1
           OR NetRevenue < 0
    )
        THROW 50201,
            'DQ FAIL: Invalid sales values.',
            1;

    -- 2. Missing dimension members
    IF EXISTS (
        SELECT 1
        FROM dw.Fact_Sales AS F
        LEFT JOIN dw.Dim_Product AS P
            ON F.ProductKey = P.ProductKey
        LEFT JOIN dw.Dim_Store AS S
            ON F.StoreKey = S.StoreKey
        LEFT JOIN dw.Dim_Date AS D
            ON F.DateKey = D.DateKey
        WHERE P.ProductKey IS NULL
           OR S.StoreKey IS NULL
           OR D.DateKey IS NULL
    )
        THROW 50202,
            'DQ FAIL: Orphan dimension keys.',
            1;

    -- 3. Duplicate order lines
    IF EXISTS (
        SELECT 1
        FROM dw.Fact_Sales
        GROUP BY OrderID, ItemID
        HAVING COUNT_BIG(*) > 1
    )
        THROW 50203,
            'DQ FAIL: Duplicate order lines.',
            1;

    -- 4. Existing reconciliation checks
    EXEC dw.usp_Validate_Capstone;

    SELECT 'PASS' AS QualityGateStatus;
END;
GO
