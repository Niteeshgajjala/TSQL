/*Assignment 1: Customer Order Management
Objective: Create and manage a stored procedure for order retrieval and updates in a customer database.
Setup:
Create a table named Customers with columns: CustomerID, FirstName, LastName, Email, PhoneNumber.
Create another table named Orders with columns: OrderID, CustomerID, OrderDate, OrderTotal, OrderStatus.*/

CREATE TABLE Cust (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    PhoneNumber VARCHAR(20)
);

CREATE TABLE Ord (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    OrderTotal DECIMAL(10, 2),
    OrderStatus VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Insert into Customers
INSERT INTO Cust (CustomerID, FirstName, LastName, Email, PhoneNumber)
VALUES
(1, 'Niteesh', 'Gajjala', 'niteeshkumarreddygajjala@gmail.com', '9392402278'),
(2, 'Dheeraj', 'Koppaka', 'koppakadheeraj@gmail.com', '79978779357'),
(3, 'Shanmukh', 'Mitepally', 'shanmukhnandhan@gmail.com', '7396422335');

-- Insert into Orders
INSERT INTO Ord (OrderID, CustomerID, OrderDate, OrderTotal, OrderStatus)
VALUES
(101, 1, '2024-01-15', 250.00, 'Shipped'),
(102, 1, '2024-02-10', 150.50, 'Pending'),
(103, 2, '2024-03-05', 300.75, 'Delivered'),
(104, 3, '2024-03-15', 450.00, 'Cancelled'),
(105, 2, '2024-04-01', 120.00, 'Shipped');

/*Task 1: Write a stored procedure GetCustomerOrders that:
Accepts a CustomerID as a parameter.
Returns all orders for the specified customer, including their OrderTotal and OrderStatus.*/

CREATE PROCEDURE GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SELECT 
        OrderID,
        CustomerID,
        OrderDate,
        OrderTotal,
        OrderStatus
    FROM Ord
    WHERE CustomerID = @CustomerID;
END;

EXECUTE GetCustomerOrders @CustomerID=1;

/*Task 2: Write a stored procedure UpdateOrderStatus that:
Accepts parameters for OrderID and NewStatus.
Updates the OrderStatus for the given OrderID.
Returns a confirmation message if the update was successful.
Bonus Challenge: Add validation in UpdateOrderStatus to ensure the OrderID exists before updating, 
and return an error message if it doesn't.*/

CREATE PROCEDURE UpdateOrderStatus
    @OrderID INT,
    @NewStatus VARCHAR(20)
AS
BEGIN
    -- Check if the OrderID exists
    IF EXISTS (SELECT 1 FROM Orders WHERE OrderID = @OrderID)
    BEGIN
        -- Update the order status
        UPDATE Ord
        SET OrderStatus = @NewStatus
        WHERE OrderID = @OrderID;

        -- Return confirmation message
        PRINT 'Order status updated successfully.';
    END
    ELSE
    BEGIN
        -- Return error message
        PRINT 'Error: OrderID does not exist.';
    END
END;

EXEC UpdateOrderStatus @OrderID = 102, @NewStatus = 'Delivered';

EXEC UpdateOrderStatus @OrderID = 999, @NewStatus = 'Cancelled';

select * from Ord;


/*Assignment 2: Inventory Stock Management
Objective: Design stored procedures to track and manage product inventory in a warehouse.
Setup:
Create a table named Products with columns: ProductID, ProductName, Category, StockQuantity, Price.*/

-- Create Products table
CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    StockQuantity INT,
    Price DECIMAL(10, 2)
);
INSERT INTO Product (ProductID, ProductName, Category, StockQuantity, Price) VALUES
(1, 'Wireless Mouse', 'Electronics', 15, 499.99),
(2, 'Keyboard', 'Electronics', 5, 999.50),
(3, 'Notebook', 'Stationery', 50, 39.99),
(4, 'Pen', 'Stationery', 3, 9.99),
(5, 'USB Cable', 'Accessories', 8, 149.75);


/*Task 1: Write a stored procedure GetLowStockProducts that:
Retrieves all products with StockQuantity below a specified threshold.
Accepts the threshold value as a parameter.*/

CREATE PROCEDURE GetLowStockProducts
    @Threshold INT
AS
BEGIN
    SELECT ProductID, ProductName, Category, StockQuantity, Price
    FROM Product
    WHERE StockQuantity < @Threshold;
END;

EXEC GetLowStockProducts @Threshold = 6;

select * from Product;

/*Task 2: Write a stored procedure RestockProduct that:
Accepts ProductID and QuantityToAdd as parameters.
Increases the StockQuantity for the specified ProductID.
Returns the updated StockQuantity.
Bonus Challenge: Modify RestockProduct to log the 
restocking activity into a separate table called RestockLog with columns: LogID, ProductID, RestockDate, QuantityAdded.
*/


CREATE TABLE RestockLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    RestockDate DATETIME,
    QuantityAdded INT,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);



CREATE PROCEDURE RestockProduct
    @ProductID INT,
    @QuantityToAdd INT
AS
BEGIN

    UPDATE Product
    SET StockQuantity = StockQuantity + @QuantityToAdd
    WHERE ProductID = @ProductID;

    INSERT INTO RestockLog (ProductID, RestockDate, QuantityAdded)
    VALUES (@ProductID, GETDATE(), @QuantityToAdd);

    SELECT StockQuantity
    FROM Product
    WHERE ProductID = @ProductID;
END;


EXEC RestockProduct @ProductID = 3, @QuantityToAdd = 10;

select * from RestockLog;


