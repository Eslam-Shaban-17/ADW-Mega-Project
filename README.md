
# 📊 AdventureWorks End-to-End Analytics Project

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge\&logo=powerbi\&logoColor=black)
![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge\&logo=microsoft-sql-server\&logoColor=white)
![DAX](https://img.shields.io/badge/DAX-0078D4?style=for-the-badge\&logo=microsoft\&logoColor=white)

> **Comprehensive BI solution analyzing sales, customers, supply chain, HR, and financial performance using SQL Server and Power BI**

---

## 🎯 Project Overview

The **AdventureWorks End-to-End Analytics Project** demonstrates full-stack business intelligence capabilities — from data modeling to visualization.

* ✅ Advanced **SQL analysis** across 5 business domains
* ✅ Dimensional **star schema modeling** for analytical efficiency
* ✅ Over **100 DAX measures** including time intelligence
* ✅ **10 interactive Power BI dashboards** built with business KPIs
* ✅ Deep **RFM customer segmentation** and profitability insights

**Duration:** 4 weeks
**Database:** AdventureWorks2022 (SQL Server)
**BI Tool:** Power BI Desktop
**Data Volume:** 120K+ transactions | 31K+ orders | 19K+ customers

---

## 💼 Business Questions Answered

### 📊 Sales

* What are the monthly, quarterly, and yearly revenue trends?
* Which product categories and regions drive the most sales?
* What’s the YoY growth rate and average order value?

### 👥 Customers

* Who are the most valuable and frequent buyers?
* What’s the retention rate and lifetime value (CLV)?
* How are customers segmented using RFM analysis?

### 📦 Supply Chain

* Which products have low stock levels or high turnover?
* Who are the top vendors by purchase volume?
* Is there a supply-demand imbalance?

### 👔 HR & Finance

* What’s the headcount, tenure, and turnover by department?
* How does profitability trend across time and products?
* Which categories have the best gross margins?

---

## 🛠️ Tech Stack

| Technology           | Purpose                              |
| -------------------- | ------------------------------------ |
| **SQL Server 2022**  | Database engine & data extraction    |
| **T-SQL**            | Querying, CTEs, and window functions |
| **Power BI Desktop** | Data modeling & visualization        |
| **DAX**              | KPIs and time intelligence measures  |
| **Power Query (M)**  | Data transformation & ETL            |
| **Git/GitHub**       | Version control & documentation      |

---

## 📁 Folder Structure

```
ADW-Mega-Project/
│
├── 01-SQL/                  → SQL scripts (sales, HR, finance, supply chain)
├── 02-PowerBI/              → Power BI files, DAX measures, data model
├── 03-Documentation/        → Business questions, methodology, insights
├── 04-Screenshots/          → Dashboard screenshots
└── 05-Presentation/         → Project slides & summary
```

---

## ✨ Key Features

### 🔍 SQL Analysis

* 120+ complex queries using joins, CTEs, and window functions
* Implemented RFM segmentation and CLV calculations
* Created analytical views for Power BI integration

### 🧱 Data Modeling

* Star schema with **4 fact** and **8 dimension** tables
* Proper **grain definition** for accurate aggregation
* Calendar and relationship management for time-series analysis

### 📈 DAX & KPIs

* Time intelligence: **YoY, MoM, YTD, QoQ**
* Customer metrics: CLV, retention, RFM scoring
* Profitability: gross margin, markup%, cost vs revenue
* Inventory metrics: stock status, turnover, reorder alerts

### 🎨 Power BI Dashboards

* Executive summary with cross-domain KPIs
* Sales, product, and customer performance reports
* Supply chain and HR analytics dashboards
* Interactive filters, drill-throughs, and bookmarks

---

## 🗄️ Data Model (Star Schema)

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

---

## 📸 Dashboard Preview

| Dashboard                    | Description                           |
| ---------------------------- | ------------------------------------- |
| **Executive Summary**        | Company-wide KPIs and trends          |
| **Sales Performance**        | Revenue, growth, and top products     |
| **Customer Analytics**       | RFM segmentation & CLV insights       |
| **Product Performance**      | Profitability by category             |
| **Inventory & Supply Chain** | Stock turnover and vendor performance |
| **HR Dashboard**             | Headcount, tenure, turnover rates     |

📂 More previews in `/04-Screenshots/`

---

## 💡 Key Insights

* 📈 **Revenue:** $123.2M total, +15.2% YoY growth
* 💰 **Profit Margin:** Average 42.3% across all categories
* 🏆 **Top Product:** Mountain-200 Black, 38 ($1.2M revenue)
* 👥 **Customer Retention:** 68%, top 20% generate 65% of revenue
* 🧳 **Inventory:** 238 low-stock products, turnover ratio 4.2x
* 👔 **HR:** 290 employees, avg tenure 8.2 years, 12% turnover

---

## 🎓 Learning Outcomes

### Technical

* Advanced SQL with window functions & optimization
* DAX modeling (CALCULATE, FILTER, context transitions)
* Power BI performance tuning & visualization best practices
* Star schema design and relationship management

### Business

* Translating business needs into analytical KPIs
* Building actionable dashboards for decision-making
* Applying RFM segmentation and profitability analysis

---

## 📧 Contact

**Eslam Shaban**
### 📧 [eslamshaban1710@gmail.com](mailto:eslamshaban1710@gmail.com)
### 🔗 [linkedin.com/in/eslamshaban7](https://www.linkedin.com/in/eslamshaban7/)
### 🐙 [github.com/Eslam-Shaban-17](https://github.com/Eslam-Shaban-17)

---

⭐ **If you found this project helpful, please star this repository!**


---

