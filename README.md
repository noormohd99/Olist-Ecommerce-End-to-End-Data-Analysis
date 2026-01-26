# Olist E-commerce: End-to-End Data Analysis & Power BI Dashboard

## 📌 Project Overview
This project demonstrates a complete **end-to-end data analysis workflow** using the **Olist Brazilian E-commerce dataset**.  
The objective is to transform raw transactional data into **actionable business insights** and an **interactive Power BI dashboard** to support data-driven decision-making.

---

## 🧑‍💼 Role
Junior Data Analyst

---

## 🛠 Tools & Technologies
- **Excel** – Initial data exploration and data quality checks  
- **SQL** – Data modeling, joins, aggregations, and business analysis  
- **Python (Pandas, Matplotlib, Seaborn)** – Data cleaning and exploratory data analysis  
- **Power BI** – Data modeling, DAX measures, and interactive dashboard  

---

Olist-Ecommerce-End-to-End-Data-Analysis/
│
├── README.md
│
├── data/
│   ├── raw/
│   │   ├── olist_orders_dataset.csv
│   │   ├── olist_customers_dataset.csv
│   │   ├── olist_order_items_dataset.csv
│   │   ├── olist_products_dataset.csv
│   │   └── olist_payments_dataset.csv
│   │
│   └── processed/
│       └── olist_analytical_dataset.csv
│
├── sql/
│   ├── table_creation.sql
│   ├── data_validation_queries.sql
│   ├── business_analysis_queries.sql
│   └── reporting_views.sql
│
├── notebooks/
│   └── olist_eda_and_cleaning.ipynb
│
├── powerbi/
│   └── olist_ecommerce_dashboard.pbix
│
├── reports/
│   └── olist_business_insights_report.pdf
│
└── assets/
    ├── dashboard_overview.png
    ├── sales_trends.png
    └── data_model.png

---

## 🎯 Business Objectives
- Analyze sales and order trends over time  
- Understand customer purchasing behavior  
- Evaluate delivery performance and delays  
- Identify top-performing products and categories  

---

## ❓ Key Business Questions
- How do sales and orders trend over time?
- Which product categories generate the highest revenue?
- What payment methods are most frequently used?
- How long does order delivery take?
- Which customer regions contribute most to revenue?

---

## 🔄 Project Workflow

### 1. Data Understanding & Profiling
- Reviewed multiple relational tables (orders, customers, products, payments, sellers)
- Identified missing values, duplicates, and inconsistent data types

### 2. Data Cleaning & Preparation
- Cleaned and standardized data using Python
- Joined multiple tables into a single analytical dataset
- Handled missing delivery dates and invalid records

### 3. SQL Analysis
- Imported cleaned data into SQL
- Created tables with proper keys
- Wrote queries to analyze revenue, orders, customers, and delivery performance

### 4. Exploratory Data Analysis (EDA)
- Performed descriptive statistics and trend analysis
- Visualized sales, category performance, and delivery times

### 5. Power BI Dashboard
- Built a star-schema data model
- Created DAX measures:
  - Total Revenue
  - Total Orders
  - Average Order Value
  - Average Delivery Time
- Designed an interactive dashboard with filters and drill-downs

### 6. Insights & Reporting
- Summarized key insights
- Provided business recommendations
- Identified data limitations

---

## 📊 Dashboard Preview
![Dashboard Screenshot](assets/dashboard_overview.png)

---

## 📁 Project Structure

