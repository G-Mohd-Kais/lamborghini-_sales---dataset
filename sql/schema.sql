/* =====================================================================
   Lamborghini Global Sales — Database Schema
   Dialect: SQL Server (T-SQL). Minor tweaks needed for MySQL/Postgres
   are noted in comments.
   ===================================================================== */

IF DB_ID('LamborghiniSalesDB') IS NULL
BEGIN
    PRINT 'Create the LamborghiniSalesDB database first (SSMS: right-click Databases > New Database),
           then run this script against it.';
END
GO

-- ---------------------------------------------------------------------
-- Dimension: Models  (top 4 Lamborghini models used in this project)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS dbo.dim_models;
CREATE TABLE dbo.dim_models (
    ModelID     CHAR(3)         NOT NULL PRIMARY KEY,
    ModelName   VARCHAR(50)     NOT NULL,
    Segment     VARCHAR(50)     NOT NULL,
    BasePrice   DECIMAL(10,2)   NOT NULL
);

-- ---------------------------------------------------------------------
-- Dimension: Customers (dealers / retail buyers, with geography)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS dbo.dim_customers;
CREATE TABLE dbo.dim_customers (
    CustomerID      CHAR(5)         NOT NULL PRIMARY KEY,
    CustomerName    VARCHAR(100)    NOT NULL,
    Country         VARCHAR(50)     NOT NULL,
    Region          VARCHAR(30)     NOT NULL   -- North America, Europe, Asia, Africa, South America, Australia
);

-- ---------------------------------------------------------------------
-- Fact: Orders (one row per sales order/transaction)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS dbo.fact_orders;
CREATE TABLE dbo.fact_orders (
    OrderID         CHAR(6)         NOT NULL PRIMARY KEY,
    OrderDate       DATE            NOT NULL,
    CustomerID      CHAR(5)         NOT NULL,
    ModelID         CHAR(3)         NOT NULL,
    PaintColor      VARCHAR(30)     NOT NULL,
    OrderQuantity   INT             NOT NULL,
    DealSize        VARCHAR(10)     NOT NULL,   -- Small / Medium / Large  (derived, kept for validation)
    UnitPrice       DECIMAL(10,2)   NOT NULL,
    SalesAmount     DECIMAL(12,2)   NOT NULL,
    CONSTRAINT FK_orders_customer FOREIGN KEY (CustomerID) REFERENCES dbo.dim_customers(CustomerID),
    CONSTRAINT FK_orders_model    FOREIGN KEY (ModelID)    REFERENCES dbo.dim_models(ModelID)
);

-- Helpful indexes for the aggregations the dashboard will run
CREATE INDEX IX_orders_date   ON dbo.fact_orders(OrderDate);
CREATE INDEX IX_orders_model  ON dbo.fact_orders(ModelID);
CREATE INDEX IX_orders_cust   ON dbo.fact_orders(CustomerID);
GO
