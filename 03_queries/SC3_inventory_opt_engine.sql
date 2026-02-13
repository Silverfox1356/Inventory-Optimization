USE inventory_db;
# Inventory Optimization Engine
WITH current_state AS (
    SELECT 
        product_id,
        AVG(inventory_level) AS current_avg_inventory,
        AVG(units_sold / NULLIF(inventory_level, 0)) * 365 AS current_turnover,
        SUM(CASE WHEN units_sold > inventory_level THEN 1 ELSE 0 END) AS current_stockouts
    FROM daily_transactions
    GROUP BY product_id
),
abc_classification AS (
    SELECT 
        product_id,
        category,
        total_revenue,
        CASE 
            WHEN ROUND(SUM(total_revenue) OVER (ORDER BY total_revenue DESC) * 100.0 / SUM(total_revenue) OVER (), 2) <= 80 THEN 'A'
            WHEN ROUND(SUM(total_revenue) OVER (ORDER BY total_revenue DESC) * 100.0 / SUM(total_revenue) OVER (), 2) <= 95 THEN 'B'
            ELSE 'C'
        END AS abc_class
    FROM (
        SELECT 
            dt.product_id,
            p.category,
            SUM(dt.units_sold * dt.price * (1 - dt.discount / 100)) AS total_revenue
        FROM daily_transactions dt
        JOIN products p ON dt.product_id = p.product_id
        GROUP BY dt.product_id, p.category
    ) AS revenue_calc
),
sales_stats AS (
    SELECT 
        product_id,
        AVG(units_sold) AS avg_daily_sales,
        STDDEV(units_sold) AS stddev_sales
    FROM daily_transactions
    GROUP BY product_id
),
proposed_state AS (
    SELECT 
        ss.product_id,
        abc.category,
        abc.abc_class,
        cs.current_avg_inventory,
        cs.current_turnover,
        cs.current_stockouts,
        ss.avg_daily_sales,
        ss.stddev_sales,
        CASE 
            WHEN abc.abc_class = 'A' THEN 2.33
            WHEN abc.abc_class = 'B' THEN 1.65
            ELSE 1.28
        END AS z_score,
        ROUND(CASE 
            WHEN abc.abc_class = 'A' THEN 2.33 * ss.stddev_sales * SQRT(7)
            WHEN abc.abc_class = 'B' THEN 1.65 * ss.stddev_sales * SQRT(7)
            ELSE 1.28 * ss.stddev_sales * SQRT(7)
        END, 0) AS safety_stock,
        ROUND(((ss.avg_daily_sales * 7) / 2) + CASE 
            WHEN abc.abc_class = 'A' THEN 2.33 * ss.stddev_sales * SQRT(7)
            WHEN abc.abc_class = 'B' THEN 1.65 * ss.stddev_sales * SQRT(7)
            ELSE 1.28 * ss.stddev_sales * SQRT(7)
        END, 0) AS proposed_avg_inventory
    FROM sales_stats ss
    JOIN abc_classification abc ON ss.product_id = abc.product_id
    JOIN current_state cs ON ss.product_id = cs.product_id
)
SELECT 
    ps.product_id,
    ps.category,
    ps.abc_class,
    ROUND(ps.current_avg_inventory, 0) AS current_avg_inventory,
    ROUND(ps.current_turnover, 2) AS current_turnover,
    ps.current_stockouts,
    CASE 
        WHEN ps.abc_class = 'A' THEN '99%'
        WHEN ps.abc_class = 'B' THEN '95%'
        ELSE '90%'
    END AS recommended_service_level,
    ps.safety_stock,
    ps.proposed_avg_inventory,
    ROUND((ps.avg_daily_sales * 365) / NULLIF(ps.proposed_avg_inventory, 0), 2) AS proposed_turnover,
    ROUND(ps.current_stockouts * 0.2, 0) AS projected_stockouts,
    ps.proposed_avg_inventory - ROUND(ps.current_avg_inventory, 0) AS inventory_increase_units,
    ROUND(((ps.proposed_avg_inventory - ps.current_avg_inventory) / NULLIF(ps.current_avg_inventory, 0)) * 100, 1) AS inventory_increase_pct,
    ROUND(((ps.current_turnover - ((ps.avg_daily_sales * 365) / NULLIF(ps.proposed_avg_inventory, 0))) / NULLIF(ps.current_turnover, 0)) * 100, 1) AS turnover_reduction_pct,
    ROUND((SELECT AVG(price) FROM daily_transactions WHERE product_id = ps.product_id), 2) AS avg_price,
    ROUND((ps.proposed_avg_inventory - ps.current_avg_inventory) * (SELECT AVG(price) FROM daily_transactions WHERE product_id = ps.product_id), 2) AS additional_investment
FROM proposed_state ps
ORDER BY ps.abc_class, ps.category, ps.product_id;