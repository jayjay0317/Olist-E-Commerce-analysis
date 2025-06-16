/*
--------------------------------------------------------------------------------
-- Query for: 3. Regional Sales Analysis
-- Description: This query calculates the total revenue and order count
--              per customer state and city to identify key markets.
--------------------------------------------------------------------------------
*/

-- Analyze sales performance by customer state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(op.payment_value) AS total_revenue
FROM
    customers AS c
JOIN
    orders AS o ON c.customer_id = o.customer_id
JOIN
    order_payments AS op ON o.order_id = op.order_id
WHERE
    o.order_status = 'delivered'
GROUP BY
    c.customer_state
ORDER BY
    total_revenue DESC
LIMIT 10;

-- Analyze sales performance by customer city (within top states)
SELECT
    c.customer_state,
    c.customer_city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(op.payment_value) AS total_revenue
FROM
    customers AS c
JOIN
    orders AS o ON c.customer_id = o.customer_id
JOIN
    order_payments AS op ON o.order_id = op.order_id
WHERE
    o.order_status = 'delivered'
    AND c.customer_state IN ('SP', 'RJ', 'MG', 'RS', 'PR', 'SC', 'BA', 'DF', 'ES', 'GO') -- Filter for top states
GROUP BY
    c.customer_state,
    c.customer_city
ORDER BY
    total_revenue DESC;