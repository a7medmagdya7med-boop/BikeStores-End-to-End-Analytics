-- Read-only inspection of pipeline run and data quality logs.
USE [BikeStores];
GO
SELECT TOP (25)
    RunID, PipelineName, StartTime, EndTime, RunStatus, ErrorMessage
FROM orchestration.Pipeline_Run_Log
ORDER BY RunID DESC;
GO
SELECT TOP (25)
    RunID, PipelineName, StartTime, EndTime, RunStatus, RowsChecked, ErrorMessage
FROM monitoring.Pipeline_Run_Log
ORDER BY RunID DESC;
GO
SELECT TOP (50)
    RunID, RuleName, CheckStatus, FailedRows, CheckedAt
FROM monitoring.Data_Quality_Results
ORDER BY CheckID DESC;
GO
