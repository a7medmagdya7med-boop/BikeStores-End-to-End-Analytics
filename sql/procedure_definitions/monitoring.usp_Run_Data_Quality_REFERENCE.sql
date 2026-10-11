-- BIKESTORES / PROCEDURE DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [monitoring].[usp_Run_Data_Quality].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Step 29 - Query 9
-- Automated Data Quality Monitoring

CREATE   PROCEDURE [monitoring].[usp_Run_Data_Quality]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @RunID BIGINT,
        @RowsChecked BIGINT,
        @FailedRows BIGINT,
        @ErrorMessage NVARCHAR(4000);

    BEGIN TRY

        -- 1. Start Run
        INSERT INTO monitoring.Pipeline_Run_Log (
            PipelineName,
            RunStatus
        )
        VALUES (
            'BikeStores_DW_Quality',
            'RUNNING'
        );

        SET @RunID = SCOPE_IDENTITY();

        SELECT
            @RowsChecked = COUNT_BIG(*)
        FROM dw.Fact_Sales;

        -- 2. Check Invalid Quantity
        SELECT
            @FailedRows = COUNT_BIG(*)
        FROM dw.Fact_Sales
        WHERE Quantity <= 0;

        INSERT INTO monitoring.Data_Quality_Results (
            RunID, RuleName, CheckStatus, FailedRows
        )
        VALUES (
            @RunID,
            'Invalid Quantity',
            CASE WHEN @FailedRows = 0
                 THEN 'PASS' ELSE 'FAIL' END,
            @FailedRows
        );

        -- 3. Check Invalid Discount
        SELECT
            @FailedRows = COUNT_BIG(*)
        FROM dw.Fact_Sales
        WHERE Discount NOT BETWEEN 0 AND 1;

        INSERT INTO monitoring.Data_Quality_Results (
            RunID, RuleName, CheckStatus, FailedRows
        )
        VALUES (
            @RunID,
            'Invalid Discount',
            CASE WHEN @FailedRows = 0
                 THEN 'PASS' ELSE 'FAIL' END,
            @FailedRows
        );

        -- 4. Check Missing Product Dimension
        SELECT
            @FailedRows = COUNT_BIG(*)
        FROM dw.Fact_Sales AS F
        LEFT JOIN dw.Dim_Product AS P
            ON F.ProductKey = P.ProductKey
        WHERE P.ProductKey IS NULL;

        INSERT INTO monitoring.Data_Quality_Results (
            RunID, RuleName, CheckStatus, FailedRows
        )
        VALUES (
            @RunID,
            'Missing Product Dimension',
            CASE WHEN @FailedRows = 0
                 THEN 'PASS' ELSE 'FAIL' END,
            @FailedRows
        );

        -- 5. Determine Final Status
        IF EXISTS (
            SELECT 1
            FROM monitoring.Data_Quality_Results
            WHERE RunID = @RunID
              AND CheckStatus = 'FAIL'
        )
        BEGIN
            UPDATE monitoring.Pipeline_Run_Log
            SET
                RunStatus = 'FAILED',
                EndTime = SYSDATETIME(),
                RowsChecked = @RowsChecked,
                ErrorMessage =
                    'One or more data quality rules failed.'
            WHERE RunID = @RunID;
        END
        ELSE
        BEGIN
            UPDATE monitoring.Pipeline_Run_Log
            SET
                RunStatus = 'SUCCESS',
                EndTime = SYSDATETIME(),
                RowsChecked = @RowsChecked
            WHERE RunID = @RunID;
        END;

        -- 6. Return Run Result
        SELECT *
        FROM monitoring.Pipeline_Run_Log
        WHERE RunID = @RunID;

        SELECT *
        FROM monitoring.Data_Quality_Results
        WHERE RunID = @RunID;

    END TRY

    BEGIN CATCH

        SET @ErrorMessage = ERROR_MESSAGE();

        IF @RunID IS NOT NULL
        BEGIN
            UPDATE monitoring.Pipeline_Run_Log
            SET
                RunStatus = 'FAILED',
                EndTime = SYSDATETIME(),
                ErrorMessage = @ErrorMessage
            WHERE RunID = @RunID;
        END;

        THROW;

    END CATCH;
END;
GO
