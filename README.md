# SQL Inventory Optimization System

A comprehensive MySQL-based inventory management and optimization solution designed for multi-store retail operations. This system provides automated reorder calculations, demand forecasting analysis, and real-time KPI dashboards to optimize inventory levels and reduce stockouts.

## 📋 Project Overview

This project implements a complete inventory optimization system using SQL for **Urban Retail Co.**, a multi-location retail chain operating across 5 stores with 30 products spanning 5 categories. The system analyzes 2 years of historical data (109,501 records) to provide actionable insights for inventory management.

### Key Objectives
- Automate inventory reorder point calculations
- Minimize stockouts while reducing excess inventory
- Analyze sales trends and seasonal patterns
- Monitor key performance indicators (KPIs)
- Optimize stock allocation across multiple locations

## 🎯 Features

### 1. Database Schema Design
- **Normalized relational database** following 3NF principles
- Dimension tables for stores, products, and dates
- Fact table for inventory and sales transactions
- Optimized indexing for query performance

### 2. Automated Reorder System
- Dynamic reorder point calculations based on:
  - Historical sales velocity
  - Lead time requirements
  - Safety stock levels
  - Seasonal demand patterns
- Automated alerts for low-stock items
- Optimal order quantity recommendations

### 3. KPI Dashboard Queries
- **Inventory Turnover Rate** by product and category
- **Stock-to-Sales Ratio** monitoring
- **Stockout Frequency** tracking
- **Carrying Cost Analysis**
- **Fill Rate** performance metrics
- **ABC Analysis** for inventory classification

### 4. Demand Forecasting Analysis
- Sales trend analysis with moving averages
- Seasonal pattern identification
- Forecast accuracy evaluation
- Weather and promotion impact analysis

### 5. Performance Analytics
- Store-level performance comparison
- Regional sales analysis
- Category profitability insights
- Discount effectiveness evaluation

## 📊 Database Schema

### Dimension Tables
- **dim_stores**: Store information (Store_ID, Region, Store_Name)
- **dim_products**: Product catalog (Product_ID, Category, Product_Name)
- **dim_dates**: Date dimension (Date, Year, Month, Quarter, Season, Is_Holiday)

### Fact Table
- **fact_inventory_sales**: Main transactional data
  - Date, Store_ID, Product_ID
  - Inventory_Level, Units_Sold, Units_Ordered
  - Price, Discount, Demand_Forecast
  - Weather_Condition, Competitor_Pricing

## 📈 Use Cases

1. **Inventory Managers**: Monitor stock levels and automate reorder decisions
2. **Supply Chain Analysts**: Optimize ordering patterns and reduce carrying costs
3. **Store Managers**: Track store-specific performance and inventory health
4. **Business Analysts**: Generate insights from sales trends and seasonal patterns
5. **Data Scientists**: Use as foundation for ML-based demand forecasting

## 🛠️ Technologies Used

- **Database**: MySQL 8.0
- **Query Language**: SQL
- **Data Volume**: 109,501 records
- **Time Span**: 2 years (2022-2023)
- **Update Frequency**: Daily transactions

## 📝 Key Insights & Results

- Identified optimal reorder points for 30 products across 5 stores
- Reduced stockout incidents by implementing automated alerts
- Improved inventory turnover through data-driven ordering decisions
- Discovered seasonal patterns affecting 5 product categories
- Analyzed impact of weather and promotions on sales velocity