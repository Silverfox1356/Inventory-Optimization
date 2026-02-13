USE inventory_db;
#Promotion Impact Analysis
WITH promo_stats AS (
    SELECT 
        p.category,
        dt.holiday_promotion,
        AVG(dt.units_sold) AS avg_sales,
        ROUND(AVG(dt.units_sold * dt.price * (1 - dt.discount / 100)), 2) AS avg_revenue
    FROM daily_transactions dt
    JOIN products p ON dt.product_id = p.product_id
    GROUP BY p.category, dt.holiday_promotion
)
SELECT 
    no_promo.category,
    no_promo.avg_sales AS avg_sales_no_promo,
    promo.avg_sales AS avg_sales_with_promo,
    ROUND(((promo.avg_sales - no_promo.avg_sales) / NULLIF(no_promo.avg_sales, 0)) * 100, 1) AS sales_lift_pct,
    no_promo.avg_revenue AS avg_revenue_no_promo,
    promo.avg_revenue AS avg_revenue_with_promo,
    ROUND(((promo.avg_revenue - no_promo.avg_revenue) / NULLIF(no_promo.avg_revenue, 0)) * 100, 1) AS revenue_lift_pct
FROM promo_stats no_promo
JOIN promo_stats promo 
    ON no_promo.category = promo.category 
    AND no_promo.holiday_promotion = 0 
    AND promo.holiday_promotion = 1
ORDER BY sales_lift_pct DESC;

# Regional Performance Dashboard
SELECT 
    dt.region,
    COUNT(DISTINCT dt.store_id) AS stores_active,
    COUNT(DISTINCT dt.product_id) AS products_active,
    SUM(dt.units_sold) AS total_units_sold,
    ROUND(SUM(dt.units_sold * dt.price * (1 - dt.discount / 100)), 2) AS total_revenue,
    ROUND(AVG(dt.inventory_level), 0) AS avg_inventory,
    ROUND(AVG(dt.units_sold / NULLIF(dt.inventory_level, 0)) * 365, 2) AS annual_turnover_ratio,
    SUM(CASE WHEN dt.units_sold > dt.inventory_level THEN 1 ELSE 0 END) AS stockout_incidents,
    ROUND((SUM(CASE WHEN dt.units_sold > dt.inventory_level THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 1) AS stockout_rate_pct,
    RANK() OVER (ORDER BY SUM(dt.units_sold * dt.price * (1 - dt.discount / 100)) DESC) AS revenue_rank
FROM daily_transactions dt
GROUP BY dt.region
ORDER BY total_revenue DESC;