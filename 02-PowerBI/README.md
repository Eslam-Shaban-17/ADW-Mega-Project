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
├── ADW-Mega-Project.SemanticModel/    # Data model folder
│   ├── definition/                     # Model definition files
│   ├── DAXQueries/           # All DAX queries as .dax files
│		│    ├── 📄 01.revenue_metrics.dax     # Revenue metrics
│   │    ├── 📄 02.order_quantity.dax      # AOV, Total Quantity
│   │    ├── 📄 03.cost_profit.dax         # COGS, Markup%, GM%
│   │    ├── 📄 04.time_intelligence.dax   # YoY, MoM, YTD
│		│		 ├── 📄 05.customer_metrics.dax    # CLV, retention, RFM
│   │    ├── 📄 06.product_metrics.dax     # Product performance
│   │    ├── 📄 07.territory_metrics.dax   # Territory performance
│   │    ├── 📄 08.inventory_metrics.dax   # Stock & turnover
│   │    ├── 📄 09.purchsing_metrics.dax   # Total Purchases
│		│		 ├── 📄 10.supply_demand.dax       # Suplly &demand status
│   │    └── 📄 11.hr_metrics.dax          # Employee metrics              │   │
│   └── .pbi/                           # Power BI metadata
└── Data-Model/
│    ├── PowerBI-DataModel-Setup.sql     # SQL views to run first
│    └── DimDate-PowerQuery.txt          # Date table M code
├── ADW-Mega-Project.Report/            # All Reports data
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

## DAX Measures (100+)

All measures are organized in the **`📊 Measures`** table with folders:

```
📊 Measures/
├── 💰 Revenue/ (6 measures)
├── 📦 Orders & Quantity/ (6 measures)
├── 💵 Cost & Profit/ (6 measures)
├── 📅 Time Intelligence/ (13 measures)
├── 👥 Customers/ (8 measures)
├── 🏆 Products/ (5 measures)
├── 🌍 Territory/ (2 measures)
├── 📦 Inventory/ (14 measures)
├── 🏭 Purchasing/ (4 measures)
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

## Dashboard Pages (10)

1. **Executive Summary** - High-level KPIs
2. **Sales Performance** - Revenue trends & growth
3. **Customer Analytics** - Segmentation & CLV
4. **Product Performance** - Top products & margins
5. **Inventory Management** - Stock levels & turnover
6. **Profitability** - Margins & cost analysis
7. **Geographic Analysis** - Regional performance
8. **HR Dashboard** - Employee metrics
9. **Purchasing** - Vendor analysis
10. **Advanced Analytics** - Forecasting & insights

## Setup Instructions

### 1. Create SQL Views First

```sql
-- Run this script in SSMS against AdventureWorks2022:
-- Data-Model/PowerBI-DataModel-Setup.sql

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

→ Create it using the M code in `Data-Model/DimDate-PowerQuery.txt`

### "Measures showing wrong values"

→ Check relationships in Model View (should all be 1:Many)

### "File too large"

→ The `.pbip` format is smaller than `.pbix`

→ If still large, check if you imported full tables instead of views

---

**Need help?** Open an issue or check the main [README.md](https://claude.ai/README.md)

</aside>
