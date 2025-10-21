<aside>

# 🔬 Project Methodology

## Overview

This document explains **how** I built the project and **why** I made certain decisions.

---

## 📊 Phase 1: Planning (Week 1)

### What I Did

1. Downloaded AdventureWorks2022 database
2. Explored tables and relationships in SSMS
3. Identified 5 business domains
4. Listed 50+ business questions

### Key Decisions

**Why AdventureWorks?**

- Standard dataset (easy for recruiters to understand)
- Rich data (sales, customers, inventory, HR)
- Real-world complexity

**Why these 5 domains?**

- Covers typical BI analyst responsibilities
- Shows versatility (sales, finance, HR, operations)
- Each domain has different challenges

---

## 🔍 Phase 2: SQL Analysis (Week 1-2)

### Approach

**Step 1: Simple Exploration**

```sql
-- Started with basic queries
SELECT * FROM Sales.SalesOrderHeader;
SELECT COUNT(*) FROM Sales.SalesOrderDetail;

```

**Step 2: Answering Business Questions**

- Wrote one query per business question
- Tested results for accuracy
- Added comments explaining logic

**Step 3: Advanced Techniques**

- RFM segmentation (3 different approaches)
- Window functions for rankings
- Time intelligence with LAG/LEAD

### Key Decisions

**Historical Data Handling**

- **Problem:** Data ends in 2014, using GETDATE() makes all customers "churned"
- **Solution:** Used `@MaxDate = MAX(OrderDate)` instead
- **Learning:** Always check date ranges first!

**Multiple Solutions**

- Showed 2-3 ways to solve same problem
- Example: RFM with manual scoring vs NTILE
- Reason: Demonstrates different skill levels

---

## 📐 Phase 3: Data Modeling (Week 2)

### Star Schema Design

**Why Star Schema?**

- Industry standard for BI
- Fast query performance
- Easy for users to understand

**Grain Decision**

- **FactSales:** Line-item grain (not order grain)
- **Why:** Allows product-level analysis
- **Challenge:** TotalDue duplicates across lines
- **Solution:** Allocated tax/freight proportionally

### Creating Views

**Why Views Instead of Direct Tables?**

```sql
-- ❌ Bad: Import full tables with all columns
SELECT * FROM Sales.SalesOrderDetail;

-- ✅ Good: Create clean view with only needed columns
CREATE VIEW vw_FactSales AS
SELECT
    SalesOrderID,
    ProductID,
    OrderQty,
    LineTotal,
    -- Add calculated COGS here
FROM ...

```

**Benefits:**

- Cleaner Power BI model
- Pre-calculated columns (COGS, GrossProfit)
- Easy to update logic

### DimDate Table

**Why Build in Power Query?**

- No date dimension in AdventureWorks
- Power Query (M) is perfect for generating dates
- Can customize (fiscal year, holidays, etc.)

```
// Generated dates from 2011-2014
// Added: Year, Quarter, Month, Day, Week

```

---

## 📊 Phase 4: Power BI Development (Week 2-3)

### Data Import

**Import vs DirectQuery?**

- **Chose:** Import
- **Why:**
  - Faster performance
  - Can use all DAX features
  - Data rarely changes (historical)

### Calculated Columns vs Measures

**When I Used Calculated Columns:**

```
// Allocated tax (stored in table)
TaxAllocated =
    (FactSales[LineTotal] / FactSales[SubTotal]) * FactSales[TaxAmt]

```

- **Why:** Used frequently, calculated once
- **Tradeoff:** Increases file size but improves performance

**When I Used Measures:**

```
// Total Revenue (calculated on-the-fly)
Total Revenue = SUM(FactSales[LineTotal])

```

- **Why:** Flexible, responds to filters
- **Benefit:** Smaller file size

### DAX Measure Organization

**Created Folders:**

```
📊 Measures/
├── 💰 Revenue/
├── 👥 Customers/
├── 📅 Time Intelligence/
etc.

```

**Why:**

- Easy to find measures
- Professional appearance
- Scalable as project grows

---

## 🎨 Phase 5: Visualization (Week 3-4)

### Dashboard Design Philosophy

**Principles I Followed:**

1. **Less is More:** 6-8 visuals per page max
2. **Consistent Colors:** Blue theme throughout
3. **Top-Down:** KPIs at top, details below
4. **Interactivity:** Everything cross-filters
5. **Mobile-Friendly:** Test on phone layout

### Visual Selection

**My Process:**

1. Identify metric type (trend? comparison? composition?)
2. Choose appropriate chart
3. Test with real users (friends/family)
4. Simplify if confused

**Examples:**

- Line charts for trends (time series)
- Bar charts for comparisons (top 10)
- Donut/pie for composition (% of total)
- Tables for detailed drill-down

---

## 🔧 Phase 6: Optimization

### Performance Improvements

**What I Did:**

1. **Removed unnecessary columns** (hide in model)
2. **Used measures instead of calculated columns** where possible
3. **Limited visual count** per page
4. **Proper data types** (integers for IDs)

**Before Optimization:** 8-second load

**After Optimization:** 3-second load ✅

### Testing

**Validation Checks:**

```
// Created diagnostic measures
Row Count = COUNTROWS(FactSales)
// Expected: 121,317

Revenue Check = [Revenue (Order Level)] - [Revenue (Line Level)]
// Expected: Close to 0

```

---

## 🤔 Challenges & Solutions

### Challenge 1: TotalDue Duplication

**Problem:**

```
Order 43659 has 12 line items
TotalDue = $23,153
But appears 12 times in FactSales!
SUM(TotalDue) = $277,839 ❌ (inflated!)

```

**Solution:**

```
// Use SUMX to deduplicate
Total Revenue (Order Level) =
SUMX(
    VALUES(FactSales[SalesOrderID]),
    CALCULATE(MAX(FactSales[TotalDue]))
)

```

### Challenge 2: Historical Data

**Problem:** GETDATE() shows all customers as churned

**Solution:** Used dataset's max date

```sql
DECLARE @MaxDate DATE = (SELECT MAX(OrderDate) FROM ...)

```

### Challenge 3: RFM Segmentation

**Tried 3 Approaches:**

1. Manual thresholds (simple but arbitrary)
2. Manual scoring (more control)
3. NTILE (dynamic, best for this dataset)

**Chose:** NTILE for fairness and simplicity

---

## 📚 What I Learned

### Technical Skills

- Window functions in SQL
- DAX context (filter vs row)
- Star schema design
- PBIP format (better for Git)

### Business Skills

- How to ask good business questions
- RFM customer segmentation
- Financial metrics (margins, turnover)
- Supply chain concepts

### Soft Skills

- Breaking big projects into phases
- Documenting decisions
- When to stop optimizing (80/20 rule)

---

## 🔄 Iterative Approach

**This wasn't linear!** I went back many times:

```
Week 1: SQL → Week 2: Power BI → Week 3: Dashboard
          ↓           ↓                ↓
      Found issue → Redesigned → Simplified
          ↑           ↑                ↑
      Back to SQL → Fixed model → Rebuilt visual

```

**Key Lesson:** Version control (Git) saved me multiple times!

---

## 🎯 What I'd Do Differently

### If Starting Over

1. **Plan data model first** before SQL queries
2. **Use PBIP from start** (not migrate from PBIX)
3. **Test on mobile earlier** (designed desktop-first)
4. **Create measure library** template upfront

### If More Time

1. Add Python for forecasting
2. Implement incremental refresh
3. Build mobile-specific layouts
4. Add more advanced analytics

---

## 📖 Resources I Used

**Learning:**

- SQLBI.com (DAX patterns)
- Microsoft Docs (Power BI)
- Guy in a Cube (YouTube)
- Stack Overflow (troubleshooting)

**Inspiration:**

- Power BI Community Gallery
- LinkedIn portfolio projects
- Kaggle notebooks

---

**Key Takeaway:** Start small, iterate often, document everything!

</aside>
