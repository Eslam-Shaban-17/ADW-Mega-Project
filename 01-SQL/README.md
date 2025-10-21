<aside>

# 📊 SQL Analysis Scripts

## What's Inside

This folder contains all SQL queries I used to explore and analyze the AdventureWorks database before building the Power BI dashboard.

## Files

| File                           | Description                                      | Key Queries |
| ------------------------------ | ------------------------------------------------ | ----------- |
| `01-Sales-Performance.sql`     | Revenue trends, top products, YoY/MoM growth     | 12 queries  |
| `02-Customer-Segmentation.sql` | RFM analysis, customer lifetime value, retention | 5 queries   |
| `03-Supply-Chain.sql`          | Inventory levels, turnover, vendor analysis      | 6 queries   |
| `04-HR-Analytics.sql`          | Headcount, turnover rate, tenure                 | 9 queries   |
| `05-Financial-Performance.sql` | Profit margins, COGS, ROI                        | 9 queries   |
| `99-All-Queries.sql`           | **Complete file** with all queries combined      | 40+ queries |

## How I Used These

1. **Exploration:** Understood the data structure and business metrics
2. **Validation:** Cross-checked Power BI results against SQL
3. **Documentation:** Showed my SQL skills to recruiters
4. **Learning:** Practiced window functions, CTEs, date handling

## Key Techniques Demonstrated

- ✅ **Window Functions:** `ROW_NUMBER()`, `RANK()`, `LAG()`, `LEAD()`, `NTILE()`
- ✅ **CTEs:** Complex multi-step calculations
- ✅ **Date Handling:** Working with historical data (using `@MaxDate`)
- ✅ **Aggregations:** `GROUP BY`, `HAVING`, conditional aggregation
- ✅ **Joins:** Multiple table joins for comprehensive analysis

## Running the Queries

```sql
-- 1. Restore AdventureWorks2022 database first
-- 2. Open any .sql file in SSMS
-- 3. Execute (F5) to see results
-- 4. Each query is commented with business question

```

## Example Query

```sql
-- Top 5 customers by revenue
SELECT TOP 5
    c.PersonID,
    p.FirstName + ' ' + p.LastName AS CustomerName,
    SUM(h.TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader h
JOIN Sales.Customer c ON h.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
GROUP BY c.PersonID, p.FirstName, p.LastName
ORDER BY TotalRevenue DESC;

```

## Notes

- All queries use standard T-SQL (SQL Server 2019+)
- Queries are production-ready (no `SELECT *`)
- Comments explain business logic
- Some queries show multiple solution approaches

---

**Questions?** Check the main [README.md](https://claude.ai/README.md) or open an issue!

</aside>
