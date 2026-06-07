
--Q1. List top 5 customers by total order amount.
--Retrieve the top 5 customers who have spent the most across all sales orders. Show CustomerID, CustomerName, and TotalSpent.

Select C.CustomerID,C.Name as CustomerName,T.TotalSpend from (Select top 5 SO.CustomerID, Sum(TotalAmount)as [TotalSpend] from SalesOrder SO
group by SO.CustomerID
order by 1 desc)
as T inner join Customer C on C.CustomerID =T.CustomerID

--Q2. Find the number of products supplied by each supplier.
--Display SupplierID, SupplierName, and ProductCount. Only include suppliers that have more than 10 products.

SELECT 
    s.SupplierID,
    s.Name AS SupplierName,
    COUNT(DISTINCT pod.ProductID) AS ProductCount
FROM dbo.Supplier s
JOIN dbo.PurchaseOrder po 
    ON s.SupplierID = po.SupplierID
JOIN dbo.PurchaseOrderDetail pod 
    ON po.OrderID = pod.OrderID
GROUP BY 
    s.SupplierID, 
    s.Name
HAVING COUNT(DISTINCT pod.ProductID) > 10;


--Q3. Identify products that have been ordered but never returned.
--Show ProductID, ProductName, and total order quantity.

SELECT
    p.ProductID,
    p.Name        AS ProductName,
    SUM(sod.Quantity) AS TotalOrderedQuantity
FROM dbo.[Product]       p
JOIN dbo.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE p.ProductID NOT IN (
    SELECT DISTINCT ProductID
    FROM  dbo.ReturnDetail
)
GROUP BY
    p.ProductID,
    p.Name

--    Q4. For each category, find the most expensive product.
--Display CategoryID, CategoryName, ProductName, and Price. Use a subquery to get the max price per category.


With CategoryWithMaxPrice AS (
Select MAX(Price) as maxprice,c.CategoryID,C.Name from [Product] p
inner join Category C on p.CategoryID =C.CategoryID
group by C.CategoryID,C.Name
)
Select CMP.CategoryID,CMP.Name as CategoryName ,p.Name as ProductName, CMP.maxprice from CategoryWithMaxPrice CMP
inner join [Product] p on p.CategoryID= CMP.CategoryID and p.Price=CMP.maxprice
order by CMP.CategoryID

--Form Subquery
Select res.CategoryID,res.Name as CategoryName ,p.Name as ProductName, res.maxprice from  (Select MAX(Price) as maxprice,c.CategoryID,C.Name from [Product] p
inner join Category C on p.CategoryID =C.CategoryID
group by C.CategoryID,C.Name)
as res inner join [Product] p on res.CategoryID=p.CategoryID and p.Price=res.maxprice
order by CategoryID

--Q5. List all sales orders with customer name, product name, category, and supplier.
--For each sales order, display:
--OrderID, CustomerName, ProductName, CategoryName, SupplierName, and Quantity.

SELECT
    so.OrderID,cu.Name AS CustomerName, p.Name AS ProductName,cat.Name AS CategoryName,s.Name AS SupplierName,
    sod.Quantity
FROM  dbo.SalesOrder so
JOIN  dbo.Customer   cu  ON so.CustomerID  = cu.CustomerID
JOIN  dbo.SalesOrderDetail     sod ON so.OrderID     = sod.OrderID
JOIN  dbo.Product   p   ON sod.ProductID  = p.ProductID
JOIN  dbo.Category  cat ON p.CategoryID   = cat.CategoryID
JOIN  dbo.PurchaseOrderDetail  pod ON p.ProductID    = pod.ProductID
JOIN  dbo.PurchaseOrder  po  ON pod.OrderID    = po.OrderID
JOIN  dbo.Supplier       s   ON po.SupplierID  = s.SupplierID
ORDER BY so.OrderID;

--Q6. Find all shipments with details of warehouse, manager, and products shipped.
--Display:
--ShipmentID, WarehouseName, ManagerName, ProductName, QuantityShipped, and TrackingNumber.

SELECT
    sh.ShipmentID,
    l.Name AS WarehouseName,
    e.Name AS ManagerName,
    p.Name AS ProductName,
    sd.Quantity  AS QuantityShipped,
    sh.TrackingNumber
FROM  dbo.Shipment        sh
JOIN  dbo.Warehouse       w  ON sh.WarehouseID = w.WarehouseID
Join dbo.[Location] l on l.LocationID=w.LocationID
JOIN  dbo.Employee        e  ON w.ManagerID    = e.EmployeeID
JOIN  dbo.ShipmentDetail  sd ON sh.ShipmentID  = sd.ShipmentID
JOIN  dbo.Product         p  ON sd.ProductID   = p.ProductID
ORDER BY sh.ShipmentID;


--Q7. Find the top 3 highest-value orders per customer using RANK(). Display CustomerID, CustomerName, OrderID, and TotalAmount.
WITH RankedOrders AS (
    SELECT
        c.CustomerID,
        c.Name         AS CustomerName,
        so.OrderID,
        so.TotalAmount,
        RANK() OVER (
            PARTITION BY c.CustomerID
            ORDER BY     so.TotalAmount DESC
        ) AS rnk
    FROM  dbo.Customer   c
    JOIN  dbo.SalesOrder so ON c.CustomerID = so.CustomerID
)
SELECT
    CustomerID,
    CustomerName,
    OrderID,
    TotalAmount
FROM  RankedOrders
WHERE rnk <= 3
ORDER BY CustomerID, rnk;


--Q8. For each product, show its sales history with the previous and next sales quantities (based on order date). Display
--ProductID, ProductName, OrderID, OrderDate, Quantity, PrevQuantity, and NextQuantity.

SELECT
    p.ProductID,
    p.Name AS ProductName,
    so.OrderID,
    so.OrderDate,
    sod.Quantity,
    null AS PrevQuantity,
   null AS NextQuantity
FROM  dbo.Product            p
JOIN  dbo.SalesOrderDetail   sod ON p.ProductID  = sod.ProductID
JOIN  dbo.SalesOrder         so  ON sod.OrderID  = so.OrderID
ORDER BY p.ProductID, so.OrderDate, so.OrderID;


--Q9. Create a view named vw_CustomerOrderSummary that shows for each customer:
--CustomerID, CustomerName, TotalOrders, TotalAmountSpent, and LastOrderDate.

CREATE VIEW dbo.vw_CustomerOrderSummary
AS
SELECT
    c.CustomerID,
    c.Name                    AS CustomerName,
    COUNT(so.OrderID)         AS TotalOrders,
    SUM(so.TotalAmount)       AS TotalAmountSpent,
    MAX(so.OrderDate)         AS LastOrderDate
FROM  dbo.Customer    c
LEFT JOIN dbo.SalesOrder so ON c.CustomerID = so.CustomerID
GROUP BY
    c.CustomerID,
    c.Name;



    --Q10. Write a stored procedure sp_GetSupplierSales that takes a SupplierID as input and returns the total 
    --sales amount for all products supplied by that supplier.

    Create PROCEDURE dbo.sp_GetSupplierSales
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Supplier WHERE SupplierID = @SupplierID)
    BEGIN
        RAISERROR('Supplier with given ID does not exist.', 16, 1);
        RETURN;
    END

    SELECT
        s.SupplierID,
        s.Name                          AS SupplierName,
        COUNT(DISTINCT pod.ProductID)   AS TotalProductsSupplied,
        COUNT(DISTINCT so.OrderID)      AS TotalSalesOrders,
        SUM(sod.TotalAmount)            AS TotalSalesAmount
    FROM       dbo.Supplier              s
    JOIN       dbo.PurchaseOrder         po  ON s.SupplierID  = po.SupplierID
    JOIN       dbo.PurchaseOrderDetail   pod ON po.OrderID    = pod.OrderID
    JOIN       dbo.SalesOrderDetail      sod ON pod.ProductID = sod.ProductID
    JOIN       dbo.SalesOrder            so  ON sod.OrderID   = so.OrderID
    WHERE      s.SupplierID = @SupplierID
    GROUP BY
        s.SupplierID,
        s.Name;

END;

