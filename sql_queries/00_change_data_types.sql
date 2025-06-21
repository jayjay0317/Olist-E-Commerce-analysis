/*
--------------------------------------------------------------------------------
-- Query for changing data types
-- Description: This query changes data types of the date columns into timestamp
---------------------------------------------------------------------------------
*/

ALTER TABLE order_items
ALTER COLUMN shipping_limit_date TYPE timestamp
USING shipping_limit_date::timestamp;

ALTER TABLE order_reviews
ALTER COLUMN review_creation_date TYPE timestamp
USING review_creation_date::timestamp;

ALTER TABLE order_reviews
ALTER COLUMN review_answer_timestamp TYPE timestamp
USING review_answer_timestamp::timestamp;

ALTER TABLE orders
ALTER COLUMN order_purchase_timestamp TYPE timestamp
USING order_purchase_timestamp::timestamp;

ALTER TABLE orders
ALTER COLUMN order_approved_at TYPE timestamp
USING order_approved_at::timestamp;

ALTER TABLE orders
ALTER COLUMN order_delivered_carrier_date TYPE timestamp
USING order_delivered_carrier_date::timestamp;

ALTER TABLE orders
ALTER COLUMN order_delivered_customer_date TYPE timestamp
USING order_delivered_customer_date::timestamp;

ALTER TABLE orders
ALTER COLUMN order_estimated_delivery_date TYPE timestamp
USING order_estimated_delivery_date::timestamp;