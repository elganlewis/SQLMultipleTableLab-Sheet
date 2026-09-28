-- QUERIES TO TRY
-- 1. What are the names of employees in the Marketing Department?
SELECT EmployeeName
FROM Employee
WHERE DepartmentName = 'Marketing';

-- 2. Find the items sold by the departments on the second floor.
SELECT DISTINCT ItemName
FROM Sale,
    Department
WHERE Sale.DepartmentName = Department.DepartmentName
    AND Department.DepartmentFloor = 2;

-- Note that this query performs an equijoin on Sale and Department.
SELECT *
FROM (
        Sale
        NATURAL JOIN Department
    )
WHERE Department.DepartmentFloor = 2;

-- 3. Identify by floor the items available on floors other than the second floor
SELECT DISTINCT ItemName,
    Department.DepartmentFloor AS 'On Floor'
FROM Delivery,
    Department
WHERE Delivery.DepartmentName = Department.DepartmentName
    AND Department.DepartmentFloor <> 2
ORDER BY Department.DepartmentFloor,
    ItemName;

-- 4. Find the average salary of the employees in the Clothes department
SELECT AVG(EmployeeSalary)
FROM Employee
WHERE DepartmentName = 'Clothes';

-- 5. Find, for each department, the average salary of the employees in that department and report by descending salary.
SELECT DepartmentName,
    AVG(EmployeeSalary) AS AverageSalary
FROM Employee
GROUP BY DepartmentName
ORDER BY AverageSalary DESC;

-- 6. List the items delivered by exactly one supplier (i.e. the items always delivered by the same supplier).
SELECT ItemName
FROM Delivery
GROUP BY ItemName
HAVING COUNT(DISTINCT SupplierNumber) = 1;

-- 7. List the suppliers that deliver at least 10 items.
SELECT Supplier.SupplierNumber,
    Supplier.SupplierName
FROM Delivery,
    Supplier
WHERE Delivery.SupplierNumber = Supplier.SupplierNumber
GROUP BY Supplier.SupplierNumber,
    Supplier.SupplierName
HAVING COUNT(DISTINCT Delivery.ItemName) >= 10;

-- 8. Count the number of direct employees of each manager
SELECT Boss.EmployeeNumber,
    Boss.EmployeeName,
    COUNT(*) AS 'Employees'
FROM Employee AS Worker,
    Employee AS Boss
WHERE Worker.BossNumber = Boss.EmployeeNumber
GROUP BY Boss.EmployeeNumber,
    Boss.EmployeeName;

-- 9. Find, for each department that sells items of type 'E' the average salary of the employees.
SELECT Department.DepartmentName,
    AVG(EmployeeSalary) AS 'Average Salary'
FROM Employee,
    Department,
    Sale,
    Item
WHERE Employee.DepartmentName = Department.DepartmentName
    AND Department.DepartmentName = Sale.DepartmentName
    AND Sale.ItemName = Item.ItemName
    AND ItemType = 'E'
GROUP BY Department.DepartmentName;

-- 10. Find the total number of items of type 'E' sold by departments on the second floor
SELECT SUM(SaleQuantity) AS 'Number of Items'
FROM Department,
    Sale,
    Item
WHERE Department.DepartmentName = Sale.DepartmentName
    AND Sale.ItemName = Item.ItemName
    AND ItemType = 'E'
    AND DepartmentFloor = '2';

-- 11. What is the average delivery quantity of items of type 'N' delivered by each company?
SELECT Delivery.SupplierNumber,
    SupplierName,
    Delivery.ItemName,
    AVG(Delivery.DeliveryQuantity) AS 'Average Quantity'
FROM (
        (
            Delivery
            NATURAL JOIN Supplier
        )
        NATURAL JOIN Item
    )
WHERE Item.ItemType = 'N'
GROUP BY Delivery.SupplierNumber,
    SupplierName,
    Delivery.ItemName
ORDER BY Delivery.SupplierNumber,
    SupplierName,
    'Average Quantity' DESC,
    Delivery.ItemName;

-- NESTED QUERIES
-- 1. What are the names of items sold by departments on the second floor? This was previously solved in the preceding section by the use of a join. However, it could be more efficiently solved by using an inner query:
SELECT DISTINCT ItemName
FROM Sale
WHERE DepartmentName IN (
        SELECT DepartmentName
        FROM Department
        WHERE DepartmentFloor = 2
    );

-- 2. Find the salary of Clare's manager.
SELECT EmployeeName,
    EmployeeSalary
FROM Employee
WHERE EmployeeNumber = (
        SELECT BossNumber
        FROM Employee
        WHERE EmployeeName = 'Clare'
    );

-- 3. Find the name and salary of the managers with more than two employees 
SELECT EmployeeName,
    EmployeeSalary
FROM Employee
WHERE EmployeeNumber IN (
        SELECT BossNumber
        FROM Employee
        GROUP BY BossNumber
        HAVING COUNT(*) > 2
    );

-- 4. List the names of the employees who earn more than any employee in the Marketing department 
SELECT EmployeeName,
    EmployeeSalary
FROM Employee
WHERE EmployeeSalary > (
        SELECT MAX(EmployeeSalary)
        FROM Employee
        WHERE DepartmentName = 'Marketing'
    );

-- 5. Among all the departments with a total salary greater than £25000, find the departments that sell Stetsons. 
SELECT DISTINCT DepartmentName
FROM Sale
WHERE ItemName = 'Stetsons'
    AND DepartmentName IN (
        SELECT DepartmentName
        FROM Employee
        GROUP BY DepartmentName
        HAVING SUM(EmployeeSalary) > 25000
    );

-- 6. Find the suppliers that deliver compasses and at least one other kind of item 
SELECT DISTINCT Delivery.SupplierNumber,
    Supplier.SupplierName
FROM (
        Supplier
        NATURAL JOIN Delivery
    )
WHERE (
        ItemName <> 'Compass'
        AND SupplierNumber IN (
            SELECT SupplierNumber
            FROM Delivery
            WHERE ItemName = 'Compass'
        )
    );

-- 7. Find the suppliers that deliver compasses and at least three other kinds of item 
SELECT DISTINCT Delivery.SupplierNumber,
    Supplier.SupplierName
FROM (
        Supplier
        NATURAL JOIN Delivery
    )
WHERE SupplierNumber IN (
        SELECT SupplierNumber
        FROM Delivery
        WHERE ItemName = 'Compass'
    )
GROUP BY Delivery.SupplierNumber,
    Supplier.SupplierName
HAVING COUNT(DISTINCT ItemName) > 3;

-- 8. List the departments for which each item delivered to the department is delivered to some other department as well 
SELECT DISTINCT DepartmentName
FROM Delivery AS Delivery1
WHERE NOT EXISTS (
        SELECT *
        FROM Delivery AS Delivery2
        WHERE Delivery2.DepartmentName = Delivery1.DepartmentName
            AND ItemName NOT IN (
                SELECT ItemName
                FROM Delivery AS Delivery3
                WHERE Delivery3.DepartmentName <> Delivery1.DepartmentName
            )
    );