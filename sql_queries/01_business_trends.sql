/*
--------------------------------------------------------------------------------
-- Query for: 1. Business Growth & Health
-- Description: This query calculates the total number of orders and revenue per month
--              to analyze the overall business growth trend.
---------------------------------------------------------------------------------
*/

SELECT
    TO_CHAR(o.order_purchase_timestamp, 'YYYY-MM') AS month,
    COUNT(o.order_id) AS total_orders,
    SUM(p.payment_value) AS total_revenue
FROM
    orders AS o
JOIN
    order_payments AS p ON o.order_id = p.order_id
WHERE
    o.order_status = 'delivered'
GROUP BY
    month
ORDER BY
    month;