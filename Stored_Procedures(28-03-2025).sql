/* 1. Create and Execute a Stored Procedure with Parameters
Objective: Learn to create a stored procedure with input parameters and execute it with different values.
Task:
Create a stored procedure that retrieves employee details from an Employees table based on a department ID.
Pass the department ID as an input parameter.
Test the stored procedure by calling it with multiple department IDs.
Expected Outcome: A dynamic result set displaying employee information specific to the input department.
*/

CREATE TABLE Employ (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    DepartmentID INT,
    Salary DECIMAL(10, 2)
);

INSERT INTO Employ (EmployeeID, Name, DepartmentID, Salary)
VALUES
(1, 'Niteesh', 101, 60000),
(2, 'Dheeraj', 102, 75000),
(3, 'Shanmukh', 101, 58000),
(4, 'Jai Vardhan', 103, 82000);

CREATE PROCEDURE EMP_procedure(@DepartmentID int)
AS
BEGIN
SELECT * FROM Employ WHERE DepartmentID=@DepartmentID
END

exec EMP_procedure 101;

exec EMP_procedure @DepartmentID=102;

Execute EMP_procedure @DepartmentID=103;

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

CREATE TABLE Product_s (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL UNIQUE,
    Price DECIMAL(10, 2) NOT NULL
);
CREATE TABLE ErrorLogs (
    ErrorID INT IDENTITY(1,1) PRIMARY KEY,
    ErrorMessage NVARCHAR(MAX),
    ErrorProcedure NVARCHAR(200),
    ErrorLine INT,
    ErrorDateTime DATETIME
);

CREATE PROCEDURE InsertProduct
    @ProductID INT,
    @ProductName VARCHAR(100),
    @Price DECIMAL(10, 2)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Product_s (ProductID, ProductName, Price)
        VALUES (@ProductID, @ProductName, @Price);
    END TRY
    BEGIN CATCH
        INSERT INTO ErrorLogs (ErrorMessage, ErrorProcedure, ErrorLine, ErrorDateTime)
        VALUES (
            ERROR_MESSAGE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            GETDATE()
        );
    END CATCH
END;


EXEC InsertProduct @ProductID = 1, @ProductName = 'Laptop', @Price = 999.99;


EXEC InsertProduct @ProductID = 1, @ProductName = 'Tablet', @Price = 399.99;
EXEC InsertProduct @ProductID = 2, @ProductName = 'Laptop', @Price = 299.99;

SELECT * FROM ErrorLogs;



/* 3. Stored Procedure for Data Modification
Objective: Practice using stored procedures to modify data in a table.
Task:
Create a stored procedure to update the salary of employees in an Employees table.
The procedure should take EmployeeID and NewSalary as input parameters.
Test the procedure by updating multiple employees’ salaries.
Expected Outcome: Employees’ salaries are updated in the database, and users can confirm via a SELECT query.*/

ALTER PROCEDURE EMP_procedure
    @DepartmentID INT,
    @NewSalary DECIMAL(10, 2)
AS
BEGIN
    UPDATE Employ
    SET Salary = @NewSalary
    WHERE DepartmentID = @DepartmentID;
END;

EXEC EMP_procedure @DepartmentID = 102, @NewSalary = 30000.32;

SELECT * FROM Employ;

/*
4. Stored Procedure with a Conditional Query
Objective: Use control flow in a stored procedure to return conditional results.
Task:
Create a stored procedure that accepts a category name as an input parameter.
Based on the category, return either all products from a Products table or a "Category not found" message if no products exist in the given category.
Test the procedure with valid and invalid category names.
Expected Outcome: Dynamic results displaying matching products or a custom error message.*/

CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(100),
    Category NVARCHAR(100),
    Price DECIMAL(10, 2)
);

INSERT INTO Product (ProductID, ProductName, Category, Price) VALUES
(1, 'Smartphone', 'Electronics', 699.99),
(2, 'Laptop', 'Electronics', 999.99),
(3, 'Blender', 'Home Appliances', 59.99),
(4, 'Notebook', 'Stationery', 3.99);

CREATE PROCEDURE GetProductsByCategory
    @Category NVARCHAR(100)
AS
BEGIN
    DECLARE @ProductCount INT;

    SELECT @ProductCount = COUNT(*) 
    FROM Product
    WHERE Category = @Category;

    IF @ProductCount > 0
    BEGIN
        SELECT ProductName, Price, Category
        FROM Product
        WHERE Category = @Category;
    END
    ELSE
    BEGIN
        PRINT 'Category not found';
    END
END;

EXEC GetProductsByCategory @Category='clothes';
EXEC GetProductsByCategory @Category='Electronics';


/*5. Stored Procedure with Output Parameters
Objective: Learn to use output parameters in stored procedures.
Task:
Create a stored procedure to calculate the total sales for a given CustomerID from a Sales table.
Pass the CustomerID as an input parameter and return the total sales amount as an output parameter.
Execute the procedure to retrieve total sales for multiple customers.
Expected Outcome: Accurate calculation of total sales and proper usage of output parameters.*/

CREATE TABLE Saless (
    SaleID INT PRIMARY KEY IDENTITY,
    CustomerID INT,
    SaleAmount DECIMAL(10, 2),
    SaleDate DATE
);

INSERT INTO Saless (CustomerID, SaleAmount, SaleDate) VALUES
(101, 250.50, '2025-01-15'),
(101, 175.00, '2025-02-10'),
(102, 300.00, '2025-03-05'),
(103, 450.75, '2025-03-15'),
(102, 150.25, '2025-04-01'),
(101, 200.00, '2025-04-10');

CREATE PROCEDURE TotalSales (@CustomerID INT ,@Totalamount DECIMAL(10,2) out)
AS
BEGIN
SELECT @totalamount=sum(SaleAmount) FROM Saless WHERE CustomerID = @CustomerID
END

DECLARE @total_amount DECIMAL(10,2)
EXEC TotalSales @CustomerID=101,@Totalamount= @total_amount out
PRINT @total_amount
EXEC TotalSales @CustomerID=102,@Totalamount= @total_amount out
PRINT @total_amount









