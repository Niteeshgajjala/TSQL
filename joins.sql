
/* Create a SQL query that will return all employees with "Sales" at the start of their job 
titles. Return the columns for job title, last name, middle name, and first name.*/

SELECT 
e.JobTitle,
p.FirstName,
p.MiddleName,
p.LastName
FROM 
HumanResources.Employee e
JOIN 
Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE 
e.JobTitle LIKE 'Sales%';


/* To find out if any of the current customers have placed an order or not, create a report 
using the following SQL statement: customer name, city, order number, order date, and order
amount in ascending order based on the order date.*/

SELECT 
    CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName,
    a.City,
    soh.SalesOrderNumber AS OrderNumber,
    soh.OrderDate,
    soh.TotalDue AS OrderAmount
FROM 
    Sales.Customer AS c
INNER JOIN 
    Person.Person AS p ON c.PersonID = p.BusinessEntityID
LEFT JOIN 
    Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
LEFT JOIN 
    Person.BusinessEntityAddress AS bea ON p.BusinessEntityID = bea.BusinessEntityID
LEFT JOIN 
    Person.Address AS a ON bea.AddressID = a.AddressID
ORDER BY 
    soh.OrderDate ASC;







/*Write a SQL query to find those orders where the order amount exists between 500 and 2000. 
Return ord_no, purch_amt, cust_name, city.*/
SELECT 
soh.SalesOrderNumber AS ord_no,
soh.TotalDue AS purch_amt,
CONCAT(p.FirstName, ' ', p.LastName) AS cust_name,
a.City
FROM 
Sales.SalesOrderHeader AS soh
INNER JOIN 
Sales.Customer AS c ON soh.CustomerID = c.CustomerID
INNER JOIN 
Person.Person AS p ON c.PersonID = p.BusinessEntityID
INNER JOIN 
Person.BusinessEntityAddress AS bea ON p.BusinessEntityID = bea.BusinessEntityID
INNER JOIN 
Person.Address AS a ON bea.AddressID = a.AddressID
WHERE 
soh.TotalDue BETWEEN 500 AND 2000
ORDER BY 
soh.TotalDue;




/*Create a SQL query to compare employees' year-to-date sales. Return TerritoryName, SalesYTD,
BusinessEntityID, and Sales from the prior year (PrevRepSales). 
The results are sorted by territorial name in ascending order.*/

SELECT 
st.Name AS TerritoryName,
sp.SalesYTD,
sp.BusinessEntityID,
sp.SalesLastYear AS PrevRepSales
FROM 
Sales.SalesPerson sp
JOIN Sales.SalesTerritory st 
ON sp.TerritoryID = st.TerritoryID
ORDER BY 
st.Name ASC;

/*3. Write a SQL query to calculate the difference between the maximum salary and the salary 
of all the employees who work in the department of ID 80. Return job title, employee name 
and salary difference.*/

SELECT 
    e.JobTitle,
    p.FirstName + ' ' + p.LastName AS EmployeeName,
    (
        SELECT MAX(eph2.Rate)
        FROM HumanResources.EmployeePayHistory eph2
        JOIN HumanResources.Employee e2 ON eph2.BusinessEntityID = e2.BusinessEntityID
        JOIN HumanResources.EmployeeDepartmentHistory edh2 ON e2.BusinessEntityID = edh2.BusinessEntityID
        JOIN HumanResources.Department d2 ON edh2.DepartmentID = d2.DepartmentID
        WHERE d2.DepartmentID = 16
    ) - eph.Rate AS SalaryDifference
FROM 
    HumanResources.EmployeePayHistory eph
JOIN HumanResources.Employee e ON eph.BusinessEntityID = e.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE d.DepartmentID = 16;


/* To list every salesperson, along with the customer's name, city, grade, order number, date, 
and amount, create a SQL query.
Requirement for choosing the salesmen's list:
Salespeople who work for one or more clients, or  Salespeople who haven't joined any clients yet.
Requirements for choosing a customer list:
placed one or more orders with their salesman, or  didn't place any orders.*/

SELECT 
    sp.BusinessEntityID AS SalespersonID,
    spPerson.FirstName + ' ' + spPerson.LastName AS Salesperson,
    c.CustomerID,
    custPerson.FirstName + ' ' + custPerson.LastName AS CustomerName,
    addr.City,
    c.StoreID,
    soh.SalesOrderNumber,
    soh.OrderDate,
    soh.TotalDue
FROM 
    Sales.SalesPerson sp
LEFT JOIN Sales.SalesOrderHeader soh ON sp.BusinessEntityID = soh.SalesPersonID
LEFT JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
LEFT JOIN Person.Person custPerson ON c.PersonID = custPerson.BusinessEntityID
LEFT JOIN Person.BusinessEntityAddress custBEA ON c.PersonID = custBEA.BusinessEntityID
LEFT JOIN Person.Address addr ON custBEA.AddressID = addr.AddressID
LEFT JOIN Person.Person spPerson ON sp.BusinessEntityID = spPerson.BusinessEntityID
ORDER BY sp.BusinessEntityID;



/* Write a SQL query to locate those salespeople who do not live in the same city where their 
customers live and have received a commission of more than 12% from the company. 
Return Customer Name, customer city, Salesman, salesman city, commission.*/

SELECT DISTINCT
    custPerson.FirstName + ' ' + custPerson.LastName AS CustomerName,
    custAddr.City AS CustomerCity,
    salesPerson.FirstName + ' ' + salesPerson.LastName AS SalesmanName,
    salesAddr.City AS SalesmanCity,
    salesRep.CommissionPct  AS Commission
FROM Sales.SalesOrderHeader salesOrder
JOIN Sales.Customer cust ON salesOrder.CustomerID = cust.CustomerID
JOIN Sales.SalesPerson salesRep ON salesOrder.SalesPersonID = salesRep.BusinessEntityID
JOIN Person.Person salesPerson ON salesRep.BusinessEntityID = salesPerson.BusinessEntityID
JOIN Person.Person custPerson ON cust.PersonID = custPerson.BusinessEntityID

JOIN Person.BusinessEntityAddress custBEA ON cust.StoreID = custBEA.BusinessEntityID
JOIN Person.Address custAddr ON custBEA.AddressID = custAddr.AddressID

JOIN Person.BusinessEntityAddress salesBEA ON salesRep.BusinessEntityID = salesBEA.BusinessEntityID
JOIN Person.Address salesAddr ON salesBEA.AddressID = salesAddr.AddressID

WHERE custAddr.City <> salesAddr.City
  AND salesRep.CommissionPct > 0.12;
