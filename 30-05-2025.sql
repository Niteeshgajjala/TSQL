/*1. PIVOT
Objective: Transform row data into columns using PIVOT.
Task:
	1.	Create a table named Sales with the columns: Region, Product, Year, and SalesAmount.
	2.	Populate the table with sample data for multiple regions, products, and years.
	3.	Write a query to display the total SalesAmount for each Product, with each Year as a column.
	4.	Add a query to reverse the PIVOT using the UNPIVOT operator.*/

CREATE TABLE Sal (
    Region VARCHAR(50),
    Product VARCHAR(50),
    Year INT,
    SalesAmount DECIMAL(10, 2)
);

INSERT INTO Sal (Region, Product, Year, SalesAmount) VALUES
('North', 'Laptop', 2022, 1500.00),
('North', 'Laptop', 2023, 1700.00),
('South', 'Laptop', 2022, 1600.00),
('South', 'Laptop', 2023, 1800.00),
('North', 'Tablet', 2022, 800.00),
('North', 'Tablet', 2023, 850.00),
('South', 'Tablet', 2022, 900.00),
('South', 'Tablet', 2023, 950.00),
('North', 'Phone', 2022, 1200.00),
('North', 'Phone', 2023, 1300.00),
('South', 'Phone', 2022, 1250.00),
('South', 'Phone', 2023, 1350.00);

SELECT Product, [2022] AS Sales_2022, [2023] AS Sales_2023
FROM (
    SELECT Product, Year, SalesAmount
    FROM Sal
) AS SourceTable
PIVOT (
    SUM(SalesAmount)
    FOR Year IN ([2022], [2023])
) AS PivotTable;

SELECT Product, Year, SalesAmount
FROM (
    SELECT Product, [2022], [2023]
    FROM (
        SELECT Product, Year, SalesAmount
        FROM Sal
    ) AS SourceTable
    PIVOT (
        SUM(SalesAmount)
        FOR Year IN ([2022], [2023])
    ) AS PivotTable
) AS PivotResult
UNPIVOT (
    SalesAmount FOR Year IN ([2022], [2023])
) AS UnpivotResult;


/*2. SELECT INTO
Objective: Create a new table from an existing table.
Task:
	1.	Create a table named Employees with columns: EmployeeID, Name, Department, and Salary.
	2.	Insert sample data into the Employees table.
	3.	Use SELECT INTO to create a new table HighSalaryEmployees that stores data for employees earning above 60,000.
	4.	Verify the new table's structure and data.*/

CREATE TABLE Employee_s (
    EmployeeID INT,
    Name VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(10, 2)
);

INSERT INTO Employee_s (EmployeeID, Name, Department, Salary) VALUES
(1, 'Niteesh', 'HR', 55000),
(2, 'Dheeraj', 'IT', 72000),
(3, 'Shanmukh', 'Finance', 80000),
(4, 'Jai', 'IT', 60000),
(5, 'Manohar', 'HR', 65000);

SELECT * INTO HighSalaryEmployees
FROM Employee_s
WHERE Salary > 60000;



EXEC sp_help HighSalaryEmployees;

SELECT * from HighSalaryEmployees;

/*3. CASE
Objective: Use CASE statements for conditional logic in queries.
Task:
	1.	Use the Employees table from the previous task.
	2.	Write a query to classify employees into salary ranges:
	?	"Low" for salary < 40,000
	?	"Medium" for salary between 40,000 and 60,000
	?	"High" for salary > 60,000
	3.	Add a column named SalaryRange in your query, which uses CASE logic for classification.*/

SELECT * ,
CASE
WHEN Salary <40000 THEN 'Low'
WHEN Salary BETWEEN 40000 AND 60000 THEN 'Medium'
WHEN Salary >60000 Then 'High'
END AS SalaryRange
FROM Employee_s

/*4. COALESCE
Objective: Handle NULL values with COALESCE.
Task:
	1.	Create a table named Orders with columns: OrderID, CustomerName, OrderDate, and ShippedDate.
	2.	Insert some sample data, ensuring ShippedDate has some NULL values.
	3.	Write a query that replaces NULL in ShippedDate with the string "Not Shipped" using COALESCE.
	4.	Include a column named DeliveryStatus with the logic:
	?	"Delivered" if ShippedDate is not NULL.
	?	"Pending" if ShippedDate is NULL.*/

CREATE TABLE Order_s (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    OrderDate DATE,
    ShippedDate DATE
);

INSERT INTO Order_s (OrderID, CustomerName, OrderDate, ShippedDate) VALUES
(1, 'Alice', '2025-05-01', '2025-05-03'),
(2, 'Bob', '2025-05-02', NULL),
(3, 'Charlie', '2025-05-03', '2025-05-05'),
(4, 'Diana', '2025-05-04', NULL);

SELECT OrderID, CustomerName, OrderDate ,
COALESCE(CONVERT(VARCHAR, ShippedDate, 23), 'Not Shipped') AS ShippedDate,
CASE 
        WHEN ShippedDate IS NOT NULL THEN 'Delivered'
        ELSE 'Pending'
    END AS DeliveryStatus
FROM Order_s;

/*5. NULLIF
Objective: Use NULLIF for handling division errors.
Task:
	1.	Create a table named Scores with columns: StudentID, Subject, MarksObtained, and MaximumMarks.
	2.	Write a query to calculate Percentage as (MarksObtained * 100) / MaximumMarks.
	3.	Use NULLIF to handle cases where MaximumMarks is zero, preventing a division-by-zero error.*/

CREATE TABLE Scores (
    StudentID INT,
    Subject VARCHAR(100),
    MarksObtained INT,
    MaximumMarks INT
);

INSERT INTO Scores (StudentID, Subject, MarksObtained, MaximumMarks) VALUES
(101, 'Math', 85, 0),
(101, 'Science', 78, 100),
(102, 'Math', 92, 100),
(102, 'Science', 88, 100),
(103, 'Math', 55, 100),
(103, 'Science', 60, 0);

SELECT 
    StudentID,
    Subject,
    MarksObtained,
    MaximumMarks,
    (MarksObtained * 100.0) / NULLIF(MaximumMarks, 0) AS Percentage
FROM Scores;

/*6. DDL Statements with Constraints
Objective: Explore constraints such as UNIQUE, CHECK, NOT NULL, and FOREIGN KEY.
Task:
	1.	Create a table named Departments with columns: DepartmentID (Primary Key), DepartmentName (UNIQUE).
	2.	Create a table named Staff with columns:
	?	StaffID (Primary Key)
	?	StaffName (NOT NULL)
	?	DepartmentID (FOREIGN KEY) referencing Departments
	?	Age with a CHECK constraint ensuring Age > 18.
	3.	Insert valid data into both tables, and attempt to insert invalid data to test constraints.*/

CREATE TABLE Depart (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) UNIQUE
);

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY,
    StaffName VARCHAR(100) NOT NULL,
    DepartmentID INT,
    Age INT CHECK (Age > 18),
    FOREIGN KEY (DepartmentID) REFERENCES Depart(DepartmentID)
);

INSERT INTO Depart (DepartmentID, DepartmentName) VALUES
(1, 'HR'),
(2, 'Finance'),
(3, 'IT');

INSERT INTO Staff (StaffID, StaffName, DepartmentID, Age) VALUES
(101, 'Niteesh', 1, 22),
(102, 'Dheeraj', 2, 21),
(103, 'shannu', 3, 22);

INSERT INTO Depart (DepartmentID, DepartmentName)
VALUES (4, 'HR'); 

INSERT INTO Staff (StaffID, StaffName, DepartmentID, Age)
VALUES (104, NULL, 1, 22); 

INSERT INTO Staff (StaffID, StaffName, DepartmentID, Age)
VALUES (105, 'David', 2, 17); 

INSERT INTO Staff (StaffID, StaffName, DepartmentID, Age)
VALUES (106, 'Emma', 99, 28);


/*7. TRUNCATE and DROP
Objective: Understand the differences between TRUNCATE and DROP.
Task:
	1.	Create a table named TemporaryData with some columns and populate it with test data.
	2.	Use TRUNCATE to remove all rows and verify that the table structure remains intact.
	3.	Use DROP to delete the TemporaryData table completely and verify its removal.*/

CREATE TABLE TemporaryData (
    ID INT,
    Name VARCHAR(100)
);

INSERT INTO TemporaryData(ID,Name)
VALUES
(1,'Niteesh'),(2,'Dheeraj');

SELECT * FROM TemporaryData;

TRUNCATE TABLE TemporaryData;

DROP TABLE TemporaryData;

/*8. Data Types
Objective: Experiment with various SQL data types.
Task:
	1.	Create a table named Products with the following columns:
	?	ProductID (INT, Primary Key)
	?	ProductName (VARCHAR(50), NOT NULL)
	?	Price (DECIMAL(10, 2))
	?	StockQuantity (SMALLINT)
	?	LaunchDate (DATE).
	2.	Insert data using valid data types.
	3.	Try inserting invalid data (e.g., text in Price, a string in LaunchDate) and observe the errors.*/

CREATE TABLE Pro_duct(
ProductID INT Primary Key,
ProductName VARCHAR(50) NOT NULL,
Price DECIMAL(10, 2),
StockQuantity SMALLINT,
LaunchDate DATE);

INSERT INTO Pro_duct (ProductID, ProductName, Price, StockQuantity, LaunchDate) VALUES
(1, 'Smartphone X100', 699.99, 150, '2024-11-15'),
(2, 'Laptop Pro 15', 1199.50, 80, '2023-09-01'),
(3, 'Wireless Earbuds Z', 129.99, 300, '2024-05-20'),
(4, 'Smartwatch G5', 249.00, 200, '2025-02-10'),
(5, 'Gaming Console S', 499.00, 50, '2023-12-25');

INSERT INTO Pro_duct (ProductID, ProductName, Price, StockQuantity, LaunchDate) VALUES
(5, 'Watch',230,22,'Hi');

INSERT INTO Pro_duct (ProductID, ProductName, Price, StockQuantity, LaunchDate) VALUES
(4, 'pen', 'cheap', 50, '2024-06-01');
























