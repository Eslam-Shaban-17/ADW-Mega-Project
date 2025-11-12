<aside>

# 📊 Power BI Dashboard Files

## Project Format

This Power BI project uses **PBIP format** (Project file) instead of PBIX, which allows:

- ✅ Better version control (Git-friendly)
- ✅ Separate DAX queries in text files
- ✅ Team collaboration
- ✅ Component-level tracking

## Folder Structure

```
02-PowerBI/
├── ADW-Mega-Project.pbip # Main project file (open this)
├── ADW-Mega-Project.SemanticModel/             # Data model folder
│   ├── definition/                             # Model definition files
│   ├── DAXQueries/                             # All DAX queries as .dax files
│	│	 ├── 📄 01.revenue_metrics.dax         # Revenue metrics
│   │    ├── 📄 02.order_quantity.dax          # AOV, Total Quantity
│   │    ├── 📄 03.cost_profit.dax             # COGS, Markup%, GM%
│   │    ├── 📄 04.time_intelligence.dax       # YoY, MoM, YTD
│	│    ├── 📄 05.customer_metrics.dax        # CLV, retention
│   │    ├── 📄 06.customer_segment_RFM.dax    # RFM segmentation
│   │    ├── 📄 07.product_metrics.dax         # Product performance
│   │    ├── 📄 08.territory_metrics.dax       # Territory performance
│   │    ├── 📄 09.inventory_metrics.dax       # Stock & turnover
│   │    ├── 📄 10.purchsing_metrics.dax       # Total Purchases
│	│	 ├── 📄 11.supply_demand.dax           # Supply & demand status
│   │    └── 📄 12.hr_metrics.dax              # Employee metrics
│   └── .pbi/                                  # Power BI metadata
└── Data-Model/
│    ├── PowerBI_DataModel_Setup.sql           # SQL views to run first
│    ├── data_modeling_diagram.png             # Data model diagram
│    └── final_database_Diagram.png            # Final Data model diagram after adding calculated tables
├── ADW-Mega-Project.Report/                   # All Reports data
│		├── definition/
│		├── StaticResources/
│		└── .pbi/
```

## Opening the Project

### ✅ With PBIP (Recommended)

1. Open **Power BI Desktop** (latest version)
2. File → Open → Browse to `ADW-Mega-Project.pbip`
3. Project opens with full version control support

### ⚠️ If You Have PBIX

- The old `.pbix` file is in `/archive/` folder
- Use it if your Power BI doesn't support PBIP yet

## Data Model

### Star Schema Overview

- **4 Fact Tables:** Sales, Inventory, Purchasing, Employee History
- **8 Dimension Tables:** Date, Customer, Product, Territory, Vendor, Employee, Department, Shift
- **121K+ rows** in main fact table
- **31K orders, 19K customers**

### Calculated Columns

I added these columns in Power BI (not in SQL):

**FactSales:**

- `LineProportionOfOrder` - Line's share of order total
- `TaxAllocated` - Proportionally allocated tax per line
- `FreightAllocated` - Proportionally allocated freight per line
- `LineTotalFull` - Line total including tax & freight

### Calculated Tables

I created these calculated tables to support advanced analytics:

**1. CustomerRFM** - RFM segmentation table
- Calculates Recency, Frequency, and Monetary values per customer
- **Columns:**
  - `LastPurchase` - Last purchase date
  - `Frequency` - Number of distinct orders
  - `Monetary` - Total revenue per customer
  - `RecencyDays` - Days since last purchase
  - `MaxDataDate` - Maximum date in dataset (calculated column)
  - `RFM Recency Score` - Score 1-5 (calculated column)
  - `RFM Frequency Score` - Score 1-5 (calculated column)
  - `RFM Monetary Score` - Score 1-5 (calculated column)
  - `RFM Score` - Combined score (R*100 + F*10 + M)
  - `RFM Segment` - Customer segment (Champions, Loyal Customers, Potential Loyalists, Needs Attention, At Risk, Lost)

**2. CustomerSummary** - Customer performance summary
- Aggregates customer-level metrics
- **Columns:**
  - `TotalRevenue` - Total revenue per customer
  - `TotalOrders` - Total order count
  - `CLV` - Customer Lifetime Value (Revenue/Orders)
  - `CLV Category` - CLV category 0-5 (calculated column)
  - `CLV Range` - CLV range labels (calculated column)

**3. ProductInventory** - Product inventory status
- Combines product and inventory data with status indicators
- **Columns:**
  - `StockQty` - Current stock quantity
  - `InventoryValue` - Total inventory value
  - `StockStatus` - Status (Out of Stock, Critical, Low, Normal, Overstocked)

**4. ProfitSteps** - Profit waterfall steps
- Static table for profit decomposition visualization
- **Columns:**
  - `Step` - Profit step name (Revenue, COGS, Freight, Tax, Gross Profit)
  - `SortOrder` - Display order

## DAX Measures (100+)

All measures are organized in the **`📊 Measures`** table with folders:

```
📊 Measures/
├── 💰 Revenue/ (6 measures)
├── 📦 Orders & Quantity/ (6 measures)
├── 💵 Cost & Profit/ (6 measures)
├── 📅 Time Intelligence/ (13 measures)
├── 👥 Customers/ (13 measures)
├── 👥 Customer_Segment_RFM/ (16 measures)
├── 🏆 Products/ (8 measures)
├── 🌍 Territory/ (3 measures)
├── 📦 Inventory/ (17 measures)
├── 🏭 Purchasing/ (5 measures)
├── 🔍 Supply-Demand/ (3 measures)
└── 👔 HR/ (7 measures)

```

### Key Measures Examples

```
// Revenue (allocated approach)
Total Revenue = [Subtotal Amount] + [Total Tax] + [Total Freight]

// Time intelligence
Revenue YoY % = DIVIDE([Total Revenue] - [Revenue LY], [Revenue LY], 0)

// Customer metrics
Customer Lifetime Value =
    AVERAGEX(VALUES(DimCustomer[CustomerID]), CALCULATE([Total Revenue]))

```

## Dashboard Pages (12)

1. **Overview Dashboard** - High-level KPIs & executive summary
2. **Sales Performance** - Revenue trends & growth
3. **Customer Analytics** - Segmentation & CLV
4. **RFM Segmentation** - Customer RFM analysis & scoring
5. **Product Performance** - Top products & margins
6. **Inventory Management** - Stock levels & turnover
7. **Profitability Analysis** - Margins & cost analysis
8. **Geographic Analysis** - Regional performance
9. **HR Dashboard** - Employee metrics
10. **Purchasing & Vendor** - Vendor analysis
11. **Advanced Analytics** - Forecasting & insights
12. **Q&A Visual** - Natural language query interface

## Setup Instructions

### 1. Create SQL Views First

```sql
-- Run this script in SSMS against AdventureWorks2022:
-- Data-Model/PowerBI_DataModel_Setup.sql

```

### 2. Open Project & Update Connection

```
File → Options → Data source settings
Update server name to: localhost (or your server)

```

### 3. Refresh Data

```
Home → Refresh (takes ~30 seconds)

```

### 4. Verify

```
// Check row count (should be 121,317)
Fact Table Rows = COUNTROWS(FactSales)

```

## Performance Optimization

What I did to keep dashboard fast:

- ✅ Used calculated columns for frequently-used allocations
- ✅ Hid unnecessary columns
- ✅ Created proper star schema
- ✅ Limited visuals per page (6-8 max)
- ✅ Used measures instead of calculated columns where possible

**Load time:** ~3 seconds

**Refresh time:** ~30 seconds

## Troubleshooting

### "Can't connect to data source"

→ Update server name in data source settings

### "Can't find DimDate table"

→ Create it using Power Query M code (Date table is created in the model)

### "Measures showing wrong values"

→ Check relationships in Model View (should all be 1:Many)

### "File too large"

→ The `.pbip` format is smaller than `.pbix`

→ If still large, check if you imported full tables instead of views

---

**Need help?** Open an issue or check the main [README.md](https://claude.ai/README.md)

</aside>
