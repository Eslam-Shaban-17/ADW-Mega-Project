Use AdventureWorks2022


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
Select Year(ExpenseDate),
		Month(ExpenseDate),
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
-- First Create  Finance Schema
--Create Schema Finance
-----------------------------------------------------------
-- Second Create table
CREATE TABLE Finance.OperatingExpenses
(
    ExpenseID INT IDENTITY PRIMARY KEY,
    ExpenseDate DATE NOT NULL,
    DepartmentID SmallInt NULL,
    ExpenseCategory NVARCHAR(50) NOT NULL,
    Amount MONEY NOT NULL,
    Notes NVARCHAR(200) NULL,
    CONSTRAINT FK_OperatingExpenses_Department
        FOREIGN KEY (DepartmentID)
        REFERENCES HumanResources.Department(DepartmentID)
);
-----------------------------------------------------------
-- Insert Approximate Data
;WITH Numbers AS
(
    SELECT TOP (4000)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
),
DeptCount AS
(
    SELECT COUNT(*) AS cnt FROM HumanResources.Department
),
RandNums AS
(
    SELECT
        rn,
        -- force per-row evaluation here
        ABS(CHECKSUM(NEWID())) % (SELECT cnt FROM DeptCount) + 1 AS randDeptRow
    FROM Numbers
),
Dept AS
(
    SELECT DepartmentID,
           ROW_NUMBER() OVER (ORDER BY DepartmentID) AS dept_rn
    FROM HumanResources.Department
)
INSERT INTO Finance.OperatingExpenses
       (ExpenseDate, DepartmentID, ExpenseCategory, Amount, Notes)
SELECT
    DATEADD(
        DAY,
        ABS(CHECKSUM(NEWID())) % (1 + DATEDIFF(DAY,'2008-01-01','2014-12-31')),
        '2008-01-01') AS ExpenseDate,
    d.DepartmentID,
    CASE ABS(CHECKSUM(NEWID())) % 6
         WHEN 0 THEN 'Salaries & Wages'
         WHEN 1 THEN 'Utilities'
         WHEN 2 THEN 'Rent'
         WHEN 3 THEN 'Marketing & Ads'
         WHEN 4 THEN 'IT & Software'
         ELSE       'Miscellaneous'
    END AS ExpenseCategory,
    1000 + ROUND(RAND(CHECKSUM(NEWID())) * 9000, 0) AS Amount,
    CONCAT('Auto expense #', r.rn) AS Notes
FROM RandNums r
JOIN Dept d
  ON d.dept_rn = r.randDeptRow;

-----------------------------------------------------------
SELECT MIN(ExpenseDate) AS Earliest,
       MAX(ExpenseDate) AS Latest,
       COUNT(*) AS RowsInserted
FROM Finance.OperatingExpenses;
-----------------------------------------------------------
--Check Relationship
SELECT o.*, d.Name AS DepartmentName
FROM Finance.OperatingExpenses o
LEFT JOIN HumanResources.Department d
       ON o.DepartmentID = d.DepartmentID;
---------------------------
SELECT DepartmentID, COUNT(*) 
FROM Finance.OperatingExpenses
GROUP BY DepartmentID
Order by DepartmentID;
-----------------------------------------------------------
------ delete all data
--delete from Finance.OperatingExpenses
------ diplay all data 
--select * from Finance.OperatingExpenses

--select
--NEWID(),
--checksum(newid())
-----------------------------------------------------------
--Example: Combine with Financial KPIs
WITH Revenue AS (
    SELECT SUM(TotalDue) AS TotalRevenue
    FROM Sales.SalesOrderHeader
),
COGS AS (
    SELECT SUM(ActualCost * Quantity) AS TotalCOGS
    FROM Production.TransactionHistory
    WHERE TransactionType = 'S'
),
OpEx AS (
    SELECT SUM(Amount) AS TotalOperatingExpenses
    FROM Finance.OperatingExpenses
)
SELECT
    r.TotalRevenue,
    c.TotalCOGS,
    o.TotalOperatingExpenses,
    r.TotalRevenue - c.TotalCOGS AS GrossProfit,
    r.TotalRevenue - c.TotalCOGS - o.TotalOperatingExpenses AS NetProfit
FROM Revenue r
CROSS JOIN COGS c
CROSS JOIN OpEx o;

--Performance Optimization
-- Add indexes for better performance
CREATE NONCLUSTERED INDEX IX_OrderDate 
ON Sales.SalesOrderHeader(OrderDate) INCLUDE (TotalDue, CustomerID);

CREATE NONCLUSTERED INDEX IX_ProductID 
ON Sales.SalesOrderDetail(ProductID) INCLUDE (OrderQty, LineTotal);

---------------------------------------------------------------------------------------
--IF OBJECT_ID('Finance.OperatingExpensesMonthly') IS NULL
--BEGIN
--    --CREATE SCHEMA Finance;
--    CREATE TABLE Finance.OperatingExpensesMonthly
--    (
--        ExpenseDate DATE,
--        Salaries MONEY,
--        Utilities MONEY,
--        Rent MONEY,
--        Marketing MONEY,
--        TotalOperatingExpenses AS (Salaries + Utilities + Rent + Marketing) PERSISTED
--    );
--END
---------------------------
---- Insert 2000 rows starting from 2008-01-01 (for example)
--;WITH n AS
--(
--    SELECT TOP (2000) 
--           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS i
--    FROM sys.all_columns a CROSS JOIN sys.all_columns b
--)
--INSERT INTO Finance.OperatingExpensesMonthly (ExpenseDate, Salaries, Utilities, Rent, Marketing)
--SELECT 
--    DATEADD(MONTH, i, '2008-01-01') AS ExpenseDate,

--    -- Salaries: start around 80k, slowly grow + random
--    80000 + i*50 + ROUND(RAND(CHECKSUM(NEWID()))*5000,0) AS Salaries,

--    -- Utilities: start around 5k, mild growth
--    5000 + i*2 + ROUND(RAND(CHECKSUM(NEWID()))*800,0)    AS Utilities,

--    -- Rent: roughly constant ~15k ±1k
--    15000 + ROUND(RAND(CHECKSUM(NEWID()))*1000,0)        AS Rent,

--    -- Marketing: bigger seasonal swings
--    8000 + ROUND(RAND(CHECKSUM(NEWID()))*6000,0)         AS Marketing
--FROM n;
---------------------------
--SELECT TOP 10 *
--FROM Finance.OperatingExpensesMonthly
--ORDER BY ExpenseDate DESC;