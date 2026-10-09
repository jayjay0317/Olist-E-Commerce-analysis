/*
--------------------------------------------------------------------------------
-- Query for: 5. Customer Loyalty & Value Analysis
-- Description: This query analyzes customer re-purchase behavior and calculates
--              Frequency and Monetary metrics for customer segmentation.
--------------------------------------------------------------------------------
*/

-- Part 1: Calculate overall re-purchase rate
-- A re-purchasing customer is defined as a customer_unique_id with more than one order_id.
SELECT
    COUNT(DISTINCT c.customer_unique_id) AS total_unique_customers,
    COUNT(DISTINCT CASE WHEN order_count > 1 THEN c.customer_unique_id ELSE NULL END) AS re_purchasing_customers,
    CAST(COUNT(DISTINCT CASE WHEN order_count > 1 THEN c.customer_unique_id ELSE NULL END) AS REAL) * 100 / COUNT(DISTINCT c.customer_unique_id) AS re_purchase_rate_percentage
FROM
    customers AS c
JOIN (
    -- Subquery to count orders per unique customer
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM
        customers AS c2 -- Using alias c2 to avoid conflict with outer query
    JOIN
        orders AS o ON c2.customer_id = o.customer_id
    WHERE o.order_status = 'delivered' -- Only count delivered orders
    GROUP BY
        customer_unique_id
) AS customer_order_counts ON c.customer_unique_id = customer_order_counts.customer_unique_id;

/*
--------------------------------------------------------------------------------
-- Part 2: RFM analysis for each unique customer focused on F and M (Frequency, Monetary)
-- This uses CTEs and Window Functions.
--------------------------------------------------------------------------------
*/


-- Customer segmentation based on purchase frequency
-- and total monetary value

WITH unique_customer_orders AS (
    -- Get all delivered orders for each unique customer
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        op.payment_value
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_payments op ON o.order_id = op.order_id
    WHERE o.order_status = 'delivered'
),

customer_FM AS (
    -- Calculate purchase frequency and total payment
    -- for each unique customer
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(payment_value) AS monetary
    FROM unique_customer_orders
    GROUP BY customer_unique_id
),

FM_ranking AS (
    -- Divide customers into quartiles based on
    -- total monetary value
    SELECT
        customer_unique_id,
        frequency,
        monetary,
        NTILE(4) OVER (
            ORDER BY monetary ASC, customer_unique_id
        ) AS monetary_quartile
    FROM customer_FM
),

segmented_customers AS (
    -- Classify customers based on actual purchase
    -- frequency and relative monetary value
    SELECT
        customer_unique_id,
        frequency,
        monetary,
        CASE
            WHEN frequency >= 2
                AND monetary_quartile >= 3
                THEN 'High-Value Repeat'

            WHEN frequency >= 2
                AND monetary_quartile < 3
                THEN 'Repeat (Lower Value)'

            WHEN frequency = 1
                AND monetary_quartile >= 3
                THEN 'High-Value One-Time'

            ELSE 'Low-Value One-Time'
        END AS customer_segment
    FROM FM_ranking
)

-- Calculate customer counts, percentages,
-- average purchase frequency, and monetary value
SELECT
    customer_segment,
    COUNT(*) AS number_of_customers,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM segmented_customers),
        2
    ) AS percentage_of_total,
    ROUND(
        AVG(frequency)::numeric, 2
    ) AS average_frequency,
    ROUND(
        AVG(monetary)::numeric, 2
    ) AS average_monetary
FROM segmented_customers
GROUP BY customer_segment
ORDER BY number_of_customers DESC;
