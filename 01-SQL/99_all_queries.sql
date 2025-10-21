use AdventureWorks2022

-- --------------------------------------Sales Performance Analysis--------------------------------------

--01.What is the total sales (value) and the total number of orders during the available period?  
--ما هو إجمالي المبيعات (بالقيمة) و إجمالي عدد الطلبات خلال الفترة المتاحة؟
SELECT 
    SUM(TotalDue) AS [Total Sales],
    COUNT(DISTINCT SalesOrderID) AS [Total Orders]
FROM Sales.SalesOrderHeader;
------------------------------------------------------------------------------------
--02.What are the total sales and total orders by year?  
--ما هو إجمالي المبيعات وإجمالي الطلبات لكل سنة ؟
SELECT 
	Year(OrderDate) AS [OderYear],
    SUM(TotalDue) AS [Total Sales],
    COUNT(DISTINCT SalesOrderID) AS [Total Orders]
FROM Sales.SalesOrderHeader
Group by Year(OrderDate)
Order by Year(OrderDate);
--(with CTE)
WITH OrderYears AS (
	SELECT
		Year(OrderDate) AS OderYear,
		TotalDue,
	   SalesOrderID
   FROM Sales.SalesOrderHeader
)
select OderYear,
    SUM(TotalDue) AS [Total Sales],
    COUNT(DISTINCT SalesOrderID) AS [Total Orders]
from OrderYears
Group by OderYear
Order by OderYear;
------------------------------------------------------------------------------------
--03.What are the top 10 products by both sales value and quantity?
--if want to top 10 products by quantity will be ORDER BY TotalSalesQuantity DESC
--ما هي أعلى 10 منتجات مبيعًا بالقيمة وبالكمية؟
SELECT TOP 10
    d.ProductID,
    p.Name AS ProductName,
    SUM(d.LineTotal) AS TotalSalesValue,
    SUM(d.OrderQty) AS TotalSalesQuantity
FROM Sales.SalesOrderDetail d
JOIN Production.Product p 
    ON d.ProductID = p.ProductID
GROUP BY d.ProductID, p.Name
ORDER BY TotalSalesValue DESC;  
------------------------------------------------------------------------------------
--04.What are the top 10 orders by sales value only?  
--ما هي أعلى 10 طلبات مبيعًا بالقيمة فقط ؟
select *
from 
	(   SELECT SalesOrderID, OrderDate, TotalDue , ROW_NUMBER() over (order by TotalDue desc) as RN
		from  Sales.SalesOrderHeader
	)  AS t
where RN <= 10
------------------------------------------------------------------------------------
--05.What are the top 10 orders by sales quantity only?
--ما هي أعلى 10 طلبات مبيعًا بالكمية فقط ؟
SELECT TOP 10
    h.SalesOrderID,
    h.OrderDate,
    h.TotalDue AS TotalSales,  
    SUM(d.OrderQty) AS TotalQuantity
FROM Sales.SalesOrderHeader h
JOIN Sales.SalesOrderDetail d
    ON h.SalesOrderID = d.SalesOrderID
GROUP BY h.SalesOrderID, h.OrderDate, h.TotalDue
ORDER BY TotalQuantity DESC;
--06.What are the top 10 orders by sales value and view their quantity?  
--ما هي أعلى 10 طلبات مبيعًا بالقيمة واعرض الكمية ؟
SELECT TOP 10
    h.SalesOrderID,
    h.OrderDate,
    h.TotalDue AS TotalSales,  
    SUM(d.OrderQty) AS TotalQuantity
FROM Sales.SalesOrderHeader h
JOIN Sales.SalesOrderDetail d
    ON h.SalesOrderID = d.SalesOrderID
GROUP BY h.SalesOrderID, h.OrderDate, h.TotalDue
ORDER BY h.TotalDue DESC;
------------------------------------------------------------------------------------
--07.What are the monthly sales trends?  
-- a.Total sales for each month  
-- b.Comparison with the previous month (MoM %)  
--ما هي الاتجاهات الشهرية للمبيعات؟
--إجمالي مبيعات كل شهر
--مقارنة مع الشهر السابق (MoM %)
------------------Solution----------------
-- a.Total sales for each month  
--إجمالي مبيعات كل شهر
SELECT 
	Year(OrderDate),
	Month(OrderDate) AS [OrderMonth],
	FORMAT(OrderDate, 'MMM' ) AS [MonthName],
    SUM(TotalDue) AS [Total Sales],
    COUNT(DISTINCT SalesOrderID) AS [Total Orders]
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), Month(OrderDate), FORMAT(OrderDate, 'MMM')
ORDER BY YEAR(OrderDate), Month(OrderDate);

-- b.Comparison with the previous month (MoM %)  
-- --------------------1st solution--------------------
WITH SalesByDate AS (
    SELECT  
        YEAR(OrderDate) AS OrderYear, 
        MONTH(OrderDate) AS OrderMonth, 
        SUM(TotalDue) AS TotalSales
    FROM sales.SalesOrderHeader
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT 
    s.*,
    LAG(TotalSales) OVER (ORDER BY OrderYear, OrderMonth) AS PreviousMonthSales,
    LEAD(TotalSales) OVER (ORDER BY OrderYear, OrderMonth) AS NextMonthSales,
    ISNULL(
        ((s.TotalSales - LAG(TotalSales) OVER (ORDER BY OrderYear, OrderMonth)) * 1.0 
        / NULLIF(LAG(TotalSales) OVER (ORDER BY OrderYear, OrderMonth), 0)) * 100,
        0
    ) AS [MOM%]
FROM SalesByDate s
ORDER BY s.OrderYear, s.OrderMonth;
-- --------------------2nd solution--------------------
WITH SalesByDate AS (
    SELECT  
        YEAR(OrderDate) AS OrderYear, 
        MONTH(OrderDate) AS OrderMonth, 
        SUM(TotalDue) AS TotalSales
    FROM sales.SalesOrderHeader
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
),
SalesWithLag AS (
    SELECT 
        OrderYear,
        OrderMonth,
        TotalSales,
        LAG(TotalSales) OVER (ORDER BY OrderYear, OrderMonth) AS PreviousMonthSales
    FROM SalesByDate
)
SELECT 
    OrderYear,
    OrderMonth,
    TotalSales,
    PreviousMonthSales,
    (TotalSales - PreviousMonthSales) * 1.0 / NULLIF(PreviousMonthSales, 0) AS MoM
FROM SalesWithLag
ORDER BY OrderYear, OrderMonth;
------------------------------------------------------------------------------------
--08.What are the yearly sales trends?  
-- a.Total sales for each year  
-- b.Comparison with the previous year (YoY %)   
--ما هي الاتجاهات السنوية للمبيعات؟
--إجمالي مبيعات كل سنة
--مقارنة مع السنة السابقة (YoY %)
------------------Solution----------------
-- a.Total sales for each year  
SELECT 
	YEAR(OrderDate) AS [OderYEAR],
    SUM(TotalDue) AS [Total Sales],
    COUNT(DISTINCT SalesOrderID) AS [Total Orders]
FROM Sales.SalesOrderHeader
Group by YEAR(OrderDate)
Order by YEAR(OrderDate);
-- b.Comparison with the previous year (YoY %)   
WITH SalesByDate AS (
    SELECT  
        YEAR(OrderDate) AS OrderYear, 
        SUM(TotalDue) AS TotalSales
    FROM sales.SalesOrderHeader
    GROUP BY YEAR(OrderDate)
),
--select * from SalesByDate
SalesWithLag AS (
    SELECT 
        OrderYear,
        TotalSales,
        LAG(TotalSales) OVER (ORDER BY OrderYear) AS PreviousYearSales
    FROM SalesByDate
)
SELECT 
    OrderYear,
    TotalSales,
    PreviousYearSales,
    (TotalSales - PreviousYearSales) * 1.0 / NULLIF(PreviousYearSales, 0) AS YoY
FROM SalesWithLag
ORDER BY OrderYear;
------------------------------------------------------------------------------------
--09.Who are the top 5 customers by total spending?  
--ما هي أفضل 5 عملاء من حيث الإنفاق الكلي؟
Select Top(5) c.PersonID, p.FirstName, p.LastName, Sum(h.TotalDue) as TotalSales --h.SalesOrderID, h.OrderDate 
From sales.SalesOrderHeader h 
	Join sales.Customer c on h.CustomerID=c.CustomerID
	Join Person.Person p on c.PersonID=p.BusinessEntityID
Group by c.PersonID, p.FirstName, p.LastName
Order by TotalSales Desc;
------------------------------------------------------------------------------------
--10.What are the top territories (geographic regions) by sales?  
--ما هي أفضل المناطق الجغرافية من حيث المبيعات؟ 
Select t.Name, Sum(h.TotalDue) as TotalSales
From sales.SalesOrderHeader h 
	Join sales.SalesTerritory t on h.TerritoryID=t.TerritoryID
Group by t.Name
Order by TotalSales Desc;
------------------------------------------------------------------------------------
--11.What is the average order value (AOV) per year?  
--ما هو متوسط قيمة الطلب الواحد  لكل سنة
SELECT 
    YEAR(OrderDate) AS OrderYear,
    SUM(TotalDue) * 1.0 / COUNT(DISTINCT SalesOrderID) AS AOV
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear;

------------------------------------------------------------------------------------
--12.What is the sales distribution by categories (which product category sells the most)?  
--ما هو التوزيع حسب الفئات أي فئة منتجات بتبيع أكتر
--(Product Categories)
Select pc.Name AS Category, Sum(d.LineTotal) AS TotalSales--d.SalesOrderDetailID, p.Name AS Product, psc.Name AS SubCategory, pc.Name AS Category
From sales.SalesOrderDetail d
	Join Production.Product p on d.ProductID=p.ProductID
	Join Production.ProductSubcategory psc on p.ProductSubcategoryID= psc.ProductSubcategoryID
	Join Production.ProductCategory pc on psc.ProductCategoryID = pc.ProductCategoryID
Group by pc.Name
Order by TotalSales Desc;
------------------------------------------------------------------------------------
--Sales Forecasting Base
-- Prepare data for forecasting models
WITH MonthlySales AS (
    SELECT 
        YEAR(OrderDate) AS Year,
        MONTH(OrderDate) AS Month,
        SUM(TotalDue) AS Revenue,
        COUNT(DISTINCT SalesOrderID) AS Orders,
        AVG(TotalDue) AS AvgOrderValue
    FROM Sales.SalesOrderHeader
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT *,
    AVG(Revenue) OVER (
        ORDER BY Year, Month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS Moving_Avg_3M,
    LAG(Revenue, 12) OVER (ORDER BY Year, Month) AS Same_Month_Last_Year
FROM MonthlySales
ORDER BY Year, Month;
------------------------------------------------------------------------------------

-- --------------------------------------Customer Segmentation--------------------------------------
--1.Top Customers by Frequency
--	مين أكتر 10 عملاء عملوا عدد طلبات (Orders) أكبر؟
--	الهدف: نعرف مين العملاء الـ loyal.
Select Top(10) c.PersonID,
				p.FirstName,
				p.LastName,
				Sum(h.TotalDue) as TotalSales,
				AVG(h.TotalDue) as AvgOrderValue,
				count(distinct h.SalesOrderID) As #Orders
From sales.SalesOrderHeader h 
	Join sales.Customer c on h.CustomerID=c.CustomerID
	Join Person.Person p on c.PersonID=p.BusinessEntityID
Group by c.PersonID, p.FirstName, p.LastName
Order by #Orders Desc;
------------------------------------------------------------------------------------
--2.Top Customers by Value (CLV - Customer Lifetime Value)
--	إجمالي المبيعات (Total Sales) لكل عميل عبر كل الفترات.
Select Top(5) c.PersonID,
				p.FirstName,
				p.LastName,
				count(distinct h.SalesOrderID) As #Orders,
				Sum(h.TotalDue) as TotalSales
From sales.SalesOrderHeader h 
	Join sales.Customer c on h.CustomerID=c.CustomerID
	Join Person.Person p on c.PersonID=p.BusinessEntityID
Group by c.PersonID, p.FirstName, p.LastName
Order by TotalSales Desc;
------------------------------------------------------------------------------------
--3.Customer Segmentation by RFM (Recency, Frequency, Monetary)
--Recency = آخر تاريخ طلب للعميل.
--Frequency = عدد الطلبات.
--Monetary = إجمالي إنفاق العميل.
--اعمل جدول يلخص الـ 3 أبعاد لكل عميل.

--1st solution Basic Solution
--Segmentation labels (
-- Recency:[Recent/Active/Churned], Frequency:[Loyal/Regular/Occasional], Monetary:[High/Medium/Low])

-- Problem: Your data is historical (ends 2014)
-- ❌ WRONG
--DATEDIFF(DAY, MAX(h.OrderDate), GETDATE()) AS Recency
-- ✅ CORRECT - Use last date in dataset
--DECLARE @MaxDate DATE = (SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader);
DECLARE @MaxDate DATE = (SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader);
With RFM AS(
	SELECT  
		c.PersonID,
		p.FirstName,
		p.LastName,
		DATEDIFF(DAY, MAX(h.OrderDate), @MaxDate) AS Recency, --DaysSinceLastOrder
		COUNT(DISTINCT h.SalesOrderID) AS Frequency,
		SUM(h.TotalDue) AS Monetary,
		MAX(h.OrderDate) AS RecentOrderDate
	FROM Sales.SalesOrderHeader h
	JOIN Sales.Customer c ON h.CustomerID = c.CustomerID
	JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
	GROUP BY c.PersonID, p.FirstName, p.LastName
)
Select *,
		CASE 
			When Recency <= 30 Then 'Recent'
			When Recency <= 90 Then 'Active'
			Else 'Churned'
		End as RecenySegment,
		CASE 
			When Frequency >= 10 Then 'Loyal'
			When Frequency >= 5 Then 'Regular'
			Else 'Occasional'
		End as FrequencySegment,
		CASE 
			When Monetary >= 10000 Then 'High Value'
			When Monetary >= 5000 Then 'Medium Value'
			Else 'Low Value'
		End as MonetarySegment
From RFM;
--------------------------------------------
--2nd solution manual scoring
DECLARE @MaxDate DATE = (SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader);
With RFM AS(
	SELECT  
		c.PersonID,
		p.FirstName,
		p.LastName,
		DATEDIFF(DAY, MAX(h.OrderDate), @MaxDate) AS Recency, --DaysSinceLastOrder
		COUNT(DISTINCT h.SalesOrderID) AS Frequency,
		SUM(h.TotalDue) AS Monetary,
		MAX(h.OrderDate) AS RecentOrderDate
	FROM Sales.SalesOrderHeader h
	JOIN Sales.Customer c ON h.CustomerID = c.CustomerID
	JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
	GROUP BY c.PersonID, p.FirstName, p.LastName
),
RFM_Score AS
(
	Select *,
		CASE 
			WHEN Recency <= 30 THEN 5
            WHEN Recency <= 60 THEN 4
            WHEN Recency <= 120 THEN 3
            WHEN Recency <= 180 THEN 2
			Else 1
		End as RecenyScore,
		CASE 
			   WHEN Frequency >= 10 THEN 5
            WHEN Frequency >= 7 THEN 4
            WHEN Frequency >= 4 THEN 3
            WHEN Frequency >= 2 THEN 2
            ELSE 1
		End as FrequencyScore,
		CASE 
			 WHEN Monetary >= 10000 THEN 5
            WHEN Monetary >= 7000 THEN 4
            WHEN Monetary >= 4000 THEN 3
            WHEN Monetary >= 1000 THEN 2
            ELSE 1
       END AS MonetaryScore
From RFM
)
Select *,
	CONCAT(RecenyScore,FrequencyScore,MonetaryScore)AS RFM_Code
From RFM_Score
Order By RFM_Code desc
--------------------------------------------
--3rd solution Dynamic NTILE & Scoring
DECLARE @MaxDate DATE = (SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader);
WITH RFM AS (
    SELECT  
        c.PersonID,
        p.FirstName,
        p.LastName,
        DATEDIFF(DAY, MAX(h.OrderDate), @MaxDate) AS Recency,
        COUNT(DISTINCT h.SalesOrderID) AS Frequency,
        SUM(h.TotalDue) AS Monetary,
        MAX(h.OrderDate) AS LastOrderDate
    FROM Sales.SalesOrderHeader h
    JOIN Sales.Customer c ON h.CustomerID = c.CustomerID
    JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
    GROUP BY c.PersonID, p.FirstName, p.LastName
),
-- (عملنا توزيع لكل عمود (1–5
Scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score, -- كلما التاريخ أبعد = Score أقل
        NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score, -- أكتر Orders = Score أعلى
        NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score   -- أكتر إنفاق = Score أعلى
    FROM RFM
)
SELECT *,
       CONCAT(R_Score, F_Score, M_Score) AS RFM_Code,
       CASE 
            WHEN R_Score = 5 AND F_Score = 5 AND M_Score = 5 THEN 'Champions'
            WHEN R_Score = 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'Loyal Customers'
            WHEN R_Score = 5 AND F_Score = 1 AND M_Score = 5 THEN 'Big Spenders'
            WHEN R_Score = 5 AND F_Score = 1 AND M_Score = 1 THEN 'New Customers'
            WHEN R_Score <= 2 AND F_Score >= 4 THEN 'At Risk Loyal'
            WHEN R_Score = 1 AND M_Score = 1 THEN 'Lost Customers'
            ELSE 'Regulars'
       END AS FinalSegment
FROM Scored
ORDER BY RFM_Code DESC;
-------------------------------------------------
-- More robust RFM with proper date handling
DECLARE @AnalysisDate DATE = (SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader);

WITH RFM AS (
    SELECT  
        c.CustomerID,
        CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName,
        DATEDIFF(DAY, MAX(h.OrderDate), @AnalysisDate) AS Recency,
        COUNT(DISTINCT h.SalesOrderID) AS Frequency,
        SUM(h.TotalDue) AS Monetary,
        MAX(h.OrderDate) AS LastOrderDate
    FROM Sales.SalesOrderHeader h
    JOIN Sales.Customer c ON h.CustomerID = c.CustomerID
    LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
    GROUP BY c.CustomerID, p.FirstName, p.LastName
),
Scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score
    FROM RFM
)
SELECT *,
    CONCAT(R_Score, F_Score, M_Score) AS RFM_Code,
    CASE 
        WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'Champions'
        WHEN R_Score >= 3 AND F_Score >= 3 AND M_Score >= 3 THEN 'Loyal Customers'
        WHEN R_Score >= 4 AND F_Score <= 2 THEN 'New Customers'
        WHEN R_Score <= 2 AND F_Score >= 4 THEN 'At Risk'
        WHEN R_Score <= 2 AND F_Score <= 2 THEN 'Lost'
        ELSE 'Regular'
    END AS CustomerSegment
FROM Scored
ORDER BY Monetary DESC;

------------------------------------------------------------------------------------
--4.Average Order Value per Customer
--(إجمالي مبيعات العميل ÷ عدد الطلبات الخاصة بيه).
Select c.PersonID,
				p.FirstName,
				p.LastName,
				Sum(h.TotalDue) as TotalSales,
				AVG(h.TotalDue) as AvgOrderValue,
				Sum(h.TotalDue)/count( distinct h.SalesOrderID) as AOV,
				count(distinct h.SalesOrderID) As #Orders
From sales.SalesOrderHeader h 
	Join sales.Customer c on h.CustomerID=c.CustomerID
	Join Person.Person p on c.PersonID=p.BusinessEntityID
Group by c.PersonID, p.FirstName, p.LastName
Order by #Orders Desc;
------------------------------------------------------------------------------------
--5.Inactive Customers
--العملاء اللي ما عملوش أي طلبات آخر سنة موجودة في البيانات.
DECLARE @MaxDate DATE = (SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader);
SELECT  
	c.PersonID,
	p.FirstName,
	p.LastName,
	DATEDIFF(DAY, MAX(h.OrderDate), @MaxDate) AS Recency, --DaysSinceLastOrder
	COUNT(DISTINCT h.SalesOrderID) AS Frequency,
	SUM(h.TotalDue) AS Monetary,
	MAX(h.OrderDate) AS RecentOrderDate,
	CASE
		When DATEDIFF(DAY, MAX(h.OrderDate), @MaxDate) > 265
		Then 1
		Else 0
	End as InactiveCustomers

FROM Sales.SalesOrderHeader h
JOIN Sales.Customer c ON h.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
GROUP BY c.PersonID, p.FirstName, p.LastName
------------------------------------------------------------------------------------

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
------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------- HR Analysis ----------------------------------------------------

--A. Workforce Overview

--1. Current Employees per Department
--How many current employees are in each department?
--(Exclude any employee who has an EndDate in EmployeeDepartmentHistory.)
--كم عدد الموظفين الحاليين في كل قسم؟
SELECT 
  d.DepartmentID,
  d.Name AS Department,
  COUNT(DISTINCT h.BusinessEntityID) AS TotalEmployees
FROM HumanResources.EmployeeDepartmentHistory h
JOIN HumanResources.Department d
  ON h.DepartmentID = d.DepartmentID
WHERE h.EndDate IS NULL
GROUP BY d.DepartmentID, d.Name
ORDER BY TotalEmployees DESC;
------------------------------------------------------------------------------------
--2. Current Employees per Shift
--How many current employees work in each shift?
--كم عدد الموظفين الحاليين الذين يعملون في كل شيفت؟
select   
	s.ShiftID,
	s.Name AS Shift,
	COUNT(DISTINCT h.BusinessEntityID) AS TotalEmployees
from [HumanResources].[EmployeeDepartmentHistory] h
Join [HumanResources].[Shift] s
on h.ShiftID = s.ShiftID
WHERE h.EndDate IS NULL
Group by s.ShiftID, s.Name
Order by TotalEmployees desc
------------------------------------------------------------------------------------
--3. Employees per Job Title
--How many employees are there for each JobTitle?
--كم عدد الموظفين لكل عنوان وظيفي ؟
SELECT
  e.JobTitle,
  COUNT(DISTINCT e.BusinessEntityID) AS TotalEmployees
FROM HumanResources.Employee e
JOIN HumanResources.EmployeeDepartmentHistory h
  ON e.BusinessEntityID = h.BusinessEntityID
  AND h.EndDate IS NULL
GROUP BY e.JobTitle
ORDER BY TotalEmployees DESC;
------------------------------------------------------------------------------------
--B. Tenure & Turnover

--4. Average Tenure
--What is the average number of years that current employees have been in the company
--(calculated from StartDate until today)?
-- (ما هو متوسط عدد السنوات التي قضاها الموظفون الحاليون في الشركة (متوسط مدة الخدمة  
--يُحسب من تاريخ التعيين  حتى اليوم؟ 
select AVG(CAST(DATEDIFF(DAY, e.HireDate,GETDATE()) as FLOAT)) / 365.25 as AvgTenureYears
from [HumanResources].[Employee] e
Join [HumanResources].[EmployeeDepartmentHistory] h
On e.BusinessEntityID = h.BusinessEntityID
WHERE h.EndDate IS NULL
AND e.HireDate IS NOT NULL;
------------------------------------------------------------------------------------
--5. Employee Turnover Rate
--What is the employee turnover rate over the last year?
--Turnover Rate = [(Number of employees who left in the last year) / (Average number of employees during the same period) ] ​× 100

DECLARE @start DATE = DATEADD(YEAR, -1, CAST(GETDATE() AS DATE));
DECLARE @end   DATE = CAST(GETDATE() AS DATE);

WITH LeftEmployees AS (
  SELECT DISTINCT BusinessEntityID
  FROM HumanResources.EmployeeDepartmentHistory
  WHERE EndDate BETWEEN @start AND @end
),
HeadcountStart AS (
  SELECT COUNT(DISTINCT BusinessEntityID) AS HCStart
  FROM HumanResources.EmployeeDepartmentHistory
  WHERE StartDate <= @start
    AND (EndDate IS NULL OR EndDate >= @start)
),
HeadcountEnd AS (
  SELECT COUNT(DISTINCT BusinessEntityID) AS HCEnd
  FROM HumanResources.EmployeeDepartmentHistory
  WHERE StartDate <= @end
    AND (EndDate IS NULL OR EndDate >= @end)
)
SELECT
  (SELECT COUNT(*) FROM LeftEmployees) AS NumLeft,
  (SELECT HCStart FROM HeadcountStart) AS HeadcountStart,
  (SELECT HCEnd FROM HeadcountEnd) AS HeadcountEnd,
  CASE
    WHEN ((SELECT HCStart FROM HeadcountStart) + (SELECT HCEnd FROM HeadcountEnd)) = 0 
      THEN NULL
    ELSE
      CAST((SELECT COUNT(*) FROM LeftEmployees) AS FLOAT)
      / ( ((SELECT HCStart FROM HeadcountStart) + (SELECT HCEnd FROM HeadcountEnd)) / 2.0)
  END * 100.0 AS TurnoverRatePct;
------------------------------------------------------------------------------------
--C. Hiring & Candidates

--6. Job Candidates per Department or Job Title
--How many job candidates are there for each department or JobTitle?
--كم عدد المرشحين للوظائف لكل قسم أو لكل مسمى وظيفي ؟
SELECT d.DepartmentID, e.JobTitle, COUNT(*) AS CandidateCount
FROM HumanResources.JobCandidate jc
JOIN HumanResources.Employee e
    ON jc.BusinessEntityID = e.BusinessEntityID
Join [HumanResources].[EmployeeDepartmentHistory] h
On e.BusinessEntityID = h.BusinessEntityID
Join [HumanResources].[Department] d
on h.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentID, e.JobTitle;
------------------------------------------------------------------------------------
--D. Demographics & Miscellaneous

--7. Average Age of Current Employees
--What is the average age of current employees?
--(If birth date data is available.)
--ما هو متوسط عمر الموظفين الحاليين؟
select AVG(CAST(DATEDIFF(day, e.BirthDate, GETDATE()) AS FLOAT)) / 365.25 AS AvgAgeYears--AVG(DATEDIFF(year, BirthDate, GETDATE())) as AvgEmpAge
from [HumanResources].[Employee] e
Join [HumanResources].[EmployeeDepartmentHistory] h
On e.BusinessEntityID = h.BusinessEntityID
WHERE h.EndDate IS NULL And BirthDate is Not Null
------------------------------------------------------------------------------------
--8. Employees per Gender
--How many current employees are there by gender?
--كم عدد الموظفين الحاليين حسب الجنس؟
SELECT 
  e.Gender,
  COUNT(DISTINCT e.BusinessEntityID) AS TotalEmployees
FROM HumanResources.Employee e
JOIN HumanResources.EmployeeDepartmentHistory h
  ON e.BusinessEntityID = h.BusinessEntityID
  AND h.EndDate IS NULL
WHERE e.Gender IS NOT NULL
GROUP BY e.Gender;
------------------------------------------------------------------------------------
--E. Advanced / Optional

--9. Top 5 Departments by Highest Turnover Rate
--Which 5 departments have the highest employee turnover rate?
--ما هي أعلى 5 أقسام لديها أعلى معدل دوران للموظفين؟		
DECLARE @start DATE = DATEADD(YEAR, -1, CAST(GETDATE() AS DATE));
DECLARE @end   DATE = CAST(GETDATE() AS DATE);

WITH LeftByDept AS (
  SELECT h.DepartmentID, COUNT(DISTINCT h.BusinessEntityID) AS NumLeft
  FROM HumanResources.EmployeeDepartmentHistory h
  WHERE h.EndDate BETWEEN @start AND @end
  GROUP BY h.DepartmentID
),
HCStart AS (
  SELECT h.DepartmentID, COUNT(DISTINCT h.BusinessEntityID) AS HCStart
  FROM HumanResources.EmployeeDepartmentHistory h
  WHERE h.StartDate <= @start
    AND (h.EndDate IS NULL OR h.EndDate >= @start)
  GROUP BY h.DepartmentID
),
HCEnd AS (
  SELECT h.DepartmentID, COUNT(DISTINCT h.BusinessEntityID) AS HCEnd
  FROM HumanResources.EmployeeDepartmentHistory h
  WHERE h.StartDate <= @end
    AND (h.EndDate IS NULL OR h.EndDate >= @end)
  GROUP BY h.DepartmentID
)
SELECT TOP(5)
  d.DepartmentID,
  d.Name AS Department,
  ISNULL(l.NumLeft,0) AS NumLeft,
  ISNULL(s.HCStart,0) AS HCStart,
  ISNULL(e.HCEnd,0) AS HCEnd,
  CASE WHEN (ISNULL(s.HCStart,0) + ISNULL(e.HCEnd,0)) = 0 THEN NULL
       ELSE CAST(ISNULL(l.NumLeft,0) AS FLOAT) / ((ISNULL(s.HCStart,0) + ISNULL(e.HCEnd,0))/2.0) * 100
  END AS TurnoverPct
FROM HumanResources.Department d
LEFT JOIN LeftByDept l ON d.DepartmentID = l.DepartmentID
LEFT JOIN HCStart s ON d.DepartmentID = s.DepartmentID
LEFT JOIN HCEnd e ON d.DepartmentID = e.DepartmentID
ORDER BY TurnoverPct DESC;

---------------------------------------------------------------------------------------------------------

-- ------------------------------------------ Financial Performance -----------------------------------------------
--A. Revenue & Profitability

-- 01.Total Revenue by Year/Month
--What is the total sales revenue per year and per month?
-- إجمالي الإيرادات (المبيعات) سنوياً و شهرياً
Select Year(OrderDate) as SalesYear,
		MONTH(OrderDate) as SalesMonth,
		sum(TotalDue) as Revenue
from Sales.SalesOrderHeader
Group by Year(OrderDate), MONTH(OrderDate)
Order By SalesYear, SalesMonth
------------------------------------------------------------------------------------
-- 02.Gross Profit & Gross Margin
--What is the gross profit (Sales – COGS) and the gross margin %?
-- إجمالي الربح وهامش الربح

-- 1st solution: using StandardCost from Production.Product
SELECT 
    --YEAR(soh.OrderDate)  AS SalesYear, 
    --MONTH(soh.OrderDate) AS SalesMonth,
	SUM(TotalDue) as TotalSales, 
    SUM(sod.OrderQty * p.StandardCost) AS TotalCOGS,  -- Cost of goods sold
    SUM(soh.TotalDue) - SUM(sod.OrderQty * p.StandardCost) AS GrossProfit,
    ( (SUM(soh.TotalDue) - SUM(sod.OrderQty * p.StandardCost))
        / NULLIF(SUM(soh.TotalDue),0) ) * 100 AS GrossMarginPct
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product AS p
    ON sod.ProductID = p.ProductID
--GROUP BY YEAR(soh.OrderDate), MONTH(soh.OrderDate)
--ORDER BY SalesYear, SalesMonth;
-------------
-- 2nd solution:Production.TransactionHistory [More Accurate]
WITH COGS AS (
    SELECT SUM(ActualCost * Quantity) AS TotalCOGS
    FROM Production.TransactionHistory
    WHERE TransactionType = 'S'
),
Revenue AS (
    SELECT SUM(TotalDue) AS TotalRevenue
    FROM Sales.SalesOrderHeader
)
SELECT
    r.TotalRevenue,
    c.TotalCOGS,
    r.TotalRevenue - c.TotalCOGS AS GrossProfit,
    ((r.TotalRevenue - c.TotalCOGS) * 100.0) / r.TotalRevenue AS GrossMarginPct
FROM Revenue r CROSS JOIN COGS c;
------------------------------------------------------------------------------------
--03.Operating Expenses (لو البيانات متوفرة)
--Total operating expenses per year/month.
-- إجمالي المصروفات التشغيلية
--does not contain an “Operating Expenses” table or field.
-- So I created Operating Expenses Table with Data like ADW Data Range
Select Year(ExpenseDate) as Year,
		Month(ExpenseDate) as Month,
		Sum(Amount) as TotalOpEX
From Finance.OperatingExpenses
Group by Year(ExpenseDate),Month(ExpenseDate)
Order by Year(ExpenseDate),Month(ExpenseDate);
------------------------------------------------------------------------------------
--04.Net Profit
--What is the net profit (Revenue – COGS – Expenses)?
-- صافي الربح
With Revenue As(
Select Sum(TotalDue) as TotalRevenue
From Sales.SalesOrderHeader
),
COGS AS(
Select Sum(Quantity * ActualCost) as TotalCOGS
From Production.TransactionHistory
WHERE TransactionType = 'S'
),
OpEx As(
Select Sum(Amount) as TotalOperatingExpenses
From Finance.OperatingExpenses
)
Select 
	r.TotalRevenue,
	c.TotalCOGS,
	o.TotalOperatingExpenses,
	r.TotalRevenue - c.TotalCOGS as GrossProfit,
	r.TotalRevenue - c.TotalCOGS - o.TotalOperatingExpenses as NetProfit
From Revenue r
Cross Join COGS c
Cross Join OpEx o
------------------------------------------------------------------------------------
--B. Financial Ratios

--05.Year-over-Year Revenue Growth
--Percentage growth in sales revenue compared to previous year.
-- معدل نمو الإيرادات مقارنة بالعام السابق.
-- first solution
SELECT
    YEAR(OrderDate) AS SalesYear,
    SUM(TotalDue) AS TotalRevenue,
    LAG(SUM(TotalDue)) OVER (ORDER BY YEAR(OrderDate)) AS PrevYearRevenue,
	(SUM(TotalDue) - (LAG(SUM(TotalDue)) OVER (ORDER BY YEAR(OrderDate)))) *100.0 / 
	(LAG(SUM(TotalDue)) OVER (ORDER BY YEAR(OrderDate)))  as [YoY%]
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY SalesYear;
----------------------------------------------------
-- second solution
--Better Revenue Growth Analysis
-- Add more context to YoY growth
WITH YearlyMetrics AS (
    SELECT
        YEAR(OrderDate) AS SalesYear,
        SUM(TotalDue) AS Revenue,
        COUNT(DISTINCT SalesOrderID) AS Orders,
        COUNT(DISTINCT CustomerID) AS Customers
    FROM Sales.SalesOrderHeader
    GROUP BY YEAR(OrderDate)
)
SELECT
    SalesYear,
    Revenue,
    Orders,
    Customers,
    LAG(Revenue) OVER (ORDER BY SalesYear) AS PrevYearRevenue,
    CASE 
        WHEN LAG(Revenue) OVER (ORDER BY SalesYear) IS NULL THEN NULL
        ELSE ROUND(
            (Revenue - LAG(Revenue) OVER (ORDER BY SalesYear)) * 100.0 
            / LAG(Revenue) OVER (ORDER BY SalesYear), 2
        )
    END AS YoY_Growth_Pct,
    Revenue / NULLIF(Orders, 0) AS AvgOrderValue,
    Revenue / NULLIF(Customers, 0) AS RevenuePerCustomer
FROM YearlyMetrics
ORDER BY SalesYear;
------------------------------------------------------------------------------------
--06.Profit Margin %
--Net Profit ÷ Total Revenue × 100.
-- نسبة صافي الربح.
With Revenue As(
Select Sum(TotalDue) as TotalRevenue
From Sales.SalesOrderHeader
),
COGS AS(
Select Sum(Quantity * ActualCost) as TotalCOGS
From Production.TransactionHistory
WHERE TransactionType = 'S'
),
OpEx As(
Select Sum(Amount) as TotalOperatingExpenses
From Finance.OperatingExpenses
)
Select 
	r.TotalRevenue - c.TotalCOGS - o.TotalOperatingExpenses as NetProfit,
	(r.TotalRevenue - c.TotalCOGS - o.TotalOperatingExpenses)*100.0 / r.TotalRevenue as ProfitMarginPct
From Revenue r
Cross Join COGS c
Cross Join OpEx o
------------------------------------------------------------------------------------
--07.Return on Investment (ROI) (لو عندك بيانات استثمار).
--ROI= [Net Profit or (Gain from Investment−Investment Cost) ] × 100 / Investment Cost

WITH Sales AS (
    SELECT YEAR(OrderDate) AS Year, SUM(SubTotal) AS TotalSales
    FROM Sales.SalesOrderHeader
    GROUP BY YEAR(OrderDate)
),
COGS AS (
    SELECT YEAR(TransactionDate) AS Year, SUM(Quantity * ActualCost) AS TotalCOGS
    FROM Production.TransactionHistory
    WHERE TransactionType = 'S'
    GROUP BY YEAR(TransactionDate)
),
OpEx AS (
    SELECT YEAR(ExpenseDate) AS Year, SUM(Amount) AS TotalOpEx
    FROM Finance.OperatingExpenses
    GROUP BY YEAR(ExpenseDate)
)
SELECT 
    s.Year,
    s.TotalSales,
    c.TotalCOGS,
    o.TotalOpEx,
    (s.TotalSales - c.TotalCOGS - o.TotalOpEx) AS NetProfit,
    ((s.TotalSales - c.TotalCOGS - o.TotalOpEx) / o.TotalOpEx) * 100 AS ROI_Percent
FROM Sales s
JOIN COGS c ON s.Year = c.Year
JOIN OpEx o ON s.Year = o.Year
ORDER BY s.Year;
------------------------------------------------------------------------------------
--C. Customers & Products Contribution

--08.Top 10 Products by Revenue
--Which products generate the highest revenue?
-- أعلى المنتجات من حيث المبيعات.
SELECT TOP 10
    d.ProductID,
    SUM(d.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail d
GROUP BY d.ProductID
ORDER BY TotalRevenue DESC;  
------------------------------------------------------------------------------------
--09.Top 10 Customers by Revenue
--Which customers contribute the most revenue?
-- أهم العملاء من حيث المساهمة في الإيرادات.
Select Top(10) c.PersonID,
				Sum(h.TotalDue) as TotalRevenue
From sales.SalesOrderHeader h 
	Join sales.Customer c on h.CustomerID=c.CustomerID
Group by c.PersonID
Order by TotalRevenue Desc;
------------------------------------------------------------------------------------
------------------------------------------------------------
--helper insights 

-------- sales ------------
select  Top(10) *
from sales.SalesOrderDetail

select  Top(10) *
from sales.SalesOrderHeader

select sum(totalDue)
from sales.SalesOrderHeader

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

-------- customer ------------
select  Top(10) *
from Person.Person

Select 	h.*,
		c.*,
		p.*
From sales.SalesOrderHeader h 
	Join sales.Customer c on h.CustomerID=c.CustomerID
	Join Person.Person p on c.PersonID=p.BusinessEntityID
	Group by c.PersonID

------------------------
SELECT TransactionType, COUNT(*) AS RowsCount
FROM Production.TransactionHistory
GROUP BY TransactionType;

select sum(orderQty)
from sales.SalesOrderDetail
-------------HR --------------
select top(10) * 
from [HumanResources].[Employee]
select top(10) * 
from [HumanResources].[Department]
select top(10) * 
from [HumanResources].[EmployeeDepartmentHistory]
select top(10) * 
from [HumanResources].[EmployeePayHistory]
select top(10) * 
from [HumanResources].[JobCandidate]
select top(10) * 
from [HumanResources].[Shift]

--Performance Optimization
-- Add indexes for better performance
use AdventureWorks2022
CREATE NONCLUSTERED INDEX IX_OrderDate 
ON Sales.SalesOrderHeader(OrderDate) INCLUDE (TotalDue, CustomerID);

CREATE NONCLUSTERED INDEX IX_ProductID 
ON Sales.SalesOrderDetail(ProductID) INCLUDE (OrderQty, LineTotal);
