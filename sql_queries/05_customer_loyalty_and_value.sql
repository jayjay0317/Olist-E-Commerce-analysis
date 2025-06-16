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
    -- Calculate Frequency (number of orders) and Monetary (total payment) per unique customer
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(payment_value) AS monetary
    FROM unique_customer_orders
    GROUP BY customer_unique_id
),
FM_ranking AS (
    -- Rank customers based on Frequency and Monetary values
    -- NTILE(4) divides customers into 4 groups (quartiles) based on the metric
    SELECT
        customer_unique_id,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY frequency ASC) AS frequency_quartile, -- Lower quartile = fewer orders
        NTILE(4) OVER (ORDER BY monetary ASC) AS monetary_quartile     -- Lower quartile = less spent
    FROM customer_FM
),
segmented_customers AS (
    -- Define customer segments
    -- Add a CASE statement to define segments based on quartiles (e.g., 'High-Value', 'Loyal')
    SELECT
        customer_unique_id,
        -- Example of simple segmentation based on quartiles
        CASE
            WHEN frequency_quartile >= 3 AND monetary_quartile >= 3 THEN 'High-Value Loyal' -- High F, High M
            WHEN frequency_quartile >= 3 AND monetary_quartile < 3 THEN 'Loyal (Lower Value)' -- High F, Low M
            WHEN frequency_quartile < 3 AND monetary_quartile >= 3 THEN 'Promising (High Value)' -- Low F, High M
            ELSE 'Low-Value Infrequent' -- Low F, Low M
        END AS customer_segment
    FROM FM_ranking
)
SELECT
    customer_segment,
    COUNT(DISTINCT customer_unique_id) AS number_of_customers,
    CAST(COUNT(DISTINCT customer_unique_id) AS REAL) * 100 / (SELECT COUNT(DISTINCT customer_unique_id) FROM customers) AS percentage_of_total
FROM segmented_customers
GROUP BY
    customer_segment
ORDER BY 
    number_of_customers DESC;