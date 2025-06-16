/*
--------------------------------------------------------------------------------
-- Query for: 4. Delivery Efficiency Analysis
-- Description: This query calculates average delivery times and the delivery
--              delay rate based on estimated delivery dates.
--------------------------------------------------------------------------------
*/

-- Analyze average delivery time from order approval to customer delivery
-- Calculated only for successfully delivered orders
SELECT
    -- Average time interval normalized for readability (e.g., 27 hours becomes 1 day 3 hours)
    JUSTIFY_INTERVAL(AVG(o.order_delivered_customer_date - o.order_approved_at)) AS average_delivery_time,
    -- Average delivery time converted to a decimal number of days
    EXTRACT(EPOCH FROM AVG(o.order_delivered_customer_date - o.order_approved_at)) / (24*60*60) AS avg_delivery_time_days_decimal,
    COUNT(o.order_id) AS total_delivered_orders_count
FROM
    orders AS o
WHERE
    o.order_status = 'delivered'
    AND o.order_approved_at IS NOT NULL
    AND o.order_delivered_customer_date IS NOT NULL;

-- Analyze delivery delay rate
-- Check if the actual delivery date is after the estimated delivery date
SELECT
    COUNT(o.order_id) AS total_delivered_orders,
    COUNT(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN o.order_id ELSE NULL END) AS delayed_orders,
    CAST(COUNT(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN o.order_id ELSE NULL END) AS REAL) * 100 / COUNT(o.order_id) AS delay_rate_percentage
FROM
    orders AS o
WHERE
    o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL;