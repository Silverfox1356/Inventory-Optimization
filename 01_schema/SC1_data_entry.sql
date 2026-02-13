USE inventory_db;

DROP TABLE IF EXISTS staging_inventory;

CREATE TABLE staging_inventory (
    `Date` VARCHAR(20),
    `Store_ID` VARCHAR(50),
    `Product_ID` VARCHAR(50),
    `Category` VARCHAR(50),
    `Region` VARCHAR(50),
    `Inventory_Level` INT,
    `Units_Sold` INT,
    `Units_Ordered` INT,
    `Demand_Forecast` DECIMAL(10, 2),
    `Price` DECIMAL(10, 2),
    `Discount` INT,
    `Weather_Condition` VARCHAR(50),
    `Holiday_Promotion` INT,
    `Competitor_Pricing` DECIMAL(10, 2),
    `Seasonality` VARCHAR(50)
);

-- ============================================
-- IMPORTANT: USERS MUST UPDATE THIS PATH
-- Replace with your actual file location:
-- Windows example: 'C:/Users/YOUR_NAME/Downloads/inventory_forecasting.csv'
-- Mac example: '/Users/YOUR_NAME/Downloads/inventory_forecasting.csv'
-- Linux example: '/home/YOUR_NAME/Downloads/inventory_forecasting.csv'
-- ============================================

LOAD DATA LOCAL INFILE 'YOUR_PATH_HERE/inventory_forecasting.csv'
INTO TABLE staging_inventory
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

DROP TABLE IF EXISTS daily_transactions;

DROP TABLE IF EXISTS products;

DROP TABLE IF EXISTS stores;

CREATE TABLE stores (
    store_id VARCHAR(10) PRIMARY KEY
);

CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    category VARCHAR(50) NOT NULL
);

CREATE TABLE daily_transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_date DATE NOT NULL,
    store_id VARCHAR(10) NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    region VARCHAR(50) NOT NULL,
    inventory_level INT NOT NULL,
    units_sold INT NOT NULL,
    units_ordered INT NOT NULL,
    demand_forecast DECIMAL(10, 2) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(10, 2) NOT NULL,
    competitor_pricing DECIMAL(10, 2) NOT NULL,
    weather_condition VARCHAR(20),
    holiday_promotion BOOLEAN NOT NULL,
    seasonality VARCHAR(20) NOT NULL,
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO products
SELECT DISTINCT Product_ID, Category
FROM staging_inventory;

INSERT INTO stores
SELECT DISTINCT Store_ID
FROM staging_inventory;

INSERT INTO daily_transactions (
    transaction_date,
    store_id,
    product_id,
    region,
    inventory_level,
    units_sold,
    units_ordered,
    demand_forecast,
    price,
    discount,
    competitor_pricing,
    weather_condition,
    holiday_promotion,
    seasonality
)
SELECT 
    STR_TO_DATE(`Date`, '%d-%m-%Y'),
    Store_ID,
    Product_ID,
    Region,
    Inventory_Level,
    Units_Sold,
    Units_Ordered,
    Demand_Forecast,
    Price,
    Discount,
    Competitor_Pricing,
    Weather_Condition,
    Holiday_Promotion,
    Seasonality
FROM staging_inventory;