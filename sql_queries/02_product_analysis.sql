/*
--------------------------------------------------------------------------------
-- Query for: 2. Product Performance Analysis
-- Description: This query identifies the top 10 product categories by total revenue.
--              It also includes the number of unique orders and the average
--              revenue per order for each category.
--------------------------------------------------------------------------------
*/

--CTE to calculate sales metrics per product category
WITH product_performance AS (
    SELECT
        p.product_category_name, -- product category name in Portuguese
        SUM(oi.price + oi.freight_value) AS total_revenue,
        COUNT(DISTINCT oi.order_id) AS total_orders
    FROM
        order_items AS oi
    JOIN
        products AS p ON oi.product_id = p.product_id
    JOIN
        orders AS o ON oi.order_id = o.order_id
    WHERE
        o.order_status = 'delivered'
        AND p.product_category_name IS NOT NULL
    GROUP BY
        p.product_category_name
)
-- Join with the translation table and calculate average revenue
SELECT
    trans.product_category_name_english AS product_category,  -- translate to English
    pp.total_revenue,
    pp.total_orders,
    pp.total_revenue / pp.total_orders AS avg_revenue_per_order
FROM
    product_performance AS pp
JOIN -- Use JOIN instead of LEFT JOIN here, as we only need categories that have translation
    category_translation AS trans ON pp.product_category_name = trans.product_category_name
ORDER BY
    total_revenue DESC
LIMIT 10;