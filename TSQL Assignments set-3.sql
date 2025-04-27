/*Lab Activity 1: Ranking Functions
Objective: Use RANK(), DENSE_RANK(), and ROW_NUMBER() to analyze employee salaries.Assignment:
	1.	Create an Employees table with columns: EmployeeID, FirstName, LastName, Department, and Salary.
	2.	Write a query to assign ranks based on salary within each department using RANK().
	3.	Use DENSE_RANK() to rank employees and compare the results with RANK().
	4.	Generate a sequential number for each employee irrespective of the department using ROW_NUMBER().
*/

CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10,2) -- Assume salary as project marks or stipend
);

INSERT INTO Students (StudentID, FirstName, LastName, Department, Salary) VALUES
(1, 'Gajjala', 'Niteesh Kumar Reddy', 'CSE', 80000),
(2, 'Nannapaneni', 'Subhash', 'ECE', 75000),
(3, 'Meesala', 'Jai Vardhan', 'MECH', 70000),
(4, 'Koppaka', 'Dheeraj', 'CSE', 85000),
(5, 'Bollam', 'Meghana', 'ECE', 72000);

SELECT 
    StudentID,
    FirstName,
    LastName,
    Department,
    Salary,
    RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS RankInDept
FROM Students;

SELECT 
    StudentID,
    FirstName,
    LastName,
    Department,
    Salary,
    DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS DenseRankInDept
FROM Students;

SELECT 
    StudentID,
    FirstName,
    LastName,
    Department,
    Salary,
    ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNumberOverall
FROM Students;

/*Objective: Utilize subqueries for filtering and calculating aggregate data.Assignment:
	1.	Create a Sales table with columns: SaleID, SalespersonID, Region, and TotalSales.
	2.	Write a query to find salespeople whose total sales exceed the average sales in their region using a subquery in the WHERE clause.
	3.	Use a subquery in the SELECT clause to show the salesperson's rank within their region.*/

CREATE TABLE Sale (
    SaleID INT PRIMARY KEY,
    SalespersonID INT,
    Region VARCHAR(50),
    TotalSales DECIMAL(10,2)
);
INSERT INTO Sale (SaleID, SalespersonID, Region, TotalSales) VALUES
(1, 101, 'CSE', 5000),
(2, 102, 'CSE', 7000),
(3, 103, 'ECE', 3000),
(4, 104, 'ECE', 4000),
(5, 105, 'MECH', 6000),
(6, 106, 'MECH', 5000),
(7, 107, 'CSE', 8000);

SELECT *
FROM Sale s
WHERE TotalSales > (
    SELECT AVG(TotalSales)
    FROM Sale
    WHERE Region = s.Region
);
SELECT 
    s.SalespersonID,
    s.Region,
    s.TotalSales,
    (
        SELECT COUNT(*)
        FROM Sale s2
        WHERE s2.Region = s.Region
        AND s2.TotalSales > s.TotalSales
    ) + 1 AS SalesRank
FROM Sale s;

/*
Objective: Develop stored procedures for automating tasks.Assignment:
	1.	Create a stored procedure GetHighEarningEmployees that accepts a salary threshold as an input parameter and returns employee details for those earning above the threshold.
	2.	Create another procedure UpdateEmployeeSalary to increase salaries for employees in a specific department.
	3.	Test both procedures using different input values.*/

CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY,
    Name NVARCHAR(100),
    Department NVARCHAR(100),
    Salary DECIMAL(10, 2)
);

INSERT INTO Employee (EmployeeID, Name, Department, Salary)
VALUES
(1, 'Niteesh', 'HR', 50000),
(2, 'Dheeraj', 'IT', 70000),
(3, 'Shannu', 'Finance', 65000),
(4, 'Srinadh', 'IT', 72000),
(5, 'Subhash', 'HR', 48000);

CREATE PROCEDURE GetHighEarningEmployees
    @SalaryThreshold DECIMAL(10, 2)
AS
BEGIN
    SELECT EmployeeID, Name, Department, Salary
    FROM Employee
    WHERE Salary > @SalaryThreshold;
END;

CREATE PROCEDURE UpdateEmployeeSalary
    @DepartmentName NVARCHAR(100),
    @IncreaseAmount DECIMAL(10, 2)
AS
BEGIN
    UPDATE Employee
    SET Salary = Salary + @IncreaseAmount
    WHERE Department = @DepartmentName;
END;

EXEC GetHighEarningEmployees @SalaryThreshold = 60000;

-- Increase salaries in 'HR' department by 2000
EXEC UpdateEmployeeSalary @DepartmentName = 'HR', @IncreaseAmount = 2000;

SELECT * FROM Employee;








/*LAG Function
Objective: Compare sales data using the LAG() function.Assignment:
	1.	Create a MonthlySales table with columns: Month, Region, and TotalSales.
	2.	Use LAG() to find the difference in sales between the current month and the previous month for each region.
	3.	Add a column to identify months with a sales decrease.*/

CREATE TABLE MonthlySales (
    Month INT,
    Region NVARCHAR(50),
    TotalSales DECIMAL(10, 2)
);
INSERT INTO MonthlySales (Month, Region, TotalSales)
VALUES
(1, 'Vijayawada', 15000),
(2, 'Vijayawada', 14000),
(3, 'Vijayawada', 16000),
(1, 'Visakhapatnam', 20000),
(2, 'Visakhapatnam', 21000),
(3, 'Visakhapatnam', 19000),
(1, 'Guntur', 12000),
(2, 'Guntur', 12500),
(3, 'Guntur', 11500);

SELECT 
    Month,
    Region,
    TotalSales,
    LAG(TotalSales) OVER (PARTITION BY Region ORDER BY Month) AS PreviousMonthSales,
    TotalSales - LAG(TotalSales) OVER (PARTITION BY Region ORDER BY Month) AS SalesDifference,
    CASE 
        WHEN TotalSales < LAG(TotalSales) OVER (PARTITION BY Region ORDER BY Month) THEN 'Decrease'
        ELSE 'No Decrease'
    END AS SalesTrend
FROM 
    MonthlySales
ORDER BY
    Region, Month;

/*
Objective: Predict future trends using the LEAD() function.Assignment:
	1.	Use the MonthlySales table from the previous activity.
	2.	Use LEAD() to calculate the predicted sales for the next month in each region.
	3.	Add a column to compare current sales with the predicted future sales.*/

SELECT 
    Month,
    Region,
    TotalSales,
    LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY Month) AS NextMonthSales
FROM MonthlySales

SELECT 
    Month,
    Region,
    TotalSales,
    LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY Month) AS NextMonthSales,
    CASE
        WHEN LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY Month) IS NULL THEN 'No Data'
        WHEN TotalSales < LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY Month) THEN 'Expected Increase'
        WHEN TotalSales > LEAD(TotalSales) OVER (PARTITION BY Region ORDER BY Month) THEN 'Expected Decrease'
        ELSE 'No Change'
    END AS FutureTrend
FROM MonthlySales








