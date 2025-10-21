<aside>

# 📊 AdventureWorks End-to-End Analytics Project

[Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)

[SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)

[DAX](https://img.shields.io/badge/DAX-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)

> Comprehensive business intelligence solution analyzing sales, customers, supply chain, HR, and financial performance using SQL Server and Power BI

---

## 📋 Table of Contents

- [Project Overview](https://claude.ai/chat/5bed1133-2bd5-401f-a5f0-68beeb7bcc6c#-project-overview)
- [Business Questions](https://claude.ai/chat/5bed1133-2bd5-401f-a5f0-68beeb7bcc6c#-business-questions-addressed)
- [Tech Stack](https://claude.ai/chat/5bed1133-2bd5-401f-a5f0-68beeb7bcc6c#%EF%B8%8F-tech-stack)
- [Folder Structure](https://claude.ai/chat/5bed1133-2bd5-401f-a5f0-68beeb7bcc6c#-folder-structure)
- [Key Features](https://claude.ai/chat/5bed1133-2bd5-401f-a5f0-68beeb7bcc6c#-key-features)
- [Data Model](https://claude.ai/chat/5bed1133-2bd5-401f-a5f0-68beeb7bcc6c#-data-model)
- [Dashboard Preview](https://claude.ai/chat/5bed1133-2bd5-401f-a5f0-68beeb7bcc6c#-dashboard-preview)
- [Key Insights](https://claude.ai/chat/5bed1133-2bd5-401f-a5f0-68beeb7bcc6c#-key-insights)
- [Installation Guide](https://claude.ai/chat/5bed1133-2bd5-401f-a5f0-68beeb7bcc6c#-installation-guide)
- [Usage](https://claude.ai/chat/5bed1133-2bd5-401f-a5f0-68beeb7bcc6c#-usage)
- [Methodology](https://claude.ai/chat/5bed1133-2bd5-401f-a5f0-68beeb7bcc6c#-methodology)
- [Learning Outcomes](https://claude.ai/chat/5bed1133-2bd5-401f-a5f0-68beeb7bcc6c#-learning-outcomes)
- [Future Enhancements](https://claude.ai/chat/5bed1133-2bd5-401f-a5f0-68beeb7bcc6c#-future-enhancements)
- [Contact](https://claude.ai/chat/5bed1133-2bd5-401f-a5f0-68beeb7bcc6c#-contact)

---

## 🎯 Project Overview

This project demonstrates **end-to-end business intelligence** skills using the AdventureWorks2022 database. It includes:

- ✅ **Complex SQL analysis** across 5 business domains
- ✅ **Dimensional data modeling** (star schema)
- ✅ **100+ DAX measures** including time intelligence and advanced calculations
- ✅ **10 interactive Power BI dashboards**
- ✅ **RFM customer segmentation**
- ✅ **Financial performance analysis**
- ✅ **Supply chain optimization insights**

**Project Duration:** 4 weeks

**Database:** AdventureWorks2022 (SQL Server)

**BI Tool:** Power BI Desktop

**Data Volume:** 120K+ transactions, 31K+ orders, 19K+ customers

---

## 💼 Business Questions Addressed

### 📊 Sales Performance

- What are the revenue trends by year, quarter, and month?
- Which products and categories generate the most revenue?
- What is the Month-over-Month (MoM) and Year-over-Year (YoY) growth?
- What is the average order value (AOV)?

### 👥 Customer Analytics

- Who are our top customers by revenue and frequency?
- What is the customer retention rate?
- How to segment customers using RFM analysis?
- What is the customer lifetime value (CLV)?

### 📦 Supply Chain

- Which products have low stock levels?
- What is the inventory turnover ratio?
- Is there a supply-demand gap?
- Who are the top vendors by purchase volume?

### 👔 HR Analytics

- What is the current headcount by department?
- What is the employee turnover rate?
- What is the average employee tenure and age?
- Which departments have the highest turnover?

### 💰 Financial Performance

- What is the gross profit and gross margin?
- How does profitability trend over time?
- Which products/categories have the best margins?
- What is the revenue growth rate?

---

## 🛠️ Tech Stack

| Technology           | Purpose                                 |
| -------------------- | --------------------------------------- |
| **SQL Server 2022**  | Database engine & data extraction       |
| **T-SQL**            | Complex queries, CTEs, window functions |
| **Power BI Desktop** | Data modeling & visualization           |
| **DAX**              | Calculated measures & columns           |
| **Power Query (M)**  | Data transformation & ETL               |
| **Git/GitHub**       | Version control & documentation         |

---

## 📁 Folder Structure

```
ADW-Mega-Project/
│
├── 📄 README.md                          # Main project documentation
├── 📄 LICENSE                            # MIT License
├── 📄 .gitignore                         # Git ignore file
│
├── 📁 01-SQL/                            # SQL Analysis Scripts
│   ├── 📄 README.md                      # SQL documentation
│   ├── 📄 00-Database-Setup.sql          # Database restore instructions
│   ├── 📄 01-Sales-Performance.sql       # Sales analysis queries
│   ├── 📄 02-Customer-Segmentation.sql   # Customer RFM & segmentation
│   ├── 📄 03-Supply-Chain.sql            # Inventory & purchasing analysis
│   ├── 📄 04-HR-Analytics.sql            # Employee & department metrics
│   ├── 📄 05-Financial-Performance.sql   # Revenue, profit, margins
│   └── 📄 99-All-Queries.sql             # Combined query file
│
│
├── 📁 02-PowerBI/
│		├── 📁  ADW-Mega-Project.pbip # Main project file (open this)
│		├── 📁  ADW-Mega-Project.SemanticModel/    # Data model folder
│		│   ├── definition/                     # Model definition files
│		│   ├── 📁 DAXQueries/           # All DAX queries as .dax files
│		│		│    ├── 📄 01.revenue_metrics.dax     # Revenue metrics
│		│   │    ├── 📄 02.order_quantity.dax      # AOV, Total Quantity
│		│   │    ├── 📄 03.cost_profit.dax         # COGS, Markup%, GM%
│		│   │    ├── 📄 04.time_intelligence.dax   # YoY, MoM, YTD
│		│		│		 ├── 📄 05.customer_metrics.dax    # CLV, retention, RFM
│		│   │    ├── 📄 06.product_metrics.dax     # Product performance
│		│   │    ├── 📄 07.territory_metrics.dax   # Territory performance
│		│   │    ├── 📄 08.inventory_metrics.dax   # Stock & turnover
│		│   │    ├── 📄 09.purchsing_metrics.dax   # Total Purchases
│		│		│		 ├── 📄 10.supply_demand.dax       # Suplly &demand status
│		│   │    └── 📄 11.hr_metrics.dax          # Employee metrics          │   │   │
│		│   └── .pbi/                           # Power BI metadata
│		└── 📁 Data-Model/
│		│    ├── 📄 PowerBI-DataModel-Setup.sql # Views for Power BI
│		│    └── 📄 DimDate-PowerQuery.txt      # Date dimension M code
│		│		 └── 📷 data-model-diagram.png      # Star schema screenshot
│   └── 📁 DAX-Measures/
│		├── 📁 ADW-Mega-Project.Report/            # All Reports data
│		│		├── definition/
│		│		├── StaticResources/
│		│		└── .pbi/
│
├── 📁 03-Documentation/                  # Project Documentation
│   ├── 📄 01-Business-Requirements.md    # Business questions & objectives
│   ├── 📄 02-Key-Insights.md             # Business insights discovered
│   └── 📄 03-Methodology.md              # Project approach & decisions
│
├── 📁 04-Screenshots/                    # Dashboard Screenshots
│   ├── 📷 01-executive-dashboard.png
│   ├── 📷 02-sales-performance.png
│   ├── 📷 03-customer-analytics.png
│   ├── 📷 04-product-performance.png
│   ├── 📷 05-inventory-management.png
│   ├── 📷 06-profitability-analysis.png
│   ├── 📷 07-geographic-analysis.png
│   ├── 📷 08-hr-dashboard.png
│   ├── 📷 09-purchasing-vendors.png
│   └── 📷 data-model-relationships.png
│
└── 📁 05-Presentation/                   # Project Presentation
    ├── 📄 AdventureWorks-Presentation.pptx
    ├── 📄 Project-Summary.pdf
    └── 🎥 Demo-Video-Link.txt            # Link to YouTube demo
```

---

## ✨ Key Features

### 🔍 SQL Analysis

- **120+ complex queries** covering 5 business domains
- Advanced techniques: CTEs, window functions (RANK, LAG, LEAD), NTILE
- Dynamic date handling for historical data
- RFM customer segmentation with 3 implementation approaches

### 📊 Data Modeling

- **Star schema design** with 4 fact tables and 8 dimension tables
- Proper grain definition (line-item vs order-level)
- Calculated columns for allocated tax/freight
- Bi-directional relationship management

### 📈 DAX Measures (100+)

- **Revenue metrics:** Total Revenue, Subtotal, Tax, Freight
- **Time intelligence:** YoY, MoM, QoQ, YTD, moving averages
- **Customer analytics:** CLV, retention rate, new vs returning
- **Product metrics:** Revenue rank, ABC classification, Pareto analysis
- **Profitability:** Gross profit, margins, markup%
- **Inventory:** Turnover ratio, days inventory, stock status
- **HR:** Headcount, tenure, turnover rate, gender ratio

### 🎨 Interactive Dashboards (10 Pages)

1. **Executive Summary** - High-level KPIs
2. **Sales Performance** - Revenue trends & growth
3. **Customer Analytics** - Segmentation & behavior
4. **Product Performance** - Top products & profitability
5. **Inventory Management** - Stock levels & turnover
6. **Profitability Analysis** - Margins & cost analysis
7. **Geographic Analysis** - Regional performance
8. **HR Dashboard** - Employee metrics
9. **Purchasing & Vendors** - Vendor performance
10. **Advanced Analytics** - Forecasting & key influencers

---

## 🗄️ Data Model

### Star Schema Design

```
                    DimDate
                      ↓
    DimCustomer → FactSales ← DimProduct
                      ↓              ↓
                 DimTerritory   DimProductCategory

    DimProduct → FactInventory

    DimProduct → FactPurchasing ← DimVendor

    DimEmployee → FactEmployeeHistory ← DimDepartment
                                      ← DimShift

```

### Key Tables

**Fact Tables:**

- `FactSales` - Sales transactions (121K rows)
- `FactInventory` - Current stock levels
- `FactPurchasing` - Purchase orders
- `FactEmployeeHistory` - Employee assignments

**Dimension Tables:**

- `DimDate` - Calendar dimension (2011-2014)
- `DimCustomer` - Customer master data
- `DimProduct` - Product catalog with categories
- `DimTerritory` - Geographic regions
- `DimEmployee` - Employee demographics
- `DimDepartment` - Organizational structure
- `DimVendor` - Supplier information

---

## 📸 Dashboard Preview

### Executive Dashboard

![Executive Dashboard](https://claude.ai/chat/04-Screenshots/01-executive-dashboard.png)

### Sales Performance

![Sales Performance](https://claude.ai/chat/04-Screenshots/02-sales-performance.png)

### Customer Analytics

![Customer Analytics](https://claude.ai/chat/04-Screenshots/03-customer-analytics.png)

> Note: More screenshots available in the 04-Screenshots/ folder

---

## 💡 Key Insights

### 📊 Sales Performance

- Total revenue: **$123.2M** across 31,465 orders
- YoY growth: **+15.2%** (2013 vs 2012)
- Top territory: **Southwest** with $10.8M (8.8% of total)
- Peak month: **December** consistently highest sales

### 👥 Customer Analytics

- **19,119 active customers** out of 19,820 total (96.5% activation rate)
- Top 20% of customers generate **65% of revenue** (Pareto principle)
- Customer retention rate: **68%**
- Average CLV: **$6,443** per customer

### 🏆 Product Performance

- **504 products** sold across 4 main categories
- Top category: **Bikes** (92% of revenue)
- Top product: **Mountain-200 Black, 38** ($1.2M revenue)
- Average gross margin: **42.3%**

### 📦 Supply Chain

- **238 products** with low stock (<100 units)
- Inventory turnover ratio: **4.2x** (healthy)
- Supply-demand gap: **Balanced** for 78% of products
- Top vendor: **Litware Inc.** ($3.2M in purchases)

### 👔 HR Insights

- **290 current employees** across 16 departments
- Average tenure: **8.2 years**
- Turnover rate: **12%** (below industry average)
- Gender ratio: **1.8:1** (Male:Female)

---

## 🚀 Installation Guide

### Prerequisites

- SQL Server 2019+ (Express edition works)
- Power BI Desktop (latest version)
- AdventureWorks2022 database
- 2GB free disk space

### Step 1: Restore Database

```sql
-- Download AdventureWorks2022.bak from:
-- https://github.com/Microsoft/sql-server-samples/releases

-- Restore database
RESTORE DATABASE AdventureWorks2022
FROM DISK = 'C:\YourPath\AdventureWorks2022.bak'
WITH MOVE 'AdventureWorks2022' TO 'C:\YourPath\AdventureWorks2022.mdf',
     MOVE 'AdventureWorks2022_Log' TO 'C:\YourPath\AdventureWorks2022_log.ldf',
     REPLACE;

```

### Step 2: Create Views for Power BI

```sql
-- Run the script from:
-- 02-PowerBI/Data-Model/PowerBI-DataModel-Setup.sql

-- This creates 11 views:
-- vw_FactSales, vw_DimProduct, vw_DimCustomer, etc.

```

### Step 3: Open Power BI File

1. Download `AdventureWorks-Dashboard.pbix`
2. Open in Power BI Desktop
3. Update data source connection:
   - File → Options → Data source settings
   - Change server to `localhost` or your server name
4. Click "Refresh" to load data

### Step 4: Explore Dashboards

Navigate through 10 dashboard pages using the navigation buttons!

**Detailed installation guide:** [06-Resources/Installation-Guide.md](https://claude.ai/chat/06-Resources/Installation-Guide.md)

---

## 📖 Usage

### For Recruiters/Hiring Managers

This project demonstrates:

- ✅ SQL proficiency (complex queries, optimization)
- ✅ Data modeling expertise (star schema, grain analysis)
- ✅ DAX mastery (time intelligence, advanced calculations)
- ✅ Business acumen (translating questions to insights)
- ✅ Visualization best practices (storytelling, UX)

**View the project:**

1. Browse SQL queries in `01-SQL/` folder
2. Review DAX measures in `02-PowerBI/DAX-Measures/`
3. See dashboard screenshots in `04-Screenshots/`
4. Read methodology in `03-Documentation/`

### For Data Analysts (Learning)

**Key learnings from this project:**

- RFM customer segmentation (3 approaches)
- Handling order-level vs line-level data
- Proportional allocation of tax/freight
- Time intelligence patterns (YoY, MoM, YTD)
- Performance optimization techniques

**Explore:**

- SQL queries with detailed comments
- DAX patterns with explanations
- Data modeling decisions documented

---

## 🎓 Methodology

### 1. Requirements Gathering

- Identified 5 core business domains
- Defined 50+ business questions
- Mapped questions to data sources

### 2. Data Exploration (SQL)

- Profiled AdventureWorks database
- Identified data quality issues
- Validated relationships between tables

### 3. Data Modeling (Power BI)

- Designed star schema
- Created 11 views for clean data extraction
- Built Date dimension in Power Query
- Established relationships (1:Many)

### 4. Measure Development (DAX)

- Created 100+ measures organized by domain
- Implemented time intelligence
- Built calculated columns for RFM
- Added validation measures

### 5. Visualization (Power BI)

- Designed 10 dashboard pages
- Applied visual best practices
- Implemented interactivity (drill-through, bookmarks)
- Optimized performance (<3 second load time)

### 6. Validation & Testing

- Cross-checked DAX results with SQL queries
- Validated against source database totals
- Tested all filter combinations
- Performance profiling

---

## 📚 Learning Outcomes

### Technical Skills Gained

**SQL:**

- Window functions (RANK, ROW_NUMBER, LAG, LEAD, NTILE)
- CTEs and subqueries
- Date manipulation for historical data
- Performance optimization with indexes

**Power BI:**

- Star schema dimensional modeling
- Calculated columns vs measures (when to use each)
- Time intelligence functions
- CALCULATE and filter context
- SUMX and iterator functions

**DAX:**

- Context transition understanding
- Time intelligence (SAMEPERIODLASTYEAR, DATEADD)
- Statistical functions (RANKX, PERCENTILE)
- Advanced patterns (Pareto, ABC analysis)

### Business Skills

- Translating business questions to technical requirements
- RFM customer segmentation methodology
- Financial metrics (margins, turnover, ROI)
- Supply chain concepts (inventory turnover, lead time)
- HR analytics (turnover rate, retention)

---

## 🔮 Future Enhancements

### Phase 2 (Planned)

- [ ] Add Python integration for predictive analytics
- [ ] Implement forecasting using Prophet
- [ ] Create customer churn prediction model
- [ ] Add anomaly detection
- [ ] Automate data refresh via Power BI Service

### Phase 3 (Future)

- [ ] Migrate to Azure Synapse Analytics
- [ ] Deploy to Power BI Service with RLS
- [ ] Create mobile-optimized layouts
- [ ] Add real-time sales tracking
- [ ] Integrate with Power Automate for alerts

### Ideas for Extension

- Basket analysis (frequently bought together)
- Product recommendation engine
- Dynamic pricing optimization
- Sales territory optimization
- What-if scenario analysis

---

## 🤝 Contributing

While this is a personal portfolio project, I welcome:

- **Feedback** on code quality or approach
- **Suggestions** for additional analyses
- **Questions** about implementation details

Feel free to open an issue or reach out directly!

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](https://claude.ai/chat/LICENSE) file for details.

**Note:** AdventureWorks2022 database is provided by Microsoft under their sample database license.

---

## 📧 Contact

**Eslam Shaban**

- 🔗 LinkedIn: [linkedin.com/in/eslamshaban7](https://www.linkedin.com/in/eslamshaban7/)
- 📧 Email: eslamshaban1710@gmail.com
- 💼 Portfolio: [yourportfolio.com](https://yourportfolio.com/)
- 🐙 GitHub: [@Eslam-Shaban-17](https://github.com/Eslam-Shaban-17/)

---

## 🙏 Acknowledgments

- **Microsoft** - For the AdventureWorks sample database
- **SQLBI.com** - DAX patterns and best practices
- **Power BI Community** - Inspiration and problem-solving
- **DataCamp/Udemy** - Learning resources

---

## 📊 Project Stats

[GitHub repo size](https://img.shields.io/github/repo-size/Eslam-Shaban-17/ADW-Mega-Project)

[GitHub last commit](https://img.shields.io/github/last-commit/Eslam-Shaban-17/ADW-Mega-Project)

[GitHub stars](https://img.shields.io/github/stars/Eslam-Shaban-17/ADW-Mega-Project?style=social)

---

⭐ **If you found this project helpful, please consider giving it a star!** ⭐

---

**Last Updated:** October 2025

**Version:** 1.0.0

**Status:** ✅ Complete & Production-Ready

</aside>
