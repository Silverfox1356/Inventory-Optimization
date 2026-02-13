CREATE VIEW vw_transaction_details AS
    SELECT 
        dt.*,
        p.category,
        ROUND(dt.price * (1 - dt.discount / 100), 2) AS final_price,
        ROUND(dt.units_sold * dt.price * (1 - dt.discount / 100),
                2) AS revenue
    FROM
        daily_transactions dt
            JOIN
        products p ON p.product_id = dt.product_id;