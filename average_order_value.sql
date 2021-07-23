-- Initial CTE references customer_order_totals.sql
WITH customer_order_totals_joined as (
    SELECT
        *
    FROM customer_order_totals

), customer_aov_details as (
    
    SELECT 
        customer_id,
        cus_order_gross_sales_money,
        cus_order_count,
        (cus_order_gross_sales_money / cus_order_count) as cus_average_order_value
    FROM customer_order_totals_joined

), customer_aov as (
    
    SELECT 
        customer_id,
        cus_average_order_value
    FROM customer_aov_details

), aov as (
    
    SELECT 
        (sum(cus_order_gross_sales_money) / sum(cus_order_count) ) as total_average_order_value
    FROM customer_aov_details

)

SELECT * 
FROM aov
