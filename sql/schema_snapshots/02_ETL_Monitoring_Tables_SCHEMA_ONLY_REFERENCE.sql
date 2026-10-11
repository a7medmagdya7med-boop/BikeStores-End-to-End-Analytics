-- BIKESTORES / SCHEMA SNAPSHOT / REVIEW ONLY
-- Extracted from SSMS schema-only exports. User/role statements intentionally excluded.
-- CREATE/ALTER TABLE statements can modify a database. DO NOT EXECUTE on a live database.
-- Requires existing BikeStores database and the respective schemas; no independent deployment test performed.
-- SQL Server Management Studio GO batch separators are used below.

CREATE TABLE [etl].[Fact_Sales](
	[order_id] [int] NOT NULL,
	[item_id] [int] NOT NULL,
	[order_date] [date] NOT NULL,
	[store_id] [int] NOT NULL,
	[store_name] [varchar](255) NULL,
	[product_id] [int] NOT NULL,
	[product_name] [varchar](255) NULL,
	[quantity] [int] NOT NULL,
	[unit_price] [decimal](12, 2) NOT NULL,
	[discount] [decimal](5, 4) NOT NULL,
	[net_revenue] [decimal](19, 4) NOT NULL,
	[last_loaded_at] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_Fact_Sales] PRIMARY KEY CLUSTERED 
(
	[order_id] ASC,
	[item_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [etl].[Incremental_Source_Lab](
	[sale_id] [int] NOT NULL,
	[product_name] [varchar](100) NOT NULL,
	[quantity] [int] NOT NULL,
	[unit_price] [decimal](12, 2) NOT NULL,
	[is_deleted] [bit] NOT NULL,
	[last_modified_at] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[sale_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [etl].[Incremental_Target_Lab](
	[sale_id] [int] NOT NULL,
	[product_name] [varchar](100) NOT NULL,
	[quantity] [int] NOT NULL,
	[unit_price] [decimal](12, 2) NOT NULL,
	[revenue] [decimal](19, 2) NOT NULL,
	[last_modified_at] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[sale_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [etl].[Incremental_Watermark_Lab](
	[pipeline_name] [sysname] NOT NULL,
	[last_watermark] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[pipeline_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [etl].[Staging_Sales](
	[order_id] [int] NOT NULL,
	[item_id] [int] NOT NULL,
	[order_date] [date] NOT NULL,
	[store_id] [int] NOT NULL,
	[store_name] [varchar](255) NULL,
	[product_id] [int] NOT NULL,
	[product_name] [varchar](255) NULL,
	[quantity] [int] NOT NULL,
	[unit_price] [decimal](12, 2) NOT NULL,
	[discount] [decimal](5, 4) NOT NULL,
	[net_revenue] [decimal](19, 4) NOT NULL,
 CONSTRAINT [PK_Staging_Sales] PRIMARY KEY CLUSTERED 
(
	[order_id] ASC,
	[item_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [monitoring].[Data_Quality_Results](
	[CheckID] [bigint] IDENTITY(1,1) NOT NULL,
	[RunID] [bigint] NOT NULL,
	[RuleName] [varchar](150) NOT NULL,
	[CheckStatus] [varchar](10) NOT NULL,
	[FailedRows] [bigint] NOT NULL,
	[CheckedAt] [datetime2](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CheckID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [monitoring].[Pipeline_Run_Log](
	[RunID] [bigint] IDENTITY(1,1) NOT NULL,
	[PipelineName] [sysname] NOT NULL,
	[StartTime] [datetime2](3) NOT NULL,
	[EndTime] [datetime2](3) NULL,
	[RunStatus] [varchar](20) NOT NULL,
	[RowsChecked] [bigint] NULL,
	[ErrorMessage] [nvarchar](4000) NULL,
PRIMARY KEY CLUSTERED 
(
	[RunID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [orchestration].[Pipeline_Run_Log](
	[RunID] [bigint] IDENTITY(1,1) NOT NULL,
	[PipelineName] [sysname] NOT NULL,
	[StartTime] [datetime2](3) NOT NULL,
	[EndTime] [datetime2](3) NULL,
	[RunStatus] [varchar](20) NOT NULL,
	[ErrorMessage] [nvarchar](4000) NULL,
PRIMARY KEY CLUSTERED 
(
	[RunID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [orchestration].[Pipeline_Step_Log](
	[StepLogID] [bigint] IDENTITY(1,1) NOT NULL,
	[RunID] [bigint] NOT NULL,
	[StepNumber] [int] NOT NULL,
	[StepName] [varchar](150) NOT NULL,
	[StartTime] [datetime2](3) NOT NULL,
	[EndTime] [datetime2](3) NULL,
	[StepStatus] [varchar](20) NOT NULL,
	[ErrorMessage] [nvarchar](4000) NULL,
PRIMARY KEY CLUSTERED 
(
	[StepLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [etl].[Fact_Sales] ADD  DEFAULT (sysdatetime()) FOR [last_loaded_at]
GO

ALTER TABLE [etl].[Incremental_Source_Lab] ADD  DEFAULT ((0)) FOR [is_deleted]
GO

ALTER TABLE [monitoring].[Data_Quality_Results] ADD  DEFAULT (sysdatetime()) FOR [CheckedAt]
GO

ALTER TABLE [monitoring].[Pipeline_Run_Log] ADD  DEFAULT (sysdatetime()) FOR [StartTime]
GO

ALTER TABLE [orchestration].[Pipeline_Run_Log] ADD  DEFAULT (sysdatetime()) FOR [StartTime]
GO

ALTER TABLE [orchestration].[Pipeline_Step_Log] ADD  DEFAULT (sysdatetime()) FOR [StartTime]
GO

ALTER TABLE [monitoring].[Data_Quality_Results]  WITH CHECK ADD  CONSTRAINT [FK_DQ_Run] FOREIGN KEY([RunID])
REFERENCES [monitoring].[Pipeline_Run_Log] ([RunID])
GO

ALTER TABLE [monitoring].[Data_Quality_Results] CHECK CONSTRAINT [FK_DQ_Run]
GO

ALTER TABLE [orchestration].[Pipeline_Step_Log]  WITH CHECK ADD  CONSTRAINT [FK_Orch_Step_Run] FOREIGN KEY([RunID])
REFERENCES [orchestration].[Pipeline_Run_Log] ([RunID])
GO

ALTER TABLE [orchestration].[Pipeline_Step_Log] CHECK CONSTRAINT [FK_Orch_Step_Run]
GO

ALTER TABLE [etl].[Incremental_Source_Lab]  WITH CHECK ADD CHECK  (([quantity]>(0)))
GO

ALTER TABLE [etl].[Incremental_Source_Lab]  WITH CHECK ADD CHECK  (([unit_price]>=(0)))
GO

ALTER TABLE [monitoring].[Data_Quality_Results]  WITH CHECK ADD  CONSTRAINT [CK_DQ_Check_Status] CHECK  (([CheckStatus]='FAIL' OR [CheckStatus]='PASS'))
GO

ALTER TABLE [monitoring].[Data_Quality_Results] CHECK CONSTRAINT [CK_DQ_Check_Status]
GO

ALTER TABLE [monitoring].[Pipeline_Run_Log]  WITH CHECK ADD  CONSTRAINT [CK_Pipeline_Run_Status] CHECK  (([RunStatus]='FAILED' OR [RunStatus]='SUCCESS' OR [RunStatus]='RUNNING'))
GO

ALTER TABLE [monitoring].[Pipeline_Run_Log] CHECK CONSTRAINT [CK_Pipeline_Run_Status]
GO

ALTER TABLE [orchestration].[Pipeline_Run_Log]  WITH CHECK ADD  CONSTRAINT [CK_Orch_RunStatus] CHECK  (([RunStatus]='FAILED' OR [RunStatus]='SUCCESS' OR [RunStatus]='RUNNING'))
GO

ALTER TABLE [orchestration].[Pipeline_Run_Log] CHECK CONSTRAINT [CK_Orch_RunStatus]
GO

ALTER TABLE [orchestration].[Pipeline_Step_Log]  WITH CHECK ADD  CONSTRAINT [CK_Orch_StepStatus] CHECK  (([StepStatus]='SKIPPED' OR [StepStatus]='FAILED' OR [StepStatus]='SUCCESS' OR [StepStatus]='RUNNING'))
GO

ALTER TABLE [orchestration].[Pipeline_Step_Log] CHECK CONSTRAINT [CK_Orch_StepStatus]
GO
