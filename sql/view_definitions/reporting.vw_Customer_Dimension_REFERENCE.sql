-- BIKESTORES / VIEW DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [reporting].[vw_Customer_Dimension].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [reporting].[vw_Customer_Dimension]
AS
SELECT
    customer_id AS CustomerID,

    CONCAT(
        first_name,
        ' ',
        last_name
    ) AS CustomerName,

    city AS CustomerCity,
    state AS CustomerState,
    zip_code AS ZipCode

FROM sales.customers;
GO
