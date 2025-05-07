/* Lab 1: Creating an Indexed Search for Customers
Objective: Improve query performance using indexes.
Steps:
	1.	Identify slow-running queries in Person.Person.
	2.	Create an index on LastName to optimize searches.
?? Expected Outcome: Queries filtering by LastName should execute faster.
Enhancements:
	•	Compare performance before and after indexing using EXPLAIN ANALYZE.*/

DECLARE @STIME DATETIME=GETDATE();

SELECT BusinessEntityID,FirstName,LastName FROM Person.Person WHERE LastName='Smith'; 

DECLARE @ETIME DATETIME=GETDATE();

SELECT DATEDIFF(NANOSECOND,@STIME,@ETIME) AS PERFORMANCE;

CREATE NONCLUSTERED INDEX ONLASTNAME
ON Person.Person (LastName);

DECLARE @STIMEI DATETIME=GETDATE();
SELECT BusinessEntityID,FirstName,LastName FROM Person.Person WHERE LastName='Smith'; 
DECLARE @ETIMEI DATETIME=GETDATE();
SELECT DATEDIFF(NANOSECOND,@STIMEI,@ETIMEI) AS PERFORMANCEI;
drop index ONLASTNAME on Person.Person;











/* Lab 2: Using Table-Valued Functions (TVF) for Sales Insights
Objective: Create a TVF to return yearly sales totals.
Steps:
	1.	Define a TVF that accepts a year parameter.
	2.	Return total sales grouped by product.
Expected Outcome: Running SELECT * FROM GetYearlySales(2023); returns sales per product for 2023.
Enhancements:
	•	Modify function to include customer-wise sales totals.*/

CREATE OR ALTER FUNCTION dbo.GetYearlySale(@Year INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        C.CustomerID,
        P.ProductID,
        P.Name AS ProductName,
        SUM(SD.OrderQty * SD.UnitPrice) AS TotalSales
    FROM Sales.SalesOrderHeader SH
    JOIN Sales.SalesOrderDetail SD ON SH.SalesOrderID = SD.SalesOrderID
    JOIN Production.Product P ON SD.ProductID = P.ProductID
    JOIN Sales.Customer C ON SH.CustomerID = C.CustomerID
    WHERE YEAR(SH.OrderDate) = @Year
    GROUP BY C.CustomerID, P.ProductID, P.Name
);
SELECT * FROM GetYearlySale(2011);





/*Lab 3: Using CTEs for Ranking Products
Objective: Rank products by total sales using Common Table Expressions (CTE).
Steps:
	1.	Define a CTE to calculate sales ranking.
	2.	Retrieve top 5 best-selling products.
Expected Outcome: Returns top 5 best-selling products.
Enhancements:
	•	Modify the query to include sales by category.*/

WITH ProductSales AS (
    SELECT 
        p.ProductID,
        p.Name AS ProductName,
        SUM(sod.OrderQty * sod.UnitPrice) AS TotalSales
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    GROUP BY p.ProductID, p.Name
),
RankedProducts AS (
    SELECT 
        ProductID,
        ProductName,
        TotalSales,
        RANK() OVER (ORDER BY TotalSales DESC) AS SalesRank
    FROM ProductSales
)
SELECT 
    ProductID,
    ProductName,
    TotalSales,
    SalesRank
FROM RankedProducts
WHERE SalesRank <= 5;


WITH ProductSales AS (
    SELECT 
        p.ProductID,
        p.Name AS ProductName,
        pc.Name AS CategoryName,
        SUM(sod.OrderQty * sod.UnitPrice) AS TotalSales
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
    GROUP BY p.ProductID, p.Name, pc.Name
),
RankedProducts AS (
    SELECT 
        ProductID,
        ProductName,
        CategoryName,
        TotalSales,
        RANK() OVER (ORDER BY TotalSales DESC) AS SalesRank
    FROM ProductSales
)
SELECT 
    ProductID,
    ProductName,
    CategoryName,
    TotalSales,
    SalesRank
FROM RankedProducts
WHERE SalesRank <= 5;










/*Lab 4: Creating a View for Frequent Customers
Objective: Use a VIEW to list customers who placed more than 5 orders.
Steps:
	1.	Create a view based on Sales.Customer.
	2.	Use an INNER JOIN with Sales.SalesOrderHeader.
Expected Outcome: Running SELECT * FROM FrequentCustomers; returns repeat customers.
Enhancements:
	•	Modify the view to display customer revenue totals.*/

CREATE VIEW FrequentCustomers
AS
SELECT 
    c.CustomerID,
    COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.Customer c
INNER JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
HAVING COUNT(soh.SalesOrderID) > 5;

SELECT * FROM FrequentCustomers;

ALTER VIEW FrequentCustomers
AS
SELECT 
    c.CustomerID,
    COUNT(soh.SalesOrderID) AS OrderCount,
    SUM(soh.TotalDue) AS TotalRevenue
FROM Sales.Customer c
INNER JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
HAVING COUNT(soh.SalesOrderID) > 5;

SELECT * FROM FrequentCustomers;






/*Lab 5: Using Triggers for Automatic Audit Logging
Objective: Log product price changes automatically.
Steps:
	1.	Create an AuditProducts table.
	2.	Use an AFTER UPDATE trigger to log changes.
Expected Outcome: When product prices change, the details are automatically logged in AuditProducts.
Enhancements:
	•	Add user details to track modifications.*/

CREATE TABLE AuditProducts (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    OldPrice MONEY,
    NewPrice MONEY,
    ChangeDate DATETIME DEFAULT GETDATE(),
    ChangedBy NVARCHAR(100)
);

CREATE TRIGGER trg_LogPric
ON Production.Product
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AuditProducts (ProductID, OldPrice, NewPrice, ChangedBy)
    SELECT 
        d.ProductID,
        d.ListPrice AS OldPrice,
        i.ListPrice AS NewPrice,
        SYSTEM_USER             
    FROM deleted d
    INNER JOIN inserted i ON d.ProductID = i.ProductID
    WHERE d.ListPrice <> i.ListPrice;
END;


UPDATE Production.Product
SET ListPrice = ListPrice + 10
WHERE ProductID = 680;

-- Check the audit log
SELECT * FROM AuditProducts;


