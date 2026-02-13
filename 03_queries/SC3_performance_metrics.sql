SELECT 
    p.category,
    SUM(dt.units_sold) AS total_units_sold,
    ROUND(AVG(dt.inventory_level), 0) AS avg_inventory_level,
    ROUND(AVG(dt.units_sold / NULLIF(dt.inventory_level, 0)) * 365,
            2) AS annual_turnover_ratio,
    CASE
        WHEN
            ROUND(AVG(dt.units_sold / NULLIF(dt.inventory_level, 0)) * 365,
                    2) > 200
        THEN
            'Very High'
        WHEN
            ROUND(AVG(dt.units_sold / NULLIF(dt.inventory_level, 0)) * 365,
                    2) >= 100
        THEN
            'High'
        WHEN
            ROUND(AVG(dt.units_sold / NULLIF(dt.inventory_level, 0)) * 365,
                    2) >= 50
        THEN
            'Moderate'
        ELSE 'Low'
    END AS performance_rating
FROM
    daily_transactions dt
        JOIN
    products p ON dt.product_id = p.product_id
GROUP BY p.category
ORDER BY annual_turnover_ratio DESC;

# ABC Analysis
SELECT 
    product_id,
    category,
    total_revenue,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2) AS revenue_pct,
    ROUND(SUM(total_revenue) OVER (ORDER BY total_revenue DESC) * 100.0 / SUM(total_revenue) OVER (), 2) AS cumulative_revenue_pct,
    CASE 
        WHEN ROUND(SUM(total_revenue) OVER (ORDER BY total_revenue DESC) * 100.0 / SUM(total_revenue) OVER (), 2) <= 80 THEN 'A'
        WHEN ROUND(SUM(total_revenue) OVER (ORDER BY total_revenue DESC) * 100.0 / SUM(total_revenue) OVER (), 2) <= 95 THEN 'B'
        ELSE 'C'
    END AS abc_classification,
    CASE 
        WHEN ROUND(SUM(total_revenue) OVER (ORDER BY total_revenue DESC) * 100.0 / SUM(total_revenue) OVER (), 2) <= 80 THEN 'High priority - maintain high service level'
        WHEN ROUND(SUM(total_revenue) OVER (ORDER BY total_revenue DESC) * 100.0 / SUM(total_revenue) OVER (), 2) <= 95 THEN 'Medium priority - balanced approach'
        ELSE 'Low priority - minimize inventory'
    END AS recommendation
FROM (
    SELECT 
        dt.product_id,
        p.category,
        ROUND(SUM(dt.units_sold * dt.price * (1 - dt.discount / 100)), 2) AS total_revenue
    FROM daily_transactions dt
    JOIN products p ON dt.product_id = p.product_id
    GROUP BY dt.product_id, p.category
) AS product_revenue
ORDER BY total_revenue DESC;

# Dead Stock Report
WITH last_sale_dates AS (
    SELECT 
        product_id,
        store_id,
        region,
        MAX(CASE WHEN units_sold > 0 THEN transaction_date END) AS last_sale_date
    FROM daily_transactions
    GROUP BY product_id, store_id, region
)
SELECT 
    ci.store_id,
    ci.product_id,
    ci.category,
    ci.region,
    lsd.last_sale_date,
    CASE 
        WHEN lsd.last_sale_date IS NULL THEN 999
        ELSE DATEDIFF('2023-12-31', lsd.last_sale_date)
    END AS days_since_last_sale,
    ci.inventory_level AS current_inventory,
    ROUND(ci.inventory_level * (SELECT AVG(price) FROM daily_transactions WHERE product_id = ci.product_id), 2) AS estimated_value,
    CASE 
        WHEN lsd.last_sale_date IS NULL THEN 'DISCONTINUE'
        WHEN DATEDIFF('2023-12-31', lsd.last_sale_date) > 180 THEN 'DISCONTINUE'
        ELSE 'CLEARANCE'
    END AS action
FROM vw_current_inventory ci
LEFT JOIN last_sale_dates lsd 
    ON ci.product_id = lsd.product_id 
    AND ci.store_id = lsd.store_id 
    AND ci.region = lsd.region
WHERE lsd.last_sale_date IS NULL 
   OR DATEDIFF('2023-12-31', lsd.last_sale_date) >= 90
ORDER BY days_since_last_sale DESC;

