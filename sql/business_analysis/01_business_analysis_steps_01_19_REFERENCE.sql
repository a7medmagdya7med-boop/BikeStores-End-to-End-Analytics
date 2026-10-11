-- REVIEW-ONLY EXCERPT FROM BikeStores_Business_Analysis_01.sql, original lines 1-2509.
-- NOT VERIFIED AS STANDALONE EXECUTABLE SQL; DO NOT RUN THIS FILE WITHOUT REVIEW.
-- Topic: Business analysis, Views, optimization.
-- Some examples can change data, settings, permissions or backup files.
-- Original source remains untouched in the user-managed private folder.

USE BikeStores;
GO
SELECT *
FROM sales.order_items;

SELECT *
FROM sales.orders;

SELECT *
FROM sales.customers;

SELECT *
FROM sales.stores;

SELECT *
FROM sales.staffs;

SELECT *
FROM production.products;

SELECT *
FROM production.brands;

SELECT *
FROM production.categories;

SELECT COUNT(*) AS Original_Order_Lines
FROM sales.order_items;


SELECT
    OI.order_id,
    OI.item_id,
    OI.product_id,
    OI.quantity,
    OI.list_price,
    OI.discount
FROM sales.order_items AS OI;


SELECT
    OI.order_id,
    OI.item_id,
    O.order_status,
    O.order_date,
    O.required_date,
    O.shipped_date,
    OI.product_id,
    OI.quantity,
    OI.list_price,
    OI.discount
FROM sales.order_items AS OI
INNER JOIN sales.orders AS O
    ON OI.order_id = O.order_id;


    SELECT
    OI.order_id,
    OI.item_id,
    O.order_date,
    C.first_name,
    C.last_name,
    C.phone,
    C.email,
    C.street,
    C.city,
    C.state,
    C.zip_code
FROM sales.order_items AS OI
INNER JOIN sales.orders AS O
    ON OI.order_id = O.order_id
LEFT JOIN sales.customers AS C
    ON O.customer_id = C.customer_id;



    
-- Step 7: Orders + Customers + Stores

SELECT
    OI.order_id,
    OI.item_id,
    O.order_date,

    -- Customer Information
    C.first_name AS Customer_First_Name,
    C.last_name AS Customer_Last_Name,
    C.email AS Customer_Email,

    -- Store Information
    ST.store_id,
    ST.store_name,
    ST.city AS Store_City,
    ST.state AS Store_State

FROM sales.order_items AS OI

INNER JOIN sales.orders AS O
    ON OI.order_id = O.order_id

LEFT JOIN sales.customers AS C
    ON O.customer_id = C.customer_id

INNER JOIN sales.stores AS ST
    ON O.store_id = ST.store_id;

    
USE BikeStores;

SELECT TOP 10
    O.order_id,
    O.order_date,
    O.store_id,
    ST.store_name,
    ST.city AS Store_City,
    ST.state AS Store_State
FROM sales.orders AS O
INNER JOIN sales.stores AS ST
    ON O.store_id = ST.store_id
ORDER BY O.order_id;



USE BikeStores;

-- Step 8: Orders + Stores + Staff
SELECT TOP 10
    O.order_id,
    O.order_date,
    O.store_id,
    ST.store_name,
    ST.city AS Store_City,
    ST.state AS Store_State,
    S.staff_id,
    S.first_name AS Staff_First_Name,
    S.last_name AS Staff_Last_Name
FROM sales.orders AS O

-- Step 7: Join stores
INNER JOIN sales.stores AS ST
    ON O.store_id = ST.store_id

-- Step 8: Join staff
INNER JOIN sales.staffs AS S
    ON O.staff_id = S.staff_id

ORDER BY O.order_id;



USE BikeStores;

-- Step 9: Complete Sales Data Query

SELECT TOP 10
    -- Order information
    O.order_id,
    O.order_date,
    O.order_status,

    -- Customer information
    C.first_name AS Customer_First_Name,
    C.last_name AS Customer_Last_Name,

    -- Store information
    ST.store_name,
    ST.city AS Store_City,

    -- Staff information
    S.first_name AS Staff_First_Name,
    S.last_name AS Staff_Last_Name,

    -- Product information
    P.product_name,
    B.brand_name,
    CAT.category_name,

    -- Sales information
    OI.quantity,
    OI.list_price,
    OI.discount,

    -- Revenue after discount
    OI.quantity * OI.list_price *
    (1 - OI.discount) AS Net_Revenue

FROM sales.order_items AS OI

INNER JOIN sales.orders AS O
    ON OI.order_id = O.order_id

LEFT JOIN sales.customers AS C
    ON O.customer_id = C.customer_id

INNER JOIN sales.stores AS ST
    ON O.store_id = ST.store_id

INNER JOIN sales.staffs AS S
    ON O.staff_id = S.staff_id

INNER JOIN production.products AS P
    ON OI.product_id = P.product_id

INNER JOIN production.brands AS B
    ON P.brand_id = B.brand_id

INNER JOIN production.categories AS CAT
    ON P.category_id = CAT.category_id

ORDER BY O.order_id, OI.item_id;




USE BikeStores;

-- Step 10 - Query 1
-- Total Sales by Store

SELECT
    ST.store_name,
    COUNT(DISTINCT O.order_id) AS Total_Orders,
    SUM(OI.quantity) AS Units_Sold,
    ROUND(
        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ), 2
    ) AS Total_Revenue

FROM sales.order_items AS OI

INNER JOIN sales.orders AS O
    ON OI.order_id = O.order_id

INNER JOIN sales.stores AS ST
    ON O.store_id = ST.store_id

GROUP BY ST.store_id, ST.store_name

ORDER BY Total_Revenue DESC;




-- Step 10 - Query 2
-- Top 10 Products by Revenue

SELECT TOP 10
    P.product_name,
    SUM(OI.quantity) AS Units_Sold,
    COUNT(DISTINCT OI.order_id) AS Total_Orders,
    ROUND(
        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ), 2
    ) AS Total_Revenue

FROM sales.order_items AS OI

INNER JOIN production.products AS P
    ON OI.product_id = P.product_id

GROUP BY P.product_id, P.product_name

ORDER BY Total_Revenue DESC;





-- Step 10 - Query 3
-- Revenue by Product Category

SELECT
    CAT.category_name,
    SUM(OI.quantity) AS Units_Sold,
    ROUND(
        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ), 2
    ) AS Total_Revenue

FROM sales.order_items AS OI

INNER JOIN production.products AS P
    ON OI.product_id = P.product_id

INNER JOIN production.categories AS CAT
    ON P.category_id = CAT.category_id

GROUP BY CAT.category_id, CAT.category_name

ORDER BY Total_Revenue DESC;




-- Step 10 - Query 4
-- Sales by Brand

SELECT
    B.brand_name,
    SUM(OI.quantity) AS Units_Sold,
    ROUND(
        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ), 2
    ) AS Total_Revenue

FROM sales.order_items AS OI

INNER JOIN production.products AS P
    ON OI.product_id = P.product_id

INNER JOIN production.brands AS B
    ON P.brand_id = B.brand_id

GROUP BY B.brand_id, B.brand_name

ORDER BY Total_Revenue DESC;

------------

USE BikeStores;

-- Step 11 - Query 1
-- Stores with revenue > 1,000,000

SELECT
    ST.store_name,
    COUNT(DISTINCT O.order_id) AS Total_Orders,
    SUM(OI.quantity) AS Units_Sold,
    ROUND(
        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ), 2
    ) AS Total_Revenue

FROM sales.order_items AS OI

INNER JOIN sales.orders AS O
    ON OI.order_id = O.order_id

INNER JOIN sales.stores AS ST
    ON O.store_id = ST.store_id

GROUP BY ST.store_id, ST.store_name

HAVING SUM(
    OI.quantity * OI.list_price *
    (1 - OI.discount)
) > 1000000

ORDER BY Total_Revenue DESC;

----------------------------------


-- Step 11 - Query 2
-- Products with more than 100 units sold

SELECT
    P.product_name,
    SUM(OI.quantity) AS Units_Sold,
    COUNT(DISTINCT OI.order_id) AS Total_Orders,
    ROUND(
        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ), 2
    ) AS Total_Revenue

FROM sales.order_items AS OI

INNER JOIN production.products AS P
    ON OI.product_id = P.product_id

GROUP BY P.product_id, P.product_name

HAVING SUM(OI.quantity) > 100

ORDER BY Units_Sold DESC;
------------------------------------------

-- Step 11 - Query 3
-- High-revenue brands

SELECT
    B.brand_name,
    SUM(OI.quantity) AS Units_Sold,
    ROUND(
        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ), 2
    ) AS Total_Revenue

FROM sales.order_items AS OI

INNER JOIN production.products AS P
    ON OI.product_id = P.product_id

INNER JOIN production.brands AS B
    ON P.brand_id = B.brand_id

GROUP BY B.brand_id, B.brand_name

HAVING SUM(
    OI.quantity * OI.list_price *
    (1 - OI.discount)
) > 500000

ORDER BY Total_Revenue DESC;

---------------------------------------------

-- Step 11 - Query 4
-- Categories with high average order-line value

SELECT
    CAT.category_name,
    COUNT(*) AS Order_Lines,
    ROUND(
        AVG(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ), 2
    ) AS Avg_Order_Line_Value

FROM sales.order_items AS OI

INNER JOIN production.products AS P
    ON OI.product_id = P.product_id

INNER JOIN production.categories AS CAT
    ON P.category_id = CAT.category_id

GROUP BY CAT.category_id, CAT.category_name

HAVING AVG(
    OI.quantity * OI.list_price *
    (1 - OI.discount)
) > 1000

ORDER BY Avg_Order_Line_Value DESC;

--------------------------------------------------

-- WHERE + GROUP BY + HAVING

SELECT
    ST.store_name,
    SUM(
        OI.quantity * OI.list_price *
        (1 - OI.discount)
    ) AS Total_Revenue

FROM sales.order_items AS OI

INNER JOIN sales.orders AS O
    ON OI.order_id = O.order_id

INNER JOIN sales.stores AS ST
    ON O.store_id = ST.store_id

WHERE O.order_date >= '2018-01-01'
  AND O.order_date < '2019-01-01'

GROUP BY ST.store_id, ST.store_name

HAVING SUM(
    OI.quantity * OI.list_price *
    (1 - OI.discount)
) > 500000

ORDER BY Total_Revenue DESC;

-----------------------------------------

USE BikeStores;
GO

-- Step 12 - Query 1
-- Basic CTE

;WITH Sales_CTE AS (
    SELECT
        order_id,
        item_id,
        product_id,
        quantity,
        list_price,
        discount,
        quantity * list_price *
        (1 - discount) AS Net_Revenue
    FROM sales.order_items
)

SELECT *
FROM Sales_CTE;

-------------------------------------------

-- Step 12 - Query 2
-- Revenue by Store using CTE

;WITH Sales_CTE AS (
    SELECT
        O.order_id,
        ST.store_id,
        ST.store_name,
        OI.quantity,
        OI.quantity * OI.list_price *
        (1 - OI.discount) AS Net_Revenue

    FROM sales.order_items AS OI

    INNER JOIN sales.orders AS O
        ON OI.order_id = O.order_id

    INNER JOIN sales.stores AS ST
        ON O.store_id = ST.store_id
)

SELECT
    store_name,
    COUNT(DISTINCT order_id) AS Total_Orders,
    SUM(quantity) AS Units_Sold,
    ROUND(SUM(Net_Revenue), 2) AS Total_Revenue

FROM Sales_CTE

GROUP BY store_id, store_name

ORDER BY Total_Revenue DESC;

------------------------------------------

-- Step 12 - Query 3
-- High Revenue Stores

;WITH Store_Sales AS (
    SELECT
        ST.store_id,
        ST.store_name,
        OI.quantity * OI.list_price *
        (1 - OI.discount) AS Net_Revenue

    FROM sales.order_items AS OI

    INNER JOIN sales.orders AS O
        ON OI.order_id = O.order_id

    INNER JOIN sales.stores AS ST
        ON O.store_id = ST.store_id
)

SELECT
    store_name,
    ROUND(SUM(Net_Revenue), 2) AS Total_Revenue

FROM Store_Sales

GROUP BY store_id, store_name

HAVING SUM(Net_Revenue) > 1000000

ORDER BY Total_Revenue DESC;

-----------------------------------------

-- Step 12 - Query 4
-- Multiple CTEs

;WITH Sales_Data AS (
    SELECT
        O.store_id,
        OI.order_id,
        OI.quantity,
        OI.quantity * OI.list_price *
        (1 - OI.discount) AS Net_Revenue

    FROM sales.order_items AS OI

    INNER JOIN sales.orders AS O
        ON OI.order_id = O.order_id
),

Store_Summary AS (
    SELECT
        store_id,
        COUNT(DISTINCT order_id) AS Total_Orders,
        SUM(quantity) AS Units_Sold,
        SUM(Net_Revenue) AS Total_Revenue

    FROM Sales_Data

    GROUP BY store_id
)

SELECT
    ST.store_name,
    SS.Total_Orders,
    SS.Units_Sold,
    ROUND(SS.Total_Revenue, 2) AS Total_Revenue

FROM Store_Summary AS SS

INNER JOIN sales.stores AS ST
    ON SS.store_id = ST.store_id

ORDER BY Total_Revenue DESC;
--------------------------------------------

USE BikeStores;

-- Step 13 - Query 1
-- Rank Stores by Revenue

;WITH Store_Sales AS (
    SELECT
        ST.store_id,
        ST.store_name,
        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Total_Revenue

    FROM sales.order_items AS OI

    INNER JOIN sales.orders AS O
        ON OI.order_id = O.order_id

    INNER JOIN sales.stores AS ST
        ON O.store_id = ST.store_id

    GROUP BY ST.store_id, ST.store_name
)

SELECT
    store_name,
    ROUND(Total_Revenue, 2) AS Total_Revenue,

    RANK() OVER (
        ORDER BY Total_Revenue DESC
    ) AS Revenue_Rank

FROM Store_Sales

ORDER BY Revenue_Rank, store_name;

----------------------------------------------

-- Step 13 - Query 2
-- Compare Ranking Functions

;WITH Product_Sales AS (
    SELECT
        P.product_id,
        P.product_name,
        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Total_Revenue

    FROM sales.order_items AS OI

    INNER JOIN production.products AS P
        ON OI.product_id = P.product_id

    GROUP BY P.product_id, P.product_name
)

SELECT
    product_name,
    ROUND(Total_Revenue, 2) AS Total_Revenue,

    ROW_NUMBER() OVER (
        ORDER BY Total_Revenue DESC, product_id
    ) AS Row_Num,

    RANK() OVER (
        ORDER BY Total_Revenue DESC
    ) AS Revenue_Rank,

    DENSE_RANK() OVER (
        ORDER BY Total_Revenue DESC
    ) AS Dense_Revenue_Rank

FROM Product_Sales

ORDER BY Total_Revenue DESC, product_id;
------------------------------------------------------------

-- Step 13 - Query 3
-- Top 3 Products per Category

;WITH Product_Sales AS (
    SELECT
        CAT.category_id,
        CAT.category_name,
        P.product_id,
        P.product_name,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Total_Revenue

    FROM sales.order_items AS OI

    INNER JOIN production.products AS P
        ON OI.product_id = P.product_id

    INNER JOIN production.categories AS CAT
        ON P.category_id = CAT.category_id

    GROUP BY
        CAT.category_id,
        CAT.category_name,
        P.product_id,
        P.product_name
),

Ranked_Products AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY category_id
            ORDER BY Total_Revenue DESC, product_id
        ) AS Product_Rank

    FROM Product_Sales
)

SELECT
    category_name,
    product_name,
    ROUND(Total_Revenue, 2) AS Total_Revenue,
    Product_Rank

FROM Ranked_Products

WHERE Product_Rank <= 3

ORDER BY category_name, Product_Rank;


------------------------------------------------

-- Step 13 - Query 4
-- Monthly Revenue and Running Total

;WITH Monthly_Sales AS (
    SELECT
        DATEFROMPARTS(
            YEAR(O.order_date),
            MONTH(O.order_date),
            1
        ) AS Sales_Month,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Monthly_Revenue

    FROM sales.order_items AS OI

    INNER JOIN sales.orders AS O
        ON OI.order_id = O.order_id

    GROUP BY
        YEAR(O.order_date),
        MONTH(O.order_date)
)

SELECT
    Sales_Month,

    ROUND(Monthly_Revenue, 2) AS Monthly_Revenue,

    ROUND(
        SUM(Monthly_Revenue) OVER (
            ORDER BY Sales_Month
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ), 2
    ) AS Running_Total

FROM Monthly_Sales

ORDER BY Sales_Month;

-------------------------------------------------

-- Step 13 - Query 5
-- Monthly Revenue Growth

;WITH Monthly_Sales AS (
    SELECT
        DATEFROMPARTS(
            YEAR(O.order_date),
            MONTH(O.order_date),
            1
        ) AS Sales_Month,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Monthly_Revenue

    FROM sales.order_items AS OI

    INNER JOIN sales.orders AS O
        ON OI.order_id = O.order_id

    GROUP BY
        YEAR(O.order_date),
        MONTH(O.order_date)
),

Revenue_Comparison AS (
    SELECT
        Sales_Month,
        Monthly_Revenue,

        LAG(Monthly_Revenue) OVER (
            ORDER BY Sales_Month
        ) AS Previous_Month_Revenue

    FROM Monthly_Sales
)

SELECT
    Sales_Month,
    ROUND(Monthly_Revenue, 2) AS Monthly_Revenue,

    ROUND(
        Previous_Month_Revenue, 2
    ) AS Previous_Month_Revenue,

    ROUND(
        100.0 * (
            Monthly_Revenue - Previous_Month_Revenue
        ) / NULLIF(Previous_Month_Revenue, 0),
        2
    ) AS MoM_Growth_Percent

FROM Revenue_Comparison

ORDER BY Sales_Month;
----------------------------------------------------

USE BikeStores;

-- Step 14 - Query 1
-- Product Revenue Contribution %

;WITH Product_Sales AS (
    SELECT
        CAT.category_id,
        CAT.category_name,
        P.product_id,
        P.product_name,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Product_Revenue

    FROM sales.order_items AS OI

    INNER JOIN production.products AS P
        ON OI.product_id = P.product_id

    INNER JOIN production.categories AS CAT
        ON P.category_id = CAT.category_id

    GROUP BY
        CAT.category_id,
        CAT.category_name,
        P.product_id,
        P.product_name
)

SELECT
    category_name,
    product_name,

    ROUND(Product_Revenue, 2)
        AS Product_Revenue,

    ROUND(
        SUM(Product_Revenue) OVER (
            PARTITION BY category_id
        ), 2
    ) AS Category_Revenue,

    ROUND(
        100.0 * Product_Revenue /
        NULLIF(
            SUM(Product_Revenue) OVER (
                PARTITION BY category_id
            ), 0
        ), 2
    ) AS Revenue_Contribution_Pct

FROM Product_Sales

ORDER BY
    category_name,
    Revenue_Contribution_Pct DESC;
    --------------------------------------------------
    
-- Step 14 - Query 2
-- Product Revenue Segmentation

;WITH Product_Sales AS (
    SELECT
        P.product_id,
        P.product_name,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Total_Revenue

    FROM sales.order_items AS OI

    INNER JOIN production.products AS P
        ON OI.product_id = P.product_id

    GROUP BY P.product_id, P.product_name
)

SELECT
    product_name,
    ROUND(Total_Revenue, 2) AS Total_Revenue,

    NTILE(4) OVER (
        ORDER BY Total_Revenue DESC, product_id
    ) AS Revenue_Quartile

FROM Product_Sales

ORDER BY Revenue_Quartile,
         Total_Revenue DESC;
----------------------------------------------------

-- Step 14 - Query 3
-- Top 5 Revenue Ranks per Category

;WITH Product_Sales AS (
    SELECT
        CAT.category_id,
        CAT.category_name,
        P.product_id,
        P.product_name,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Total_Revenue

    FROM sales.order_items AS OI

    INNER JOIN production.products AS P
        ON OI.product_id = P.product_id

    INNER JOIN production.categories AS CAT
        ON P.category_id = CAT.category_id

    GROUP BY
        CAT.category_id,
        CAT.category_name,
        P.product_id,
        P.product_name
),

Ranked_Products AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY category_id
            ORDER BY Total_Revenue DESC
        ) AS Revenue_Rank

    FROM Product_Sales
)

SELECT
    category_name,
    product_name,
    ROUND(Total_Revenue, 2) AS Total_Revenue,
    Revenue_Rank

FROM Ranked_Products

WHERE Revenue_Rank <= 5

ORDER BY category_name,
         Revenue_Rank,
         product_name;

-----------------------------------------------

-- Step 14 - Query 4
-- Product Management Performance Report

;WITH Product_Sales AS (
    SELECT
        CAT.category_id,
        CAT.category_name,
        P.product_id,
        P.product_name,

        SUM(OI.quantity) AS Units_Sold,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Total_Revenue

    FROM sales.order_items AS OI

    INNER JOIN production.products AS P
        ON OI.product_id = P.product_id

    INNER JOIN production.categories AS CAT
        ON P.category_id = CAT.category_id

    GROUP BY
        CAT.category_id,
        CAT.category_name,
        P.product_id,
        P.product_name
),

Product_Analytics AS (
    SELECT
        *,

        SUM(Total_Revenue) OVER (
            PARTITION BY category_id
        ) AS Category_Revenue,

        DENSE_RANK() OVER (
            PARTITION BY category_id
            ORDER BY Total_Revenue DESC
        ) AS Category_Rank,

        NTILE(4) OVER (
            PARTITION BY category_id
            ORDER BY Total_Revenue DESC, product_id
        ) AS Category_Quartile

    FROM Product_Sales
)

SELECT
    category_name,
    product_name,
    Units_Sold,

    ROUND(Total_Revenue, 2)
        AS Total_Revenue,

    ROUND(Category_Revenue, 2)
        AS Category_Revenue,

    ROUND(
        100.0 * Total_Revenue /
        NULLIF(Category_Revenue, 0),
        2
    ) AS Contribution_Pct,

    Category_Rank,
    Category_Quartile

FROM Product_Analytics

ORDER BY
    category_name,
    Category_Rank,
    product_name;
    ---------------------------

    
USE BikeStores;

-- Step 15 - Query 1
-- Customer Lifetime Revenue

SELECT
    C.customer_id,
    C.first_name,
    C.last_name,

    COUNT(DISTINCT O.order_id) AS Total_Orders,

    SUM(OI.quantity) AS Units_Purchased,

    ROUND(
        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ), 2
    ) AS Lifetime_Revenue

FROM sales.customers AS C

INNER JOIN sales.orders AS O
    ON C.customer_id = O.customer_id

INNER JOIN sales.order_items AS OI
    ON O.order_id = OI.order_id

WHERE O.order_status = 4

GROUP BY
    C.customer_id,
    C.first_name,
    C.last_name

ORDER BY Lifetime_Revenue DESC;

---------------------------------------------------

-- Step 15 - Query 2
-- Customer Ranking

;WITH Customer_Sales AS (
    SELECT
        C.customer_id,
        C.first_name,
        C.last_name,

        COUNT(DISTINCT O.order_id) AS Total_Orders,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Lifetime_Revenue

    FROM sales.customers AS C

    INNER JOIN sales.orders AS O
        ON C.customer_id = O.customer_id

    INNER JOIN sales.order_items AS OI
        ON O.order_id = OI.order_id

    WHERE O.order_status = 4

    GROUP BY
        C.customer_id,
        C.first_name,
        C.last_name
)

SELECT
    customer_id,
    first_name,
    last_name,
    Total_Orders,

    ROUND(Lifetime_Revenue, 2)
        AS Lifetime_Revenue,

    DENSE_RANK() OVER (
        ORDER BY Lifetime_Revenue DESC
    ) AS Customer_Rank

FROM Customer_Sales

ORDER BY Customer_Rank, customer_id;
---------------------------------------------------

-- Step 15 - Query 3
-- Repeat Purchase Rate

;WITH Customer_Orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS Total_Orders

    FROM sales.orders

    WHERE order_status = 4

    GROUP BY customer_id
)

SELECT
    COUNT(*) AS Purchasing_Customers,

    SUM(
        CASE
            WHEN Total_Orders > 1 THEN 1
            ELSE 0
        END
    ) AS Repeat_Customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Total_Orders > 1 THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS Repeat_Purchase_Rate_Pct

FROM Customer_Orders;
---------------------------------------------------

-- Step 15 - Query 4
-- RFM Customer Analysis

;WITH Customer_RFM AS (
    SELECT
        C.customer_id,
        C.first_name,
        C.last_name,

        MAX(O.order_date) AS Last_Order_Date,

        COUNT(DISTINCT O.order_id)
            AS Frequency,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Monetary

    FROM sales.customers AS C

    INNER JOIN sales.orders AS O
        ON C.customer_id = O.customer_id

    INNER JOIN sales.order_items AS OI
        ON O.order_id = OI.order_id

    WHERE O.order_status = 4

    GROUP BY
        C.customer_id,
        C.first_name,
        C.last_name
),

Reference_Date AS (
    SELECT
        DATEADD(
            DAY, 1, MAX(Last_Order_Date)
        ) AS Analysis_Date
    FROM Customer_RFM
)

SELECT
    R.customer_id,
    R.first_name,
    R.last_name,
    R.Last_Order_Date,

    DATEDIFF(
        DAY,
        R.Last_Order_Date,
        D.Analysis_Date
    ) AS Recency_Days,

    R.Frequency,

    ROUND(R.Monetary, 2) AS Monetary

FROM Customer_RFM AS R

CROSS JOIN Reference_Date AS D

ORDER BY Monetary DESC;
-------------------------------------------------

-- Step 15 - Query 5
-- RFM Scoring

;WITH Customer_RFM AS (
    SELECT
        C.customer_id,
        C.first_name,
        C.last_name,

        MAX(O.order_date) AS Last_Order_Date,

        COUNT(DISTINCT O.order_id)
            AS Frequency,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Monetary

    FROM sales.customers AS C

    INNER JOIN sales.orders AS O
        ON C.customer_id = O.customer_id

    INNER JOIN sales.order_items AS OI
        ON O.order_id = OI.order_id

    WHERE O.order_status = 4

    GROUP BY
        C.customer_id,
        C.first_name,
        C.last_name
),

RFM_Scores AS (
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY Last_Order_Date ASC,
                     customer_id
        ) AS R_Score,

        NTILE(5) OVER (
            ORDER BY Frequency ASC,
                     customer_id
        ) AS F_Score,

        NTILE(5) OVER (
            ORDER BY Monetary ASC,
                     customer_id
        ) AS M_Score

    FROM Customer_RFM
)

SELECT
    customer_id,
    first_name,
    last_name,
    Last_Order_Date,
    Frequency,
    ROUND(Monetary, 2) AS Monetary,

    R_Score,
    F_Score,
    M_Score,

    CONCAT(
        R_Score, F_Score, M_Score
    ) AS RFM_Segment

FROM RFM_Scores

ORDER BY
    M_Score DESC,
    F_Score DESC,
    R_Score DESC,
    customer_id;
    ---------------------------------------------
    
-- Step 15 - Query 6
-- Customer Segmentation

;WITH Customer_RFM AS (
    SELECT
        C.customer_id,
        C.first_name,
        C.last_name,
        MAX(O.order_date) AS Last_Order_Date,
        COUNT(DISTINCT O.order_id) AS Frequency,
        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Monetary

    FROM sales.customers AS C

    INNER JOIN sales.orders AS O
        ON C.customer_id = O.customer_id

    INNER JOIN sales.order_items AS OI
        ON O.order_id = OI.order_id

    WHERE O.order_status = 4

    GROUP BY
        C.customer_id,
        C.first_name,
        C.last_name
),

RFM_Scores AS (
    SELECT
        *,
        NTILE(5) OVER (
            ORDER BY Last_Order_Date ASC,
                     customer_id
        ) AS R_Score,

        NTILE(5) OVER (
            ORDER BY Frequency ASC,
                     customer_id
        ) AS F_Score,

        NTILE(5) OVER (
            ORDER BY Monetary ASC,
                     customer_id
        ) AS M_Score

    FROM Customer_RFM
)

SELECT
    customer_id,
    first_name,
    last_name,
    Frequency,
    ROUND(Monetary, 2) AS Monetary,
    R_Score,
    F_Score,
    M_Score,

    CASE
        WHEN R_Score >= 4
         AND F_Score >= 4
         AND M_Score >= 4
            THEN 'Champions'

        WHEN R_Score >= 4
         AND F_Score >= 3
            THEN 'Loyal Active'

        WHEN R_Score <= 2
         AND M_Score >= 4
            THEN 'At Risk High Value'

        WHEN R_Score >= 4
         AND F_Score <= 2
            THEN 'Recent Low Frequency'

        ELSE 'Other Customers'
    END AS Customer_Segment

FROM RFM_Scores

ORDER BY Monetary DESC, customer_id;
------------------------------------------------------

USE BikeStores;

-- Step 16 - Query 1
-- Monthly Sales Revenue

SELECT
    YEAR(O.order_date) AS Sales_Year,
    MONTH(O.order_date) AS Sales_Month,

    COUNT(DISTINCT O.order_id) AS Total_Orders,

    SUM(OI.quantity) AS Units_Sold,

    ROUND(
        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ), 2
    ) AS Monthly_Revenue

FROM sales.orders AS O

INNER JOIN sales.order_items AS OI
    ON O.order_id = OI.order_id

WHERE O.order_status = 4

GROUP BY
    YEAR(O.order_date),
    MONTH(O.order_date)

ORDER BY
    Sales_Year,
    Sales_Month;
    ----------------------------------------------------
    
-- Step 16 - Query 2
-- Month-over-Month Growth

;WITH Monthly_Sales AS (
    SELECT
        DATEFROMPARTS(
            YEAR(O.order_date),
            MONTH(O.order_date),
            1
        ) AS Sales_Month,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Monthly_Revenue

    FROM sales.orders AS O

    INNER JOIN sales.order_items AS OI
        ON O.order_id = OI.order_id

    WHERE O.order_status = 4

    GROUP BY
        YEAR(O.order_date),
        MONTH(O.order_date)
),

Sales_Comparison AS (
    SELECT
        Sales_Month,
        Monthly_Revenue,

        LAG(Monthly_Revenue) OVER (
            ORDER BY Sales_Month
        ) AS Previous_Month_Revenue,

        LAG(Sales_Month) OVER (
            ORDER BY Sales_Month
        ) AS Previous_Sales_Month

    FROM Monthly_Sales
)

SELECT
    Sales_Month,

    ROUND(Monthly_Revenue, 2)
        AS Monthly_Revenue,

    ROUND(Previous_Month_Revenue, 2)
        AS Previous_Month_Revenue,

    CASE
        WHEN Previous_Sales_Month =
             DATEADD(MONTH, -1, Sales_Month)
        THEN ROUND(
            100.0 * (
                Monthly_Revenue -
                Previous_Month_Revenue
            ) / NULLIF(Previous_Month_Revenue, 0),
            2
        )
        ELSE NULL
    END AS MoM_Growth_Pct

FROM Sales_Comparison

ORDER BY Sales_Month;
------------------------------------------

-- Step 16 - Query 3
-- Year-over-Year Revenue Growth

;WITH Yearly_Sales AS (
    SELECT
        YEAR(O.order_date) AS Sales_Year,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Annual_Revenue

    FROM sales.orders AS O

    INNER JOIN sales.order_items AS OI
        ON O.order_id = OI.order_id

    WHERE O.order_status = 4

    GROUP BY YEAR(O.order_date)
),

Yearly_Comparison AS (
    SELECT
        Sales_Year,
        Annual_Revenue,

        LAG(Sales_Year) OVER (
            ORDER BY Sales_Year
        ) AS Previous_Year,

        LAG(Annual_Revenue) OVER (
            ORDER BY Sales_Year
        ) AS Previous_Year_Revenue

    FROM Yearly_Sales
)

SELECT
    Sales_Year,

    ROUND(Annual_Revenue, 2)
        AS Annual_Revenue,

    ROUND(Previous_Year_Revenue, 2)
        AS Previous_Year_Revenue,

    CASE
        WHEN Previous_Year = Sales_Year - 1
        THEN ROUND(
            100.0 * (
                Annual_Revenue -
                Previous_Year_Revenue
            ) / NULLIF(Previous_Year_Revenue, 0),
            2
        )
        ELSE NULL
    END AS YoY_Growth_Pct

FROM Yearly_Comparison

ORDER BY Sales_Year;

---------------------------------------------------

-- Step 16 - Query 4
-- Running Total Revenue

;WITH Monthly_Sales AS (
    SELECT
        DATEFROMPARTS(
            YEAR(O.order_date),
            MONTH(O.order_date),
            1
        ) AS Sales_Month,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Monthly_Revenue

    FROM sales.orders AS O

    INNER JOIN sales.order_items AS OI
        ON O.order_id = OI.order_id

    WHERE O.order_status = 4

    GROUP BY
        YEAR(O.order_date),
        MONTH(O.order_date)
)

SELECT
    Sales_Month,

    ROUND(Monthly_Revenue, 2)
        AS Monthly_Revenue,

    ROUND(
        SUM(Monthly_Revenue) OVER (
            ORDER BY Sales_Month
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ), 2
    ) AS Running_Total_Revenue

FROM Monthly_Sales

ORDER BY Sales_Month;
---------------------------------------

-- Step 16 - Query 5
-- Sales Seasonality

;WITH Monthly_Sales AS (
    SELECT
        YEAR(O.order_date) AS Sales_Year,
        MONTH(O.order_date) AS Sales_Month,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Monthly_Revenue

    FROM sales.orders AS O

    INNER JOIN sales.order_items AS OI
        ON O.order_id = OI.order_id

    WHERE O.order_status = 4

    GROUP BY
        YEAR(O.order_date),
        MONTH(O.order_date)
)

SELECT
    Sales_Month,
    DATENAME(
        MONTH,
        DATEFROMPARTS(2000, Sales_Month, 1)
    ) AS Month_Name,

    COUNT(*) AS Years_Observed,

    ROUND(
        AVG(Monthly_Revenue), 2
    ) AS Avg_Monthly_Revenue,

    ROUND(
        SUM(Monthly_Revenue), 2
    ) AS Total_Revenue

FROM Monthly_Sales

GROUP BY Sales_Month

ORDER BY Avg_Monthly_Revenue DESC;
-------------------------------------------

-- Step 16 - Query 6
-- Monthly Sales Performance Dataset

;WITH Monthly_Sales AS (
    SELECT
        DATEFROMPARTS(
            YEAR(O.order_date),
            MONTH(O.order_date),
            1
        ) AS Sales_Month,

        COUNT(DISTINCT O.order_id)
            AS Total_Orders,

        SUM(OI.quantity)
            AS Units_Sold,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Monthly_Revenue

    FROM sales.orders AS O

    INNER JOIN sales.order_items AS OI
        ON O.order_id = OI.order_id

    WHERE O.order_status = 4

    GROUP BY
        YEAR(O.order_date),
        MONTH(O.order_date)
),

Sales_Analytics AS (
    SELECT
        Sales_Month,
        Total_Orders,
        Units_Sold,
        Monthly_Revenue,

        LAG(Sales_Month) OVER (
            ORDER BY Sales_Month
        ) AS Previous_Sales_Month,

        LAG(Monthly_Revenue) OVER (
            ORDER BY Sales_Month
        ) AS Previous_Month_Revenue,

        SUM(Monthly_Revenue) OVER (
            ORDER BY Sales_Month
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS Running_Total_Revenue

    FROM Monthly_Sales
)

SELECT
    Sales_Month,
    YEAR(Sales_Month) AS Sales_Year,
    MONTH(Sales_Month) AS Month_Number,

    Total_Orders,
    Units_Sold,

    ROUND(Monthly_Revenue, 2)
        AS Monthly_Revenue,

    ROUND(
        Monthly_Revenue /
        NULLIF(Total_Orders, 0), 2
    ) AS Avg_Order_Value,

    ROUND(Running_Total_Revenue, 2)
        AS Running_Total_Revenue,

    CASE
        WHEN Previous_Sales_Month =
             DATEADD(MONTH, -1, Sales_Month)
        THEN ROUND(
            100.0 * (
                Monthly_Revenue -
                Previous_Month_Revenue
            ) / NULLIF(Previous_Month_Revenue, 0),
            2
        )
        ELSE NULL
    END AS MoM_Growth_Pct

FROM Sales_Analytics

ORDER BY Sales_Month;
---------------------------------

USE BikeStores;

-- Step 17 - Query 1
-- Missing Values Check

SELECT
    'Orders' AS Table_Name,
    COUNT(*) AS Total_Rows,

    SUM(CASE
        WHEN order_id IS NULL THEN 1
        ELSE 0
    END) AS Missing_Order_ID,

    SUM(CASE
        WHEN customer_id IS NULL THEN 1
        ELSE 0
    END) AS Missing_Customer_ID,

    SUM(CASE
        WHEN order_date IS NULL THEN 1
        ELSE 0
    END) AS Missing_Order_Date

FROM sales.orders;

-- Check Order Items

SELECT
    COUNT(*) AS Total_Rows,

    SUM(CASE
        WHEN product_id IS NULL THEN 1
        ELSE 0
    END) AS Missing_Product_ID,

    SUM(CASE
        WHEN quantity IS NULL THEN 1
        ELSE 0
    END) AS Missing_Quantity,

    SUM(CASE
        WHEN list_price IS NULL THEN 1
        ELSE 0
    END) AS Missing_Price,

    SUM(CASE
        WHEN discount IS NULL THEN 1
        ELSE 0
    END) AS Missing_Discount

FROM sales.order_items;
--------------------------------------------------

-- Step 17 - Query 2
-- Duplicate Primary Keys

-- Duplicate Order IDs
SELECT
    order_id,
    COUNT(*) AS Duplicate_Count

FROM sales.orders

GROUP BY order_id

HAVING COUNT(*) > 1;

-- Duplicate Order Item Keys
SELECT
    order_id,
    item_id,
    COUNT(*) AS Duplicate_Count

FROM sales.order_items

GROUP BY order_id, item_id

HAVING COUNT(*) > 1;
---------------------------------------------------------

-- Step 17 - Query 3
-- Referential Integrity

-- Order Items without matching Orders
SELECT
    OI.order_id,
    OI.item_id

FROM sales.order_items AS OI

LEFT JOIN sales.orders AS O
    ON OI.order_id = O.order_id

WHERE O.order_id IS NULL;

-- Order Items without matching Products
SELECT
    OI.order_id,
    OI.item_id,
    OI.product_id

FROM sales.order_items AS OI

LEFT JOIN production.products AS P
    ON OI.product_id = P.product_id

WHERE P.product_id IS NULL;
---------------------------------------------------

-- Step 17 - Query 4
-- Business Rules Validation

SELECT
    order_id,
    item_id,
    product_id,
    quantity,
    list_price,
    discount

FROM sales.order_items

WHERE quantity <= 0
   OR list_price < 0
   OR discount < 0
   OR discount > 1;
   ------------------------------------------
   
-- Step 17 - Query 5
-- Revenue Reconciliation

;WITH Direct_Revenue AS (
    SELECT
        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Total_Revenue

    FROM sales.order_items AS OI

    INNER JOIN sales.orders AS O
        ON OI.order_id = O.order_id

    WHERE O.order_status = 4
),

Store_Revenue AS (
    SELECT
        O.store_id,

        SUM(
            OI.quantity * OI.list_price *
            (1 - OI.discount)
        ) AS Store_Total_Revenue

    FROM sales.order_items AS OI

    INNER JOIN sales.orders AS O
        ON OI.order_id = O.order_id

    WHERE O.order_status = 4

    GROUP BY O.store_id
),

Reconciliation AS (
    SELECT
        D.Total_Revenue AS Direct_Total,
        SUM(S.Store_Total_Revenue) AS Stores_Total

    FROM Direct_Revenue AS D

    CROSS JOIN Store_Revenue AS S

    GROUP BY D.Total_Revenue
)

SELECT
    ROUND(Direct_Total, 2) AS Direct_Total,
    ROUND(Stores_Total, 2) AS Stores_Total,

    ROUND(
        Direct_Total - Stores_Total, 2
    ) AS Revenue_Difference

FROM Reconciliation;
-------------------------------------------

-- Step 17 - Query 6
-- Data Quality Summary

SELECT
    'Missing Product IDs' AS Quality_Check,
    COUNT(*) AS Issue_Count

FROM sales.order_items
WHERE product_id IS NULL

UNION ALL

SELECT
    'Invalid Quantities',
    COUNT(*)

FROM sales.order_items
WHERE quantity IS NULL OR quantity <= 0

UNION ALL

SELECT
    'Invalid Prices',
    COUNT(*)

FROM sales.order_items
WHERE list_price IS NULL OR list_price < 0

UNION ALL

SELECT
    'Invalid Discounts',
    COUNT(*)

FROM sales.order_items
WHERE discount IS NULL
   OR discount < 0
   OR discount > 1

UNION ALL

SELECT
    'Orphan Order Items',
    COUNT(*)

FROM sales.order_items AS OI

LEFT JOIN sales.orders AS O
    ON OI.order_id = O.order_id

WHERE O.order_id IS NULL

UNION ALL

SELECT
    'Orphan Product References',
    COUNT(*)

FROM sales.order_items AS OI

LEFT JOIN production.products AS P
    ON OI.product_id = P.product_id

WHERE P.product_id IS NULL;
--------------------------------------------------

USE BikeStores;
GO

-- Step 18 - Query 1
-- Create Customer Orders View

CREATE OR ALTER VIEW sales.vw_Customer_Orders
AS

SELECT
    O.order_id,
    O.order_date,
    O.order_status,
    C.customer_id,
    C.first_name,
    C.last_name,
    C.city,
    C.state

FROM sales.orders AS O

LEFT JOIN sales.customers AS C
    ON O.customer_id = C.customer_id;
GO

------------------------------------

SELECT TOP 10 *
FROM sales.vw_Customer_Orders
ORDER BY order_id;
---------------------------------------

USE BikeStores;
GO

-- Step 18 - Query 2
-- Unified Sales Reporting View

CREATE OR ALTER VIEW sales.vw_Unified_Sales
AS

SELECT
    O.order_id,
    OI.item_id,
    O.order_date,
    O.order_status,

    C.customer_id,
    C.first_name AS Customer_First_Name,
    C.last_name AS Customer_Last_Name,

    ST.store_id,
    ST.store_name,
    ST.city AS Store_City,

    S.staff_id,
    S.first_name AS Staff_First_Name,
    S.last_name AS Staff_Last_Name,

    P.product_id,
    P.product_name,

    B.brand_name,
    CAT.category_name,

    OI.quantity,
    OI.list_price,
    OI.discount,

    OI.quantity * OI.list_price *
    (1 - OI.discount) AS Net_Revenue

FROM sales.order_items AS OI

INNER JOIN sales.orders AS O
    ON OI.order_id = O.order_id

LEFT JOIN sales.customers AS C
    ON O.customer_id = C.customer_id

INNER JOIN sales.stores AS ST
    ON O.store_id = ST.store_id

INNER JOIN sales.staffs AS S
    ON O.staff_id = S.staff_id

INNER JOIN production.products AS P
    ON OI.product_id = P.product_id

INNER JOIN production.brands AS B
    ON P.brand_id = B.brand_id

INNER JOIN production.categories AS CAT
    ON P.category_id = CAT.category_id;
GO
----------------------------------

SELECT TOP 10
    order_id,
    product_name,
    store_name,
    quantity,
    Net_Revenue

FROM sales.vw_Unified_Sales

ORDER BY order_id, item_id;
-------------------------------------


USE BikeStores;
GO

-- Step 18 - Query 3
-- Store Performance View

CREATE OR ALTER VIEW sales.vw_Store_Performance
AS

SELECT
    store_id,
    store_name,

    COUNT(DISTINCT order_id)
        AS Total_Orders,

    SUM(quantity)
        AS Units_Sold,

    ROUND(
        SUM(Net_Revenue), 2
    ) AS Total_Revenue,

    ROUND(
        SUM(Net_Revenue) /
        NULLIF(
            COUNT(DISTINCT order_id), 0
        ), 2
    ) AS Avg_Order_Value

FROM sales.vw_Unified_Sales

WHERE order_status = 4

GROUP BY store_id, store_name;
GO
--------------------------------------------

SELECT *
FROM sales.vw_Store_Performance
ORDER BY Total_Revenue DESC;
--------------------------------------------------

-- Step 18 - Query 4
-- Top 5 Products from Reporting View

SELECT TOP 5
    product_id,
    product_name,
    SUM(quantity) AS Units_Sold,

    ROUND(
        SUM(Net_Revenue), 2
    ) AS Total_Revenue

FROM sales.vw_Unified_Sales

WHERE order_status = 4

GROUP BY product_id, product_name

ORDER BY Total_Revenue DESC, product_id;
--------------------------------------------------

USE BikeStores;
GO

-- Step 18 - Query 5
-- Modify Customer Orders View

CREATE OR ALTER VIEW sales.vw_Customer_Orders
AS

SELECT
    O.order_id,
    O.order_date,
    O.order_status,

    C.customer_id,
    C.first_name,
    C.last_name,
    C.email AS Customer_Email,
    C.city,
    C.state

FROM sales.orders AS O

LEFT JOIN sales.customers AS C
    ON O.customer_id = C.customer_id;
GO
---------------------------------------------------------

SELECT TOP 10
    order_id,
    first_name,
    last_name,
    Customer_Email

FROM sales.vw_Customer_Orders

ORDER BY order_id;
-----------------------------------------

-- Step 18 - Query 6A
-- Row Count Validation

SELECT
    (SELECT COUNT(*)
     FROM sales.order_items) AS Source_Rows,

    (SELECT COUNT(*)
     FROM sales.vw_Unified_Sales) AS View_Rows;
     -----------------------------------------------------
     
-- Step 18 - Query 6B
-- Revenue Validation

SELECT
    'Source' AS Data_Source,
    ROUND(
        SUM(
            quantity * list_price *
            (1 - discount)
        ), 2
    ) AS Total_Revenue

FROM sales.order_items

UNION ALL

SELECT
    'Reporting View',
    ROUND(
        SUM(Net_Revenue), 2
    )

FROM sales.vw_Unified_Sales;
-----------------------------------------------

USE BikeStores;
GO

-- Step 19 - Query 1
-- Existing Indexes

SELECT
    T.name AS Table_Name,
    I.name AS Index_Name,
    I.type_desc AS Index_Type,
    I.is_primary_key AS Is_Primary_Key,
    I.is_unique AS Is_Unique

FROM sys.indexes AS I

INNER JOIN sys.tables AS T
    ON I.object_id = T.object_id

WHERE T.name IN (
    'orders',
    'order_items',
    'customers',
    'products'
)

AND I.index_id > 0

ORDER BY
    T.name,
    I.name;
    -----------------------------
    
USE BikeStores;

-- Step 19 - Query 2
-- Date Range Search

SELECT
    order_id,
    customer_id,
    order_date,
    order_status

FROM sales.orders

WHERE order_date >= '2018-01-01'
  AND order_date < '2019-01-01';

  ------------------------------------------------
  
USE BikeStores;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    order_id,
    customer_id,
    order_date,
    order_status

FROM sales.orders

WHERE order_date >= '2018-01-01'
  AND order_date < '2019-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
---------------------------------------------

USE BikeStores;
GO

-- Step 19 - Query 4
-- Create Date Index (Training)

CREATE NONCLUSTERED INDEX IX_Orders_OrderDate_Training
ON sales.orders (order_date)
INCLUDE (
    customer_id,
    order_status
);
GO
-----------------------------

USE BikeStores;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Test A: Force clustered index access
-- Only if PK_orders is a clustered index
-- Verify its actual name/type first

SELECT
    order_id,
    customer_id,
    order_date,
    order_status

FROM sales.orders

WITH (INDEX(0))

WHERE order_date >= '2018-01-01'
  AND order_date < '2019-01-01';

-- Test B: Force training index

SELECT
    order_id,
    customer_id,
    order_date,
    order_status

FROM sales.orders

WITH (INDEX(IX_Orders_OrderDate_Training))

WHERE order_date >= '2018-01-01'
  AND order_date < '2019-01-01';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
----------------------------------------------------

-- Less SARGable

SELECT
    order_id,
    order_date

FROM sales.orders

WHERE YEAR(order_date) = 2018;
--------------------------------------

-- More SARGable

SELECT
    order_id,
    order_date

FROM sales.orders

WHERE order_date >= '2018-01-01'
  AND order_date < '2019-01-01';
  -------------------------------------------
  
USE BikeStores;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    store_name,

    COUNT(DISTINCT order_id) AS Total_Orders,

    ROUND(
        SUM(Net_Revenue), 2
    ) AS Total_Revenue

FROM sales.vw_Unified_Sales

WHERE order_status = 4

GROUP BY store_name

ORDER BY Total_Revenue DESC;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
-------------------------------------------------

USE BikeStores;
GO

DROP INDEX IF EXISTS
    IX_Orders_OrderDate_Training
ON sales.orders;
GO
----------------------------------------------------
