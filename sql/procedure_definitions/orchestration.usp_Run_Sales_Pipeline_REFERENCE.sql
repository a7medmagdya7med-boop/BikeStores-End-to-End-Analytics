-- BIKESTORES / PROCEDURE DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [orchestration].[usp_Run_Sales_Pipeline].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE
    [orchestration].[usp_Run_Sales_Pipeline]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT OFF;

    DECLARE
        @RunID BIGINT = NULL,
        @StepLogID BIGINT = NULL,
        @LockResult INT,
        @LockAcquired BIT = 0,
        @ErrorMessage NVARCHAR(4000);

    BEGIN TRY

        -- 1. Prevent concurrent pipeline runs
        EXEC @LockResult = sys.sp_getapplock
            @Resource = 'BikeStores_Sales_ETL_Pipeline',
            @LockMode = 'Exclusive',
            @LockOwner = 'Session',
            @LockTimeout = 0;

        IF @LockResult < 0
        BEGIN
            THROW 50051,
                'Pipeline is already running or lock failed.',
                1;
        END;

        SET @LockAcquired = 1;

        -- 2. Start pipeline log
        INSERT INTO orchestration.Pipeline_Run_Log (
            PipelineName,
            RunStatus
        )
        VALUES (
            'BikeStores_Sales_ETL',
            'RUNNING'
        );

        SET @RunID = SCOPE_IDENTITY();

        -- 3. Step 1: Load sales data
        INSERT INTO orchestration.Pipeline_Step_Log (
            RunID,
            StepNumber,
            StepName,
            StepStatus
        )
        VALUES (
            @RunID,
            1,
            'Load ETL Fact Sales',
            'RUNNING'
        );

        SET @StepLogID = SCOPE_IDENTITY();

        EXEC etl.usp_Load_Fact_Sales;

        UPDATE orchestration.Pipeline_Step_Log
        SET
            StepStatus = 'SUCCESS',
            EndTime = SYSDATETIME()
        WHERE StepLogID = @StepLogID;

        -- 4. Step 2: Validate loaded data
        INSERT INTO orchestration.Pipeline_Step_Log (
            RunID,
            StepNumber,
            StepName,
            StepStatus
        )
        VALUES (
            @RunID,
            2,
            'Validate ETL Sales',
            'RUNNING'
        );

        SET @StepLogID = SCOPE_IDENTITY();

        EXEC orchestration.usp_Validate_ETL_Sales;

        UPDATE orchestration.Pipeline_Step_Log
        SET
            StepStatus = 'SUCCESS',
            EndTime = SYSDATETIME()
        WHERE StepLogID = @StepLogID;

        -- 5. Mark pipeline successful
        UPDATE orchestration.Pipeline_Run_Log
        SET
            RunStatus = 'SUCCESS',
            EndTime = SYSDATETIME()
        WHERE RunID = @RunID;

        -- 6. Release lock
        EXEC sys.sp_releaseapplock
            @Resource = 'BikeStores_Sales_ETL_Pipeline',
            @LockOwner = 'Session';

        SET @LockAcquired = 0;

        -- 7. Return results
        SELECT *
        FROM orchestration.Pipeline_Run_Log
        WHERE RunID = @RunID;

        SELECT *
        FROM orchestration.Pipeline_Step_Log
        WHERE RunID = @RunID
        ORDER BY StepNumber;

    END TRY

    BEGIN CATCH

        SET @ErrorMessage = ERROR_MESSAGE();

        -- Roll back any open transaction
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        -- Mark active step as failed
        IF @StepLogID IS NOT NULL
        BEGIN
            UPDATE orchestration.Pipeline_Step_Log
            SET
                StepStatus = 'FAILED',
                EndTime = SYSDATETIME(),
                ErrorMessage = @ErrorMessage
            WHERE StepLogID = @StepLogID
              AND StepStatus = 'RUNNING';
        END;

        -- Mark pipeline as failed
        IF @RunID IS NOT NULL
        BEGIN
            UPDATE orchestration.Pipeline_Run_Log
            SET
                RunStatus = 'FAILED',
                EndTime = SYSDATETIME(),
                ErrorMessage = @ErrorMessage
            WHERE RunID = @RunID;
        END;

        -- Release lock
        IF @LockAcquired = 1
        BEGIN
            EXEC sys.sp_releaseapplock
                @Resource = 'BikeStores_Sales_ETL_Pipeline',
                @LockOwner = 'Session';
        END;

        THROW;

    END CATCH;
END;
GO
