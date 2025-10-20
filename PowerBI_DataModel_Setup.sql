
USE AdventureWorks2022;
GO

-- ============================================
-- VIEW 1: FactSales (Main Fact Table)
-- ============================================
CREATE OR ALTER VIEW vw_FactSales AS
SELECT
    sod.SalesOrderID,
    sod.SalesOrderDetailID,
    soh.OrderDate,
    soh.CustomerID,
    sod.ProductID,
    soh.TerritoryID,
    sod.OrderQty,
    sod.UnitPrice,
    sod.LineTotal,
    soh.SubTotal,
    soh.TaxAmt,
    soh.Freight,
    soh.TotalDue,
    p.StandardCost,
    -- Calculated: COGS
    sod.OrderQty * p.StandardCost AS COGS,
    -- Calculated: Gross Profit
    sod.LineTotal - (sod.OrderQty * p.StandardCost) AS GrossProfit
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID;
GO
-- ============================================
-- VIEW 2: DimProduct (Product Dimension)
-- ============================================
CREATE OR ALTER VIEW vw_DimProduct AS
SELECT
    p.ProductID,
    p.Name AS ProductName,
    p.ProductNumber,
    p.Color,
    p.StandardCost,
    p.ListPrice,
    p.Size,
    p.Weight,
    ISNULL(psc.Name, 'No Subcategory') AS SubcategoryName,
    ISNULL(pc.Name, 'No Category') AS CategoryName,
    psc.ProductSubcategoryID,
    pc.ProductCategoryID
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID;
GO
-- ============================================
-- VIEW 3: DimCustomer (Customer Dimension)
-- ============================================
CREATE OR ALTER VIEW vw_DimCustomer AS
SELECT
    c.CustomerID,
    ISNULL(p.BusinessEntityID, 0) AS PersonID,
    ISNULL(CONCAT(p.FirstName, ' ', p.LastName), 'Unknown') AS CustomerName,
    p.FirstName,
    p.LastName,
    c.TerritoryID
FROM Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID;
GO
-- ============================================
-- VIEW 4: DimTerritory
-- ============================================
CREATE OR ALTER VIEW vw_DimTerritory AS
SELECT
    TerritoryID,
    Name AS TerritoryName,
    CountryRegionCode AS Country,
    [Group] AS Region
FROM Sales.SalesTerritory;
GO
-- ============================================
-- VIEW 5: FactInventory
-- ============================================
CREATE OR ALTER VIEW vw_FactInventory AS
SELECT
    pi.ProductID,
    pi.LocationID,
    pi.Shelf,
    pi.Bin,
    pi.Quantity,
    p.StandardCost,
    pi.Quantity * p.StandardCost AS InventoryValue
FROM Production.ProductInventory pi
JOIN Production.Product p ON pi.ProductID = p.ProductID;
GO
-- ============================================
-- VIEW 6: FactPurchasing
-- ============================================
CREATE OR ALTER VIEW vw_FactPurchasing AS
SELECT
    pod.PurchaseOrderID,
    pod.PurchaseOrderDetailID,
    poh.OrderDate,
    poh.VendorID,
    pod.ProductID,
    pod.OrderQty,
    pod.UnitPrice,
    pod.LineTotal,
    poh.SubTotal,
    poh.TaxAmt,
    poh.Freight,
    poh.TotalDue
FROM Purchasing.PurchaseOrderDetail pod
JOIN Purchasing.PurchaseOrderHeader poh ON pod.PurchaseOrderID = poh.PurchaseOrderID;
GO

-- ============================================
-- VIEW 7: DimVendor
-- ============================================
CREATE OR ALTER VIEW vw_DimVendor AS
SELECT
    BusinessEntityID AS VendorID,
    Name AS VendorName,
    CreditRating,
    PreferredVendorStatus,
    ActiveFlag
FROM Purchasing.Vendor;
GO

-- ============================================
-- VIEW 8: FactEmployeeHistory
-- ============================================
CREATE OR ALTER VIEW vw_FactEmployeeHistory AS
SELECT
    BusinessEntityID,
    DepartmentID,
    ShiftID,
    StartDate,
    EndDate,
    -- Helper: IsCurrentEmployee
    CASE WHEN EndDate IS NULL THEN 1 ELSE 0 END AS IsCurrentEmployee
FROM HumanResources.EmployeeDepartmentHistory;
GO

-- ============================================
-- VIEW 9: DimEmployee
-- ============================================
CREATE OR ALTER VIEW vw_DimEmployee AS
SELECT
    BusinessEntityID,
    NationalIDNumber,
    JobTitle,
    BirthDate,
    Gender,
    HireDate,
    SalariedFlag,
    MaritalStatus
FROM HumanResources.Employee;
GO
-- ============================================
-- VIEW 10: DimDepartment
-- ============================================
CREATE OR ALTER VIEW vw_DimDepartment AS
SELECT
    DepartmentID,
    Name AS DepartmentName,
    GroupName AS DepartmentGroup
FROM HumanResources.Department;
GO

-- ============================================
-- VIEW 11: DimShift
-- ============================================
CREATE OR ALTER VIEW vw_DimShift AS
SELECT
    ShiftID,
    Name AS ShiftName,
    StartTime,
    EndTime
FROM HumanResources.Shift;
GO

-- ============================================
-- DONE! Now connect Power BI to these views
-- ============================================