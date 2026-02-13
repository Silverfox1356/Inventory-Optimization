CREATE VIEW vw_current_inventory AS
    SELECT 
        dt.store_id,
        dt.product_id,
        p.category,
        dt.region,
        dt.inventory_level,
        dt.transaction_date AS last_updated
    FROM
        daily_transactions dt
            JOIN
        products p ON p.product_id = dt.product_id
    WHERE
        dt.transaction_date = (SELECT 
                MAX(transaction_date)
            FROM
                daily_transactions);
