/* =====================================================================
   Lamborghini Global Sales — Analysis queries
   Each query below reproduces one tile/chart on the Power BI dashboard.
   Run & screenshot these — they're good evidence you validated the
   numbers in SQL before trusting them in Power BI.
   ===================================================================== */

-- 1) KPI cards: Total Sales / Total Orders / Total Customers  (per model)
SELECT
    m.ModelName,
    FORMAT(SUM(o.SalesAmount), 'C0') AS TotalSales,
    COUNT(*)                          AS TotalOrders,
    COUNT(DISTINCT o.CustomerID)      AS TotalCustomers
FROM dbo.fact_orders o
JOIN dbo.dim_models m ON o.ModelID = m.ModelID
GROUP BY m.ModelName
ORDER BY SUM(o.SalesAmount) DESC;

-- 2) Sales by Year (for the horizontal bar chart)
SELECT
    m.ModelName,
    YEAR(o.OrderDate)   AS SalesYear,
    SUM(o.SalesAmount)  AS TotalSales
FROM dbo.fact_orders o
JOIN dbo.dim_models m ON o.ModelID = m.ModelID
GROUP BY m.ModelName, YEAR(o.OrderDate)
ORDER BY m.ModelName, SalesYear;

-- 3) Sales by Paint Color (column chart)
SELECT
    m.ModelName,
    o.PaintColor,
    COUNT(*) AS Orders
FROM dbo.fact_orders o
JOIN dbo.dim_models m ON o.ModelID = m.ModelID
GROUP BY m.ModelName, o.PaintColor
ORDER BY m.ModelName, Orders DESC;

-- 4) Sales by Deal Size (donut chart)
SELECT
    m.ModelName,
    o.DealSize,
    COUNT(*) AS Orders,
    SUM(o.SalesAmount) AS TotalSales
FROM dbo.fact_orders o
JOIN dbo.dim_models m ON o.ModelID = m.ModelID
GROUP BY m.ModelName, o.DealSize
ORDER BY m.ModelName,
    CASE o.DealSize WHEN 'Small' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END;

-- 5) Sales by Country / Region (for the map)
SELECT
    c.Region,
    c.Country,
    COUNT(*)            AS Orders,
    SUM(o.SalesAmount)   AS TotalSales
FROM dbo.fact_orders o
JOIN dbo.dim_customers c ON o.CustomerID = c.CustomerID
GROUP BY c.Region, c.Country
ORDER BY TotalSales DESC;

-- 6) Top 4 models overall — head-to-head comparison
SELECT
    m.ModelName,
    m.Segment,
    m.BasePrice,
    COUNT(*)                         AS TotalOrders,
    SUM(o.SalesAmount)               AS TotalSales,
    SUM(o.SalesAmount) / COUNT(*)    AS AvgOrderValue
FROM dbo.fact_orders o
JOIN dbo.dim_models m ON o.ModelID = m.ModelID
GROUP BY m.ModelName, m.Segment, m.BasePrice
ORDER BY TotalSales DESC;
GO

/* =====================================================================
   VIEW: this is what Power BI will actually connect to.
   One denormalized, analysis-ready view = cleaner Power Query step
   and a clear "SQL did the heavy lifting" story for your portfolio.
   ===================================================================== */
CREATE OR ALTER VIEW dbo.vw_sales_summary AS
SELECT
    o.OrderID,
    o.OrderDate,
    YEAR(o.OrderDate)          AS OrderYear,
    m.ModelName,
    m.Segment,
    m.BasePrice,
    c.CustomerID,
    c.CustomerName,
    c.Country,
    c.Region,
    o.PaintColor,
    o.OrderQuantity,
    o.DealSize,
    o.UnitPrice,
    o.SalesAmount
FROM dbo.fact_orders o
JOIN dbo.dim_models    m ON o.ModelID    = m.ModelID
JOIN dbo.dim_customers c ON o.CustomerID = c.CustomerID;
GO

SELECT TOP 20 * FROM dbo.vw_sales_summary ORDER BY OrderDate DESC;
GO
