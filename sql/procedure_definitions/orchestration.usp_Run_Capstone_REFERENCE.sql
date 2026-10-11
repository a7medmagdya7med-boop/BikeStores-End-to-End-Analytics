-- BIKESTORES / PROCEDURE DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [orchestration].[usp_Run_Capstone].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE
    [orchestration].[usp_Run_Capstone]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @RunID BIGINT = NULL,
        @StepID BIGINT = NULL,
        @LockResult INT,
        @LockAcquired BIT = 0,
        @ErrorMessage NVARCHAR(4000);

    BEGIN TRY

        -- Prevent concurrent execution
        EXEC @LockResult = sys.sp_getapplock
            @Resource = 'BikeStores_Capstone',
            @LockMode = 'Exclusive',
            @LockOwner = 'Session',
            @LockTimeout = 0;

        IF @LockResult < 0
            THROW 50105,
                'Capstone pipeline is already running.',
                1;

        SET @LockAcquired = 1;

        INSERT INTO orchestration.Pipeline_Run_Log (
            PipelineName,
            RunStatus
        )
        VALUES (
            'BikeStores_Capstone',
            'RUNNING'
        );

        SET @RunID = SCOPE_IDENTITY();

        -- Step 1: Load warehouse
        INSERT INTO orchestration.Pipeline_Step_Log (
            RunID, StepNumber, StepName, StepStatus
        )
        VALUES (
            @RunID, 1, 'Refresh Fact Sales', 'RUNNING'
        );

        SET @StepID = SCOPE_IDENTITY();

        EXEC dw.usp_Refresh_Fact_Sales;

        UPDATE orchestration.Pipeline_Step_Log
        SET StepStatus = 'SUCCESS',
            EndTime = SYSDATETIME()
        WHERE StepLogID = @StepID;

        -- Step 2: Validate
        INSERT INTO orchestration.Pipeline_Step_Log (
            RunID, StepNumber, StepName, StepStatus
        )
        VALUES (
            @RunID, 2, 'Validate Warehouse', 'RUNNING'
        );

        SET @StepID = SCOPE_IDENTITY();

        EXEC dw.usp_Validate_Capstone;

        UPDATE orchestration.Pipeline_Step_Log
        SET StepStatus = 'SUCCESS',
            EndTime = SYSDATETIME()
        WHERE StepLogID = @StepID;

        -- Finalize
        UPDATE orchestration.Pipeline_Run_Log
        SET RunStatus = 'SUCCESS',
            EndTime = SYSDATETIME()
        WHERE RunID = @RunID;

        EXEC sys.sp_releaseapplock
            @Resource = 'BikeStores_Capstone',
            @LockOwner = 'Session';

        SET @LockAcquired = 0;

        SELECT *
        FROM orchestration.Pipeline_Run_Log
        WHERE RunID = @RunID;

    END TRY
    BEGIN CATCH

        SET @ErrorMessage = ERROR_MESSAGE();

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        IF @StepID IS NOT NULL
        BEGIN
            UPDATE orchestration.Pipeline_Step_Log
            SET StepStatus = 'FAILED',
                EndTime = SYSDATETIME(),
                ErrorMessage = @ErrorMessage
            WHERE StepLogID = @StepID
              AND StepStatus = 'RUNNING';
        END;

        IF @RunID IS NOT NULL
        BEGIN
            UPDATE orchestration.Pipeline_Run_Log
            SET RunStatus = 'FAILED',
                EndTime = SYSDATETIME(),
                ErrorMessage = @ErrorMessage
            WHERE RunID = @RunID;
        END;

        IF @LockAcquired = 1
        BEGIN
            EXEC sys.sp_releaseapplock
                @Resource = 'BikeStores_Capstone',
                @LockOwner = 'Session';
        END;

        THROW;
    END CATCH;
END;
GO
