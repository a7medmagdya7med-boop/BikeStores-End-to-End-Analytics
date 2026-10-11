-- BIKESTORES / VIEW DEFINITION / REFERENCE ONLY
-- Exported SSMS definition: [reporting].[vw_Product_Dimension].
-- CREATE statements modify database objects; not tested for clean-room execution.
-- Review dependencies and run only against an isolated test database when required.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [reporting].[vw_Product_Dimension]
AS
SELECT
    P.product_id AS ProductID,
    P.product_name AS ProductName,
    P.model_year AS ModelYear,
    P.list_price AS ProductListPrice,

    B.brand_id AS BrandID,
    B.brand_name AS BrandName,

    C.category_id AS CategoryID,
    C.category_name AS CategoryName

FROM production.products AS P

LEFT JOIN production.brands AS B
    ON P.brand_id = B.brand_id

LEFT JOIN production.categories AS C
    ON P.category_id = C.category_id;
GO
