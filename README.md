# Olist E-commerce Analysis: Executive Dashboard

## 1. Project Overview
This project involves a deep-dive analysis of the Olist e-commerce dataset. The primary goal was to process and analyze sales, customer, and product data using **PostgreSQL** and to build an interactive executive dashboard in **Tableau** to monitor Key Performance Indicators (KPIs) and uncover strategic insights.

## 2. Tools Used
- **Database:** PostgreSQL
- **BI & Visualization:** Tableau
- **Version Control:** Git & GitHub

## 3. Key Business Questions
This dashboard is designed to answer the following critical business questions, providing a data-driven perspective for business decision-making:

*   **Q1: Business Growth:** What are the monthly sales and revenue trends? How does seasonality affect our business performance?
*   **Q2: Product Performance:** Which product categories are our main revenue drivers? Are there any hidden gems or underperforming categories?
*   **Q3: Customer & Regional Analysis:** Where are our key customer markets located? What is the geographic distribution of our sales?
*   **Q4: Operational Efficiency:** How efficient is our delivery process? Are we meeting our estimated delivery dates?
*   **Q5: Customer Loyalty:** What is the re-purchase rate of our customer base? How can we segment customers based on their value?

## 4. Dashboard & Data Source
- **Interactive Dashboard:**
    - [Key Overview](https://public.tableau.com/views/OlistDashboard-KeyOverview/ExecutiveOverview?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
    - [Product & Market Analysis](https://public.tableau.com/views/OlistDashboard-ProductMarket/ProductMarket?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
    - [Customer Insights](https://public.tableau.com/views/OlistDashboard-CustomerInsights/CustomerSegmentationValue?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
- **Data Source:** [Olist E-commerce Dataset on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

## 5. SQL & Analysis Highlights

This section presents the key SQL queries used to extract, transform, and aggregate data from the PostgreSQL database, along with the major insights derived from each analysis area.

### 5.1 Business Growth Analysis

To understand the overall performance and growth trajectory of Olist, monthly trends in orders and revenue were analyzed to identify patterns and seasonal effects.

```sql
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
```
This query aggregates the number of delivered orders and the total payment value on a monthly basis.

Key Insights:  
Consistent Upward Trend: Olist demonstrated a strong and consistent upward trend in both order volume and total revenue throughout 2017.
Significant Seasonal Peak: A remarkable surge in both metrics was observed in November 2017. This significant spike strongly suggests the successful impact of a major seasonal event like Black Friday, highlighting responsiveness to promotional activities.
Momentum into 2018: The positive momentum from late 2017 appears to carry into early 2018, indicating a healthy growth trajectory within the available data period. (Note: Data for late 2018 might be incomplete, limiting long-term trend analysis beyond the scope of this dataset.)

Recommendations:  
Analyze Peak Event Success: Conduct a deeper dive into the factors contributing to the November 2017 peak (e.g., specific promotions, popular products/sellers) to identify key success drivers that can be replicated.
Strategic Seasonal Planning: Leverage insights from identified seasonal peaks and trends to inform future marketing campaigns, inventory management, and logistics planning for similar events.


### 5.2 Product Performance Analysis

Understanding which products contribute most significantly to revenue is crucial for optimizing inventory, marketing, and sales strategies.

```sql
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
-- Join with the translation table and calculate average revenue per order
SELECT
    trans.product_category_name_english AS product_category,  -- translate category name to English
    pp.total_revenue,
    pp.total_orders,
    pp.total_revenue / pp.total_orders AS avg_revenue_per_order
FROM
    product_performance AS pp
JOIN -- Using JOIN ensures we only include categories with available English translations
    category_translation AS trans ON pp.product_category_name = trans.product_category_name
ORDER BY
    total_revenue DESC
LIMIT 10;
```

This query calculates the total revenue, number of orders, and average revenue per order for each product category, ranking them by total revenue.

Key Insights:  
Dominant Revenue Driver: The "health_beauty" category is the leading revenue generator, accounting for a significant portion of total sales. This indicates strong market demand and potential for further growth in this area.
High Volume vs. High Value: Categories like "bed_bath_table" and "sports_leisure" demonstrate a high volume of orders but a comparatively lower average revenue per order. In contrast, categories such as "computers_accessories" or "cool_stuff" might have higher average transaction values but contribute less to overall volume.
Strategic Importance: Identifying these different patterns helps distinguish between high-volume, lower-price item strategies and lower-volume, higher-value strategies.

Recommendations:  
Reinforce Leading Categories: Allocate significant marketing and inventory resources to top-performing categories like "health_beauty".
Optimize for Volume & Value: For high-volume, lower-price categories, explore strategies like product bundling or cross-selling higher-margin items. For high-value, lower-volume categories, focus on targeted marketing to reach specific customer segments.
Underperforming Analysis: Conduct further analysis on lower-ranked or underperforming categories to determine if they represent untapped potential or should be de-emphasized.

### 5.3 Regional Sales Analysis

Understanding the geographic distribution of sales is crucial for optimizing marketing spend, logistics, and market penetration strategies.

```sql
SELECT
    c.customer_state, -- Brazillian states
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
```
This query aggregates total orders and revenue by customer state to identify the primary geographic markets.

Key Insights:  
Sao Paulo's Dominance: Sao Paulo (SP) state accounts for an overwhelming majority of both orders and revenue, clearly highlighting it as the primary and most critical market for Olist.
Second-Tier Markets: Rio de Janeiro (RJ) and Minas Gerais (MG) are the next largest markets, but they follow distantly behind SP in terms of contribution.
High Geographic Concentration: Sales are heavily concentrated in a few key states, particularly within the Southeast region of Brazil. This indicates both strength in the core market and potential vulnerability to regional economic shifts.

Recommendations:  
Prioritize SP Market: Continue to strategically invest in strengthening market share, marketing efforts, and logistics infrastructure within the SP region while maintaining efficiency.
Develop Secondary Markets: Analyze customer behavior and market potential in RJ, MG, and other top states to develop targeted strategies for increased market penetration and reduce over-reliance on SP.
Logistics Optimization: Consider establishing or strengthening regional logistics hubs in high-volume states to improve delivery speed and cost-effectiveness.

### 5.4 Delivery Efficiency Analysis

Delivery speed and reliability are critical factors influencing customer satisfaction and repeat business in e-commerce. This analysis examines average delivery times and the rate of delayed shipments compared to estimates.

```sql
SELECT
    -- Average time interval normalized for readability (e.g., 27 hours becomes 1 day 3 hours)
    JUSTIFY_INTERVAL(AVG(o.order_delivered_customer_date - o.order_approved_at)) AS average_delivery_time,
    -- Average delivery time converted to a decimal number of days for easy comparison and calculation
    EXTRACT(EPOCH FROM AVG(o.order_delivered_customer_date - o.order_approved_at)) / (24*60*60) AS avg_delivery_time_days_decimal,
    COUNT(o.order_id) AS total_delivered_orders_count
FROM
    orders AS o
WHERE
    o.order_status = 'delivered'
    AND o.order_approved_at IS NOT NULL
    AND o.order_delivered_customer_date IS NOT NULL;

-- Query to calculate the delivery delay rate
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
```
The first query calculates the average time from order approval to customer delivery in different formats. The second query calculates the percentage of orders delivered after the estimated delivery date.

Key Insights:  
Average Delivery Time: The average time taken from order approval to customer delivery is approximately 12.13 days (using the decimal representation). The normalized interval is approximately 12 days 3 hours.
Significant Delay Rate: A notable 8.11% of delivered orders are delayed, meaning they reached the customer after the initially estimated delivery date.
Customer Impact: A high delivery delay rate directly impacts customer satisfaction, potentially leading to negative reviews and reduced likelihood of repeat purchases.

Recommendations:  
Root Cause Analysis: Conduct a detailed root cause analysis on delayed orders, investigating factors such as seller location, customer destination, product type, and specific shipping partners to identify bottlenecks.
Improve Estimation Accuracy: Review and potentially refine the estimated delivery date calculation process to set more realistic customer expectations.
Enhance Communication: Implement proactive communication strategies for delayed orders, providing timely updates and accurate revised delivery estimates to customers.
Logistics Optimization: Explore operational improvements in logistics, potentially including faster handovers to carriers or optimizing routes based on delay patterns.

### 5.5 Customer Loyalty and Value Analysis

Understanding customer behavior is key to driving repeat business and maximizing Customer Lifetime Value. This analysis examines the overall re-purchase rate and segments customers based on their purchasing frequency (Frequency) and total monetary value (Monetary) using **Window Functions (NTILE)** for segmentation.

```sql
-- Query to calculate overall re-purchase rate
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
        customers AS c2
    JOIN
        orders AS o ON c2.customer_id = o.customer_id
    WHERE o.order_status = 'delivered' -- Only count delivered orders
    GROUP BY
        customer_unique_id
) AS customer_order_counts ON c.customer_unique_id = customer_order_counts.customer_unique_id;

-- This query segments customers into four groups based on Frequency and Monetary values, and calculates the number and percentage of customers in each segment.
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
```
The first query calculates the overall re-purchase rate. The second query first calculates Frequency and Monetary metrics for each unique customer, then ranks them using NTILE window functions, defines customer segments based on these rankings, and finally calculates the size and percentage of total customers within each segment.

Key Insights:  
Low Overall Re-purchase: The overall re-purchase rate is 3.00%. This figure is relatively low, suggesting that the vast majority of Olist's customers are one-time buyers. This highlights a significant challenge and opportunity in improving customer retention.
Highly Bimodal Customer Distribution: The customer base exhibits a highly imbalanced distribution, primarily split into two large segments:
* 'Low-Value Infrequent': This segment is the largest, accounting for approximately 46.70% of total unique customers. These are primarily customers who made only a single, low-value purchase.
* 'High-Value Loyal': Surprisingly, this segment is also large, accounting for approximately 46.70% of total unique customers. These are customers who rank highly in both purchasing frequency and total monetary spend.
Small 'Middle' Segments: The 'Loyal (Lower Value)' and 'Promising (High Value)' segments, representing customers with mixed characteristics, are very small, each accounting for approximately 1.87% of the total customer base. This suggests customers tend to fall into either the one-time/low-value group or quickly become high-value/loyal, with fewer customers in transition between these states.

Recommendations:  
Prioritize High-Value Loyal Retention: Focus on nurturing and rewarding the existing 'High-Value Loyal' customers through exclusive programs, personalized offers, and exceptional service to ensure continued loyalty. Develop strategies to understand the specific factors driving their value and behavior.
Mass Conversion Strategy for Low-Value Infrequent: Develop scalable strategies aimed at converting a significant portion of the large 'Low-Value Infrequent' segment into repeat buyers. This could involve targeted follow-up campaigns, post-purchase discounts on relevant items, or highlighting the benefits of Olist's loyalty program (if any).
Analyze Transition Segments: Despite their small size, investigate the characteristics and purchase journeys of customers in the 'Loyal (Lower Value)' and 'Promising (High Value)' segments to identify potential triggers or barriers that could help transition more customers towards the 'High-Value Loyal' segment.
Optimize First Purchase Experience: Given the high volume of one-time buyers, a strong focus on optimizing the initial customer journey (website usability, product information accuracy, transparent pricing including freight, smooth checkout, timely delivery, and responsive customer service) is critical to making a positive first impression and increasing the likelihood of a second purchase.

---

## 8. Overall Conclusion and Strategic Recommendations

Based on the comprehensive analysis of Olist's 2017 e-commerce data, the following key conclusions and strategic recommendations are proposed to drive growth and improve business health in 2018 and beyond:

### Overall Conclusion:
Olist demonstrated significant growth in late 2017, notably influenced by seasonal events and driven by performance in key product categories and concentrated geographic markets, particularly São Paulo. However, for sustainable, long-term success, the business must address challenges related to a low overall customer re-purchase rate and the need to improve operational efficiency, especially concerning delivery times and delay rates. Reducing the heavy dependency on the dominant SP market through strategic expansion in secondary regions is also crucial for mitigating risk.

### Strategic Recommendations:

1.  **Market Expansion & Risk Mitigation:** While maintaining a strong focus on the core SP market, strategically invest in expanding market penetration and optimizing logistics in high-potential secondary markets (e.g., RJ, MG) to reduce geographic concentration risk and unlock new growth opportunities. Implement data-driven localized marketing campaigns.
2.  **Product Portfolio & Profitability Management:**  Continue to leverage high-performing categories (e.g., health beauty) and analyze underperformers. Implement strategies to improve the profitability of high-volume but lower-margin categories. Utilize insights from high-value/low-volume categories to inform product sourcing and targeting.
3.  **Operational Excellence in Delivery:** Conduct a deep-dive root cause analysis for the 8.11% delivery delay rate. Implement targeted operational improvements to reduce average delivery time and aim for a specific, measurable target for delay reduction (e.g., achieve less than 5% delay rate). Enhance transparent customer communication regarding shipping status and potential delays.
4.  **Customer Loyalty & Retention:** Address the low 3.00% overall re-purchase rate as a top priority. Leverage the identified customer segments (especially 'Low-Value Infrequent' and 'High-Value Loyal') to develop and implement personalized retention strategies, loyalty programs, and targeted communications aimed at increasing repeat purchases and maximizing customer lifetime value. Optimize the initial purchase experience to encourage first-time buyers to return.

These data-driven recommendations provide a framework for Olist's leadership to prioritize initiatives and allocate resources effectively to foster sustainable growth and improve key aspects of the business.

---
## 9. Tableau Dashboard Structure
The analysis findings are summarized and visualized in an interactive Tableau dashboards available on Tableau Public. The dashboards serve as a **visual executive summary** of the key insights derived from the data analysis.

[Link to the Interactive Tableau Dashboard on Tableau Public] <!-- 여기에 링크를 다시 한번 강조 -->

The dashboard is organized into the following key areas:

*   [**Key Overview:**](https://public.tableau.com/views/OlistDashboard-KeyOverview/ExecutiveOverview?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link) High-level KPIs and primary business trends.
*   **Product & Market Analysis:** Product category performance and regional sales distribution.
*   **Customer Insights:** Distribution and characteristics of customer segments.

**For detailed analysis findings, interpretations, and strategic recommendations corresponding to each visual presented in the dashboard, please refer to the comprehensive sections above (`## 5. SQL & Analysis Highlights` and `## 8. Overall Conclusion and Strategic Recommendations`).**

---
## 10. Technical Implementation Notes <!-- 기술적인 디테일 섹션 추가 제안 -->
Database Setup: The PostgreSQL database schema can be reproduced using the 00_database_setup.sql script found in the sql_queries folder. This script includes DROP, CREATE TABLE, and COPY commands.
Data Loading: Data was loaded into PostgreSQL using the COPY command in SQL (or can be automated using Python Pandas with df.to_sql for large files, handling potential CSV parsing issues).
Query Development: All SQL queries used for the Tableau dashboard are stored in the sql_queries folder, structured by analysis area (01_..., 02_..., etc.).
Environment Variables: Database credentials are managed securely using environment variables and loaded via the python-dotenv library, preventing sensitive information from being exposed in the code or version control.
