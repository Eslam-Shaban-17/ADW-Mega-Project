use AdventureWorks2022


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
--------------------------------------------------------------------------------------
--13. Product Performance Matrix
-- Boston Consulting Group (BCG) Matrix approach
WITH ProductMetrics AS (
    SELECT 
        p.ProductID,
        p.Name,
        SUM(d.OrderQty) AS TotalQuantity,
        SUM(d.LineTotal) AS TotalRevenue,
        (SUM(d.LineTotal) - SUM(d.OrderQty * p.StandardCost)) AS Profit
    FROM Sales.SalesOrderDetail d
    JOIN Production.Product p ON d.ProductID = p.ProductID
    GROUP BY p.ProductID, p.Name, p.StandardCost
)
SELECT *,
    CASE 
        WHEN TotalRevenue > (SELECT AVG(TotalRevenue) FROM ProductMetrics) 
         AND Profit > (SELECT AVG(Profit) FROM ProductMetrics) 
        THEN 'Star Products'
        
        WHEN TotalRevenue > (SELECT AVG(TotalRevenue) FROM ProductMetrics) 
         AND Profit <= (SELECT AVG(Profit) FROM ProductMetrics) 
        THEN 'Cash Cows'
        
        WHEN TotalRevenue <= (SELECT AVG(TotalRevenue) FROM ProductMetrics) 
         AND Profit > (SELECT AVG(Profit) FROM ProductMetrics) 
        THEN 'Question Marks'
        
        ELSE 'Dogs (Consider Discontinuing)'
    END AS ProductCategory
FROM ProductMetrics
ORDER BY TotalRevenue DESC;
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

--helper insights 
select  Top(10) *
from sales.SalesOrderDetail

select  Top(10) *
from sales.SalesOrderHeader

select sum(totalDue)
from sales.SalesOrderHeader

select  Top(10) *
from sales.Customer

select  Top(10) *
from Person.Person

--Performance Optimization
-- Add indexes for better performance
CREATE NONCLUSTERED INDEX IX_OrderDate 
ON Sales.SalesOrderHeader(OrderDate) INCLUDE (TotalDue, CustomerID);

CREATE NONCLUSTERED INDEX IX_ProductID 
ON Sales.SalesOrderDetail(ProductID) INCLUDE (OrderQty, LineTotal);