USE inventory_db;
# Moving Average Demand
SELECT 
    transaction_date,
    product_id,
    category,
    store_id,
    region,
    units_sold,
    ROUND(AVG(units_sold) OVER (
        PARTITION BY product_id, store_id, region
        ORDER BY transaction_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 1) AS ma_7day,
    ROUND(AVG(units_sold) OVER (
        PARTITION BY product_id, store_id, region
        ORDER BY transaction_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ), 1) AS ma_30day,
    ROUND(AVG(units_sold) OVER (
        PARTITION BY product_id, store_id, region
        ORDER BY transaction_date
        ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
    ), 1) AS ma_90day
FROM (
    SELECT 
        dt.transaction_date,
        dt.product_id,
        p.category,
        dt.store_id,
        dt.region,
        dt.units_sold
    FROM daily_transactions dt
    JOIN products p ON dt.product_id = p.product_id
    WHERE dt.product_id IN ('P0016', 'P0031', 'P0046', 'P0057', 'P0066')
      AND dt.transaction_date >= DATE_SUB('2023-12-31', INTERVAL 100 DAY)
) AS recent_data
ORDER BY product_id, store_id, region, transaction_date;

# Seasonal Demand Patterns
WITH category_avg AS (
    SELECT 
        category,
        AVG(units_sold) AS category_avg_sales
    FROM daily_transactions dt
    JOIN products p ON dt.product_id = p.product_id
    GROUP BY category
)
SELECT 
    p.category,
    dt.seasonality,
    COUNT(DISTINCT dt.transaction_date) AS total_days,
    SUM(dt.units_sold) AS total_units_sold,
    ROUND(AVG(dt.units_sold), 1) AS avg_daily_sales,
    ROUND(AVG(dt.price * (1 - dt.discount / 100)), 2) AS avg_final_price,
    CASE 
        WHEN AVG(dt.units_sold) > ca.category_avg_sales * 1.1 THEN 'PEAK'
        WHEN AVG(dt.units_sold) < ca.category_avg_sales * 0.9 THEN 'OFF-PEAK'
        ELSE 'NORMAL'
    END AS season_performance
FROM daily_transactions dt
JOIN products p ON dt.product_id = p.product_id
JOIN category_avg ca ON p.category = ca.category
GROUP BY p.category, dt.seasonality, ca.category_avg_sales
ORDER BY p.category, FIELD(dt.seasonality, 'Winter', 'Spring', 'Summer', 'Autumn');

SELECT 
    p.category,
    dt.region,
    COUNT(*) AS total_forecasts,
    ROUND(AVG(dt.demand_forecast), 1) AS avg_forecast_demand,
    ROUND(AVG(dt.units_sold), 1) AS avg_actual_sales,
    ROUND(AVG(ABS(dt.units_sold - dt.demand_forecast)),
            1) AS avg_absolute_error,
    ROUND(AVG(ABS(dt.units_sold - dt.demand_forecast) / NULLIF(dt.units_sold, 0)) * 100,
            1) AS mape_pct,
    CASE
        WHEN AVG(ABS(dt.units_sold - dt.demand_forecast) / NULLIF(dt.units_sold, 0)) * 100 < 10 THEN 'Excellent'
        WHEN AVG(ABS(dt.units_sold - dt.demand_forecast) / NULLIF(dt.units_sold, 0)) * 100 < 20 THEN 'Good'
        WHEN AVG(ABS(dt.units_sold - dt.demand_forecast) / NULLIF(dt.units_sold, 0)) * 100 < 50 THEN 'Fair'
        ELSE 'Poor'
    END AS forecast_quality
FROM
    daily_transactions dt
        JOIN
    products p ON dt.product_id = p.product_id
WHERE
    dt.units_sold > 0
GROUP BY p.category , dt.region
ORDER BY mape_pct ASC;