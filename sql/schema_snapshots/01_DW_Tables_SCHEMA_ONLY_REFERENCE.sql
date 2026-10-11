-- BIKESTORES / SCHEMA SNAPSHOT / REVIEW ONLY
-- Extracted from SSMS schema-only exports. User/role statements intentionally excluded.
-- CREATE/ALTER TABLE statements can modify a database. DO NOT EXECUTE on a live database.
-- Requires existing BikeStores database and the respective schemas; no independent deployment test performed.
-- SQL Server Management Studio GO batch separators are used below.

CREATE TABLE [dw].[Dim_Date](
	[DateKey] [int] NOT NULL,
	[FullDate] [date] NOT NULL,
	[CalendarYear] [int] NOT NULL,
	[CalendarQuarter] [int] NOT NULL,
	[CalendarMonth] [int] NOT NULL,
	[MonthName] [varchar](20) NOT NULL,
	[DayOfMonth] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[FullDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dw].[Dim_Product](
	[ProductKey] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[ProductName] [varchar](255) NOT NULL,
	[BrandName] [varchar](255) NULL,
	[CategoryName] [varchar](255) NULL,
	[ModelYear] [smallint] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dw].[Dim_Store](
	[StoreKey] [int] IDENTITY(1,1) NOT NULL,
	[StoreID] [int] NOT NULL,
	[StoreName] [varchar](255) NOT NULL,
	[City] [varchar](255) NULL,
	[State] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[StoreKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[StoreID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dw].[Fact_Sales](
	[SalesKey] [bigint] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
	[DateKey] [int] NOT NULL,
	[ProductKey] [int] NOT NULL,
	[StoreKey] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](12, 2) NOT NULL,
	[Discount] [decimal](5, 4) NOT NULL,
	[NetRevenue] [decimal](19, 4) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Fact_Sales_OrderItem] UNIQUE NONCLUSTERED 
(
	[OrderID] ASC,
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dw].[Fact_Sales]  WITH CHECK ADD  CONSTRAINT [FK_Fact_Date] FOREIGN KEY([DateKey])
REFERENCES [dw].[Dim_Date] ([DateKey])
GO

ALTER TABLE [dw].[Fact_Sales] CHECK CONSTRAINT [FK_Fact_Date]
GO

ALTER TABLE [dw].[Fact_Sales]  WITH CHECK ADD  CONSTRAINT [FK_Fact_Product] FOREIGN KEY([ProductKey])
REFERENCES [dw].[Dim_Product] ([ProductKey])
GO

ALTER TABLE [dw].[Fact_Sales] CHECK CONSTRAINT [FK_Fact_Product]
GO

ALTER TABLE [dw].[Fact_Sales]  WITH CHECK ADD  CONSTRAINT [FK_Fact_Store] FOREIGN KEY([StoreKey])
REFERENCES [dw].[Dim_Store] ([StoreKey])
GO

ALTER TABLE [dw].[Fact_Sales] CHECK CONSTRAINT [FK_Fact_Store]
GO
