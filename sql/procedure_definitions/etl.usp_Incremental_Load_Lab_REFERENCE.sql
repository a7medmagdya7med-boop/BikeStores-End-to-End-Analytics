-- BIKESTORES / PROCEDURE DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [etl].[usp_Incremental_Load_Lab].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Step 26 - Query 4
-- Incremental ETL Procedure

CREATE   PROCEDURE [etl].[usp_Incremental_Load_Lab]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @LastWatermark DATETIME2(7),
        @NewWatermark DATETIME2(7);

    BEGIN TRY

        BEGIN TRANSACTION;

        -- 1. Read watermark and lock control row
        SELECT
            @LastWatermark = last_watermark
        FROM etl.Incremental_Watermark_Lab
            WITH (UPDLOCK, HOLDLOCK)
        WHERE pipeline_name = 'Sales_Incremental_Lab';

        IF @LastWatermark IS NULL
            THROW 50031,
                'Pipeline watermark is missing.',
                1;

        -- 2. Capture changed rows
        SELECT
            sale_id,
            product_name,
            quantity,
            unit_price,
            is_deleted,
            last_modified_at
        INTO #Changes
        FROM etl.Incremental_Source_Lab
        WHERE last_modified_at > @LastWatermark;

        SELECT
            @NewWatermark = MAX(last_modified_at)
        FROM #Changes;

        -- 3. Update existing active records
        UPDATE T
        SET
            T.product_name = S.product_name,
            T.quantity = S.quantity,
            T.unit_price = S.unit_price,
            T.revenue =
                CAST(S.quantity * S.unit_price
                     AS DECIMAL(19,2)),
            T.last_modified_at = S.last_modified_at
        FROM etl.Incremental_Target_Lab AS T
        INNER JOIN #Changes AS S
            ON T.sale_id = S.sale_id
        WHERE S.is_deleted = 0;

        -- 4. Insert new active records
        INSERT INTO etl.Incremental_Target_Lab (
            sale_id,
            product_name,
            quantity,
            unit_price,
            revenue,
            last_modified_at
        )
        SELECT
            S.sale_id,
            S.product_name,
            S.quantity,
            S.unit_price,
            CAST(S.quantity * S.unit_price
                 AS DECIMAL(19,2)),
            S.last_modified_at
        FROM #Changes AS S
        WHERE S.is_deleted = 0
          AND NOT EXISTS (
              SELECT 1
              FROM etl.Incremental_Target_Lab AS T
              WHERE T.sale_id = S.sale_id
          );

        -- 5. Apply soft deletes
        DELETE T
        FROM etl.Incremental_Target_Lab AS T
        INNER JOIN #Changes AS S
            ON T.sale_id = S.sale_id
        WHERE S.is_deleted = 1;

        -- 6. Update watermark after successful load
        IF @NewWatermark IS NOT NULL
        BEGIN
            UPDATE etl.Incremental_Watermark_Lab
            SET last_watermark = @NewWatermark
            WHERE pipeline_name = 'Sales_Incremental_Lab';
        END;

        COMMIT TRANSACTION;

        SELECT
            'SUCCESS' AS Pipeline_Status,
            COUNT(*) AS Target_Rows,
            COALESCE(SUM(revenue), 0)
                AS Total_Revenue
        FROM etl.Incremental_Target_Lab;

    END TRY

    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;
END;
GO
