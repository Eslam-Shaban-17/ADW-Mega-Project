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

------------------------------------------------------------------------------------
--helper insights 

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
