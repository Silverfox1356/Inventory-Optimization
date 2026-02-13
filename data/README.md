# Inventory Forecasting Dataset

## Overview

This dataset contains comprehensive inventory, sales, and operational data for a multi-store retail operation spanning two years of daily transactions.

## Dataset Summary

- **File Name**: `inventory_forecasting.csv`
- **Total Records**: 109,501 data records (plus 1 header row)
- **Time Period**: January 1, 2022 to December 31, 2023
- **Number of Stores**: 5 stores (S001 to S005)
- **Number of Products**: 30 unique products (SKUs)
- **Product Categories**: 5 categories
- **Geographic Regions**: 4 regions

## File Information

- **Format**: CSV (Comma-Separated Values)
- **Encoding**: UTF-8 with BOM
- **Date Format**: DD-MM-YYYY
- **Delimiter**: Comma (,)
- **File Size**: Approximately 10 MB

## Column Descriptions

| Column Name | Data Type | Description | Example Values |
|-------------|-----------|-------------|----------------|
| **Date** | Date | Transaction date in DD-MM-YYYY format | 01-01-2022, 31-12-2023 |
| **Store ID** | String | Unique store identifier | S001, S002, S003, S004, S005 |
| **Product ID** | String | Unique product identifier | P0001, P0096, P0183 |
| **Category** | String | Product category | Electronics, Clothing, Furniture, Toys, Groceries |
| **Region** | String | Geographic region of the store | North, South, East, West |
| **Inventory Level** | Integer | Current stock quantity on hand | 50, 158, 231 |
| **Units Sold** | Integer | Number of units sold on the date | 48, 134, 235 |
| **Units Ordered** | Integer | Number of units ordered for replenishment | 39, 142, 211 |
| **Demand Forecast** | Float | Predicted demand for the product | 68.62, 152.36, 248.23 |
| **Price** | Float | Product selling price in USD ($) | 13.99, 40.88, 95.56 |
| **Discount** | Integer | Discount percentage applied | 0, 5, 10, 15, 20 |
| **Weather Condition** | String | Weather on transaction date | Sunny, Rainy, Cloudy, Snowy |
| **Holiday/Promotion** | Binary | Holiday or promotion indicator | 0 = Normal day, 1 = Holiday/Promotion |
| **Competitor Pricing** | Float | Competitor's price for similar product in USD ($) | 12.67, 42.39, 98.30 |
| **Seasonality** | String | Season of the year | Winter, Spring, Summer, Fall |

## Data Characteristics

### Categories Breakdown
- **Electronics**: Consumer electronics and gadgets
- **Clothing**: Apparel and fashion items
- **Furniture**: Home and office furniture
- **Toys**: Recreational and entertainment products
- **Groceries**: Food and daily essentials

### Regional Distribution
- **North**: Northern region stores
- **South**: Southern region stores
- **East**: Eastern region stores
- **West**: Western region stores

### Temporal Coverage
- **Duration**: 730 days (2 complete years)
- **Frequency**: Daily granularity
- **Seasons**: All four seasons represented

## Data Quality

- **Completeness**: All 109,501 records contain complete data with no missing values
- **Consistency**: Standardized format across all entries
- **Validity**: All numerical values are within realistic ranges
- **Currency**: All monetary values in USD ($)

## Sample Data

```csv
Date,Store ID,Product ID,Category,Region,Inventory Level,Units Sold,Units Ordered,Demand Forecast,Price,Discount,Weather Condition,Holiday/Promotion,Competitor Pricing,Seasonality
01-01-2022,S001,P0096,Toys,West,158,134,142,152.36,40.88,5,Sunny,1,42.39,Winter
01-01-2022,S001,P0016,Clothing,East,189,127,125,150.47,90.78,0,Rainy,0,84.16,Winter
01-01-2022,S001,P0031,Electronics,West,75,48,39,68.62,13.99,20,Rainy,0,12.67,Winter
```

## Usage Notes

- Date values should be converted to proper date format when importing into databases
- Binary fields (Holiday/Promotion) use 0/1 encoding
- Discount values are percentages (e.g., 10 means 10% discount)
- Price and Competitor Pricing are in USD
- Weather conditions are categorical text values

---

**Last Updated**: January 2026  
**Total Records**: 109,501  
**File Format**: CSV (UTF-8 with BOM)