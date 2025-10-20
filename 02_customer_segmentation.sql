use AdventureWorks2022


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
		When DATEDIFF(DAY, MAX(h.OrderDate), @MaxDate) > 365
		Then 1
		Else 0
	End as InactiveCustomers

FROM Sales.SalesOrderHeader h
JOIN Sales.Customer c ON h.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
GROUP BY c.PersonID, p.FirstName, p.LastName
Order by InactiveCustomers desc
------------------------------------------------------------------------------------
--Customer Cohort Analysis
-- Analyze customer retention by cohort
WITH FirstPurchase AS (
    SELECT 
        CustomerID,
        MIN(OrderDate) AS FirstOrderDate,
        YEAR(MIN(OrderDate)) AS CohortYear,
        MONTH(MIN(OrderDate)) AS CohortMonth
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
),
CohortActivity AS (
    SELECT 
        fp.CustomerID,
        fp.CohortYear,
        fp.CohortMonth,
        DATEDIFF(MONTH, fp.FirstOrderDate, h.OrderDate) AS MonthsSinceFirst,
        COUNT(DISTINCT h.SalesOrderID) AS Orders,
        SUM(h.TotalDue) AS Revenue
    FROM FirstPurchase fp
    JOIN Sales.SalesOrderHeader h ON fp.CustomerID = h.CustomerID
    GROUP BY fp.CustomerID, fp.CohortYear, fp.CohortMonth, 
             DATEDIFF(MONTH, fp.FirstOrderDate, h.OrderDate)
)--SELECT * FROM CohortActivity
SELECT 
    CohortYear,
    CohortMonth,
    MonthsSinceFirst,
    COUNT(DISTINCT CustomerID) AS ActiveCustomers,
    SUM(Revenue) AS TotalRevenue,
    AVG(Revenue) AS AvgRevenuePerCustomer
FROM CohortActivity
WHERE MonthsSinceFirst <= 12 -- First year retention
GROUP BY CohortYear, CohortMonth, MonthsSinceFirst
ORDER BY CohortYear, CohortMonth, MonthsSinceFirst;

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

Select 	h.*,
				c.*,
				p.*
From sales.SalesOrderHeader h 
	Join sales.Customer c on h.CustomerID=c.CustomerID
	Join Person.Person p on c.PersonID=p.BusinessEntityID
	Group by c.PersonID

--Performance Optimization
-- Add indexes for better performance
CREATE NONCLUSTERED INDEX IX_OrderDate 
ON Sales.SalesOrderHeader(OrderDate) INCLUDE (TotalDue, CustomerID);

CREATE NONCLUSTERED INDEX IX_ProductID 
ON Sales.SalesOrderDetail(ProductID) INCLUDE (OrderQty, LineTotal);