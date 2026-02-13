SELECT 
    store_id,
    category,
    SUM(inventory_level) AS total_inventory,
    COUNT(DISTINCT product_id) AS product_count,
    ROUND(AVG(inventory_level), 0) AS avg_per_product
FROM
    vw_current_inventory
GROUP BY store_id , category
ORDER BY store_id , total_inventory ASC;

# Low stock alert system
with sales_last_30_days as (
	select
		product_id,
		store_id,
		region,
		avg(units_sold) as avg_daily_sales
	from daily_transactions
	where transaction_date>=date_sub('2023-12-31',interval 30 day)
	group by region, store_id, product_id
)
select 
	ci.region,
    ci.store_id,
    ci.category,
    ci.product_id,
    ci.inventory_level as current_inventory,
    round(s.avg_daily_sales,1) as avg_daily_sales_30days,
    round(ci.inventory_level/nullif(s.avg_daily_sales,0),1) as days_of_stock_remain,
    case
		when (ci.inventory_level/nullif(s.avg_daily_sales,0))<3 then 'CRITICAL'
        when (ci.inventory_level/nullif(s.avg_daily_sales,0))<7 then 'LOW'
	end as alert_status
from vw_current_inventory ci
join sales_last_30_days s
on ci.region=s.region and ci.store_id=s.store_id and ci.product_id=s.product_id
where (ci.inventory_level/nullif(s.avg_daily_sales,0))<7
order by days_of_stock_remain asc;

# Stockout Incident Analysis
WITH stockout_metric AS (
    SELECT
        dt.store_id,
        p.category,
        dt.region,
        COUNT(DISTINCT dt.transaction_date) AS total_days,
        SUM(CASE WHEN dt.units_sold > dt.inventory_level THEN 1 ELSE 0 END) AS stockout_days,
        ROUND(100.0 * SUM(CASE WHEN dt.units_sold > dt.inventory_level THEN 1 ELSE 0 END) 
              / COUNT(DISTINCT dt.transaction_date), 1) AS stockout_rate_pct
    FROM daily_transactions dt
    JOIN products p ON p.product_id = dt.product_id
    GROUP BY dt.store_id, p.category, dt.region
    HAVING SUM(CASE WHEN dt.units_sold > dt.inventory_level THEN 1 ELSE 0 END) > 0
)
SELECT 
    store_id,
    category,
    region,
    total_days,
    stockout_days,
    stockout_rate_pct,
    CASE 
        WHEN stockout_rate_pct > 10 THEN 'HIGH'
        WHEN stockout_rate_pct >= 5 THEN 'MODERATE'
        ELSE 'LOW'
    END AS severity
FROM stockout_metric
ORDER BY stockout_rate_pct DESC;

    