
-- --------------------------------------Supply Chain Insights--------------------------------------

--01.Stock Availability
--ما هي المنتجات اللي مخزونها قليل (Low Stock Products)؟
--KPI: Products تحت حد معين (مثلاً أقل من 100 وحدة).
SELECT 
    pv.ProductID, p.Name as ProductName,
    SUM(Quantity) AS TotalStock
FROM Production.ProductInventory pv inner join Production.Product p 
on pv.ProductID = p.ProductID 
GROUP BY pv.ProductID, p.Name
HAVING SUM(Quantity) < 100
Order By TotalStock;
------------------------------------------------------------------------------------
--02.Inventory Turnover
--(احسب معدل دوران المخزون = (إجمالي تكلفة البضاعة المباعة ÷ متوسط قيمة المخزون)
--الهدف: نعرف هل المخزون بيتحرك بسرعة ولا بطيء.

--COGS query
SELECT SUM(ActualCost * Quantity) AS COGS
FROM Production.TransactionHistory
WHERE TransactionType = 'S';
--Average Inventory at Cost
SELECT AVG(pv.Quantity * p.StandardCost) AS AvgInventoryCost
FROM Production.ProductInventory pv
JOIN Production.Product p
     ON pv.ProductID = p.ProductID;
-- This is the textbook Inventory Turnover Ratio.
--It tells you how many times per period the company “turns over” its inventory.
SELECT
    (SELECT SUM(ActualCost * Quantity)
     FROM Production.TransactionHistory
     WHERE TransactionType = 'S')
    /
    (SELECT AVG(Quantity * StandardCost)
     FROM Production.ProductInventory
     JOIN Production.Product
          ON ProductInventory.ProductID = Product.ProductID)
    AS InventoryTurnover;
------------------------------------------------------------------------------------
--03. Top Suppliers (أكبر المورّدين)
select top(10) * 
from Purchasing.PurchaseOrderHeader
--from Purchasing.PurchaseOrderDetail
--from Purchasing.ProductVendor 
--from Purchasing.Vendor
--1st solution:SUM(TotalDue) total value of purchase orders
select VendorId,  v.Name as VendorName,
		SUM(TotalDue) as TotalPurchases
from Purchasing.PurchaseOrderHeader h inner join Purchasing.Vendor v
on h.vendorID = v.BusinessEntityID
Group by VendorID, v.Name
Order by TotalPurchases desc
-- 2nd solution: SUM(LineTotal)If you want only the merchandise cost (ignoring freight, taxes, etc.)
SELECT 
    h.VendorID,
    SUM(d.LineTotal) AS TotalPurchases
FROM Purchasing.PurchaseOrderHeader h
JOIN Purchasing.PurchaseOrderDetail d 
    ON h.PurchaseOrderID = d.PurchaseOrderID
GROUP BY h.VendorID
ORDER BY TotalPurchases DESC;
------------------------------------------------------------------------------------
--04. Supply vs Demand Gap 
--(فجوة العرض والطلب)

WITH Demand AS ( --total units sold
    SELECT
        ProductID,
        SUM(OrderQty) AS TotalUnitsSold
    FROM Sales.SalesOrderDetail
    GROUP BY ProductID
),
Supply AS ( --total units currently stored
    SELECT
        ProductID,
        SUM(Quantity) AS TotalStoredProducts
    FROM Production.ProductInventory
    GROUP BY ProductID
)
SELECT
    COALESCE(d.ProductID, s.ProductID) AS ProductID,
    ISNULL(d.TotalUnitsSold, 0) AS TotalUnitsSold,
    ISNULL(s.TotalStoredProducts, 0) AS TotalStoredProducts,
    ISNULL(s.TotalStoredProducts, 0) - ISNULL(d.TotalUnitsSold, 0) AS SupplyDemandGap
FROM Demand d
FULL JOIN Supply s
       ON d.ProductID = s.ProductID
ORDER BY SupplyDemandGap;
--Result: SupplyDemandGap → positive = more stock than sold (surplus),
--negative = sold more than current stock (potential shortage).
------------------------------------------------------------------------------------
--05. Cost of Goods Purchased 
--(تكلفة المشتريات)

select Year(h.OrderDate) as PurchaseYear,
		Month(h.OrderDate)as PurchaseMonth,
		sum(LineTotal) as TotalPurchases
from Purchasing.PurchaseOrderDetail d 
Join Purchasing.PurchaseOrderHeader h
	ON d.PurchaseOrderID = h.PurchaseOrderID
group by Year(h.OrderDate), Month(h.OrderDate)
order by Year(h.OrderDate), Month(h.OrderDate);
------------------------------------------------------------------------------------
--6. Backordered Items 
--(طلبات مؤجلة بسبب نقص المخزون)
SELECT 
    sod.SalesOrderID,
    sod.SalesOrderDetailID,
    sod.ProductID,
    sod.OrderQty,
    inv.TotalStock,
    sod.OrderQty - inv.TotalStock AS BackorderedQty
FROM Sales.SalesOrderDetail sod
JOIN (
    SELECT ProductID, SUM(Quantity) AS TotalStock
    FROM Production.ProductInventory
    GROUP BY ProductID
) inv
    ON sod.ProductID = inv.ProductID
WHERE sod.OrderQty > inv.TotalStock;
------------------------------------------------------------------------------------

--helper insights 

-------- Production ------------
select  Top(10) *
from Production.Product
-------- purchasing ------------
select  Top(10) *
from Purchasing.PurchaseOrderHeader

select  Top(10) *
from Purchasing.PurchaseOrderDetail 

select  Top(10) *
from Production.ProductInventory

select  Top(10) *
from Production.TransactionHistory

select  Top(10) *
from Purchasing.ProductVendor 
----------------------------
SELECT TransactionType, COUNT(*) AS RowsCount
FROM Production.TransactionHistory
GROUP BY TransactionType;

select sum(orderQty)
from sales.SalesOrderDetail

--Performance Optimization
-- Add indexes for better performance
CREATE NONCLUSTERED INDEX IX_OrderDate 
ON Sales.SalesOrderHeader(OrderDate) INCLUDE (TotalDue, CustomerID);

CREATE NONCLUSTERED INDEX IX_ProductID 
ON Sales.SalesOrderDetail(ProductID) INCLUDE (OrderQty, LineTotal);