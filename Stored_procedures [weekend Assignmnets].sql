/*Lab Activity 1: Creating a View for High-Earning Employees
Objective: Use VIEW to display employees earning above department average.
Steps:
Create an Employees table with sample data.
Define a VIEW to filter high-earning employees per department.
Retrieve data from the view.
Expected Outcome: The view should only return employees whose salaries are above the department average.*/

CREATE TABLE Em (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    Department VARCHAR(50),
    Salary DECIMAL(10, 2)
);

INSERT INTO Em (EmployeeID, Name, Department, Salary) VALUES
(1, 'Niteesh', 'HR', 50000),
(2, 'Biswanth', 'HR', 60000),
(3, 'Dheeraj', 'IT', 70000),
(4, 'Nageshwar', 'IT', 90000),
(5, 'Yeshwanth', 'IT', 65000),
(6, 'Harshith', 'Finance', 75000),
(7, 'Manikanta', 'Finance', 80000);

CREATE VIEW HighEarningEmployees AS
SELECT *
FROM Em e
WHERE Salary > (
    SELECT AVG(Salary) as Avg_sal
    FROM Em
    WHERE Department = e.Department
);
SELECT * FROM HighEarningEmployees;

/*2. Lab Activity 2: Using Correlated Subqueries for Recent Orders
Objective: Use Correlated Subqueries to fetch each customer's latest order details.
Steps:
Create Customers and Orders tables.
Use correlated subquery to find the latest order per customer.
Retrieve customer details along with order date.
?? Expected Outcome: Each customer appears only once, showing their most recent order date.
Enhancements:
Modify the query to include order amount.
Optimize query performance with indexing on OrderDate.*/

CREATE TABLE Customer_s (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

CREATE TABLE Or_ders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    OrderAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

INSERT INTO Customer_s (CustomerID, CustomerName) VALUES
(1, 'Niteesh'),
(2, 'Shannu'),
(3, 'Dheeraj');

INSERT INTO Or_ders (OrderID, CustomerID, OrderDate, OrderAmount) VALUES
(101, 1, '2024-12-01', 250.00),
(102, 2, '2024-11-20', 180.00),
(103, 3, '2025-03-05', 400.00);

CREATE INDEX idx_orderdate ON Or_ders(OrderDate);



SELECT 
    c.CustomerID,
    c.CustomerName,
    o.OrderDate,
    o.OrderAmount
FROM 
    Customer_s c
JOIN 
    Or_ders o ON c.CustomerID = o.CustomerID
WHERE 
    o.OrderDate = (
        SELECT MAX(o2.OrderDate)
        FROM Or_ders o2
        WHERE o2.CustomerID = c.CustomerID
    );


/*3. Lab Activity 3: Creating a Stored Procedure for Dynamic Sales Reports
Objective: Create a Stored Procedure that fetches total sales for a given year.
Steps:
Accept @Year INT as an input parameter.
Aggregate sales based on product and year.
Execute stored procedure with dynamic inputs.
?? Expected Outcome: Running stored procedure should return total sales for the year 2022.
Enhancements:
Modify procedure to fetch sales per region.*/

CREATE TABLE S_ales (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT,
    Region NVARCHAR(50),
    SaleAmount DECIMAL(10,2),
    SaleDate DATE
);

INSERT INTO S_ales (ProductID, Region, SaleAmount, SaleDate) VALUES
(101, 'North', 1200.50, '2022-01-15'),
(102, 'South', 800.00, '2022-02-10'),
(101, 'East', 950.25, '2022-03-20'),
(103, 'West', 1100.00, '2022-04-05'),
(102, 'North', 1300.75, '2022-06-17'),
(101, 'South', 1000.00, '2023-01-10'),
(104, 'East', 1150.90, '2022-11-22'),
(103, 'West', 1025.30, '2021-12-29');

CREATE OR ALTER PROCEDURE GetTotalSalesByYear
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Region,
        ProductID,
        SUM(SaleAmount) AS TotalSales
    FROM 
        S_ales
    WHERE 
        YEAR(SaleDate) = @Year
    GROUP BY 
        Region, ProductID;
END;

EXEC GetTotalSalesByYear @Year = 2022;




/*4. Stored Procedures: Dynamic Query Execution & Performance Tuning
Stored Procedure for Employee Bonus Calculation
Activity: Create a stored procedure that calculates bonus percentages dynamically.
Steps:
	1.	Accept @BaseSalary and @PerformanceRating as input parameters.
	2.	Determine bonus based on salary range.
	3.	Return final bonus amount.
 
?? Expected Outcome: Calling stored procedure should return a calculated bonus amount based on salary and rating.*/
CREATE  PROCEDURE CalculateEmployeeBonus
    @BaseSalary DECIMAL(10, 2),
    @PerformanceRating INT,
    @BonusAmount DECIMAL(10, 2) OUTPUT
AS
BEGIN
    -- Declare bonus percentage variable
    DECLARE @BonusPercentage DECIMAL(5, 2);

    IF @BaseSalary < 30000
    BEGIN
        SET @BonusPercentage = 
            CASE 
                WHEN @PerformanceRating >= 4 THEN 0.10
                WHEN @PerformanceRating = 3 THEN 0.07
                ELSE 0.05
            END;
    END
    ELSE IF @BaseSalary BETWEEN 30000 AND 60000
    BEGIN
        SET @BonusPercentage = 
            CASE 
                WHEN @PerformanceRating >= 4 THEN 0.08
                WHEN @PerformanceRating = 3 THEN 0.05
                ELSE 0.03
            END;
    END
    ELSE
    BEGIN
        SET @BonusPercentage = 
            CASE 
                WHEN @PerformanceRating >= 4 THEN 0.06
                WHEN @PerformanceRating = 3 THEN 0.04
                ELSE 0.02
            END;
    END

    SET @BonusAmount = @BaseSalary * @BonusPercentage;
END;


DECLARE @FinalBonus DECIMAL(10, 2);
EXEC CalculateEmployeeBonus 
    @BaseSalary = 45000, 
    @PerformanceRating = 4, 
    @BonusAmount = @FinalBonus OUTPUT;

SELECT @FinalBonus AS BonusAmount;













