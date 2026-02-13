CREATE VIEW vw_product_performance AS
    SELECT 
        dt.product_id,
        p.category,
        COUNT(DISTINCT dt.store_id) AS stores_selling,
        COUNT(DISTINCT dt.region) AS regions_active,
        SUM(dt.units_sold) AS total_units_sold,
        AVG(dt.inventory_level) AS avg_inventory_level,
        ROUND(AVG(dt.units_sold / NULLIF(dt.inventory_level, 0)) * 365,
                2) AS annual_turnover_ratio,
        ROUND(AVG(dt.price * (1 - dt.discount / 100)),
                2) AS avg_final_price,
        ROUND(SUM(dt.units_sold * dt.price * (1 - dt.discount / 100)),
                2) AS total_revenue,
        SUM(CASE
            WHEN dt.units_sold = 0 THEN 1
            ELSE 0
        END) AS days_with_zero_sales,
        SUM(CASE
            WHEN dt.units_sold > dt.inventory_level THEN 1
            ELSE 0
        END) AS stockout_days
    FROM
        daily_transactions dt
            JOIN
        products p ON p.product_id = dt.product_id
    GROUP BY dt.product_id , p.category;

SELECT 
    CASE
        WHEN units_sold / NULLIF(inventory_level, 0) < 0.2 THEN 'Under 20%'
        WHEN units_sold / NULLIF(inventory_level, 0) < 0.5 THEN '20-50%'
        WHEN units_sold / NULLIF(inventory_level, 0) < 0.8 THEN '50-80%'
        WHEN units_sold / NULLIF(inventory_level, 0) < 1.0 THEN '80-100%'
        ELSE 'Over 100%'
    END AS daily_turnover_bucket,
    COUNT(*) AS record_count,
    ROUND(COUNT(*) * 100.0 / (SELECT 
                    COUNT(*)
                FROM
                    daily_transactions),
            1) AS percentage
FROM
    daily_transactions
GROUP BY daily_turnover_bucket
ORDER BY daily_turnover_bucket;