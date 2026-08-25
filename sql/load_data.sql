/* =====================================================================
   Lamborghini Global Sales — Load raw CSV extracts into the database
   Adjust file paths to wherever you save the CSVs on your machine.
   ===================================================================== */

BULK INSERT dbo.dim_models
FROM 'C:\LamborghiniSalesProject\models_raw.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);

BULK INSERT dbo.dim_customers
FROM 'C:\LamborghiniSalesProject\customers_raw.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);

BULK INSERT dbo.fact_orders
FROM 'C:\LamborghiniSalesProject\orders_raw.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO

-- ---------------------------------------------------------------------
-- Basic data-quality checks (run these — screenshot the results,
-- they're great "I validated my data" evidence for your portfolio)
-- ---------------------------------------------------------------------

-- Row counts
SELECT 'dim_models' AS TableName, COUNT(*) AS Rows FROM dbo.dim_models
UNION ALL SELECT 'dim_customers', COUNT(*) FROM dbo.dim_customers
UNION ALL SELECT 'fact_orders',   COUNT(*) FROM dbo.fact_orders;

-- Orphan check: every order should match a real customer and model
SELECT o.OrderID
FROM dbo.fact_orders o
LEFT JOIN dbo.dim_customers c ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

SELECT o.OrderID
FROM dbo.fact_orders o
LEFT JOIN dbo.dim_models m ON o.ModelID = m.ModelID
WHERE m.ModelID IS NULL;

-- Sanity check: SalesAmount should equal UnitPrice * OrderQuantity
SELECT OrderID, SalesAmount, UnitPrice * OrderQuantity AS Expected
FROM dbo.fact_orders
WHERE SalesAmount <> UnitPrice * OrderQuantity;
GO
