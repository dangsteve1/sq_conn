-- Customer average transaction value
WITH customer_order_totals_joined as (
    SELECT
        *
    FROM customer_order_totals

), customer_atv_details as (
    
    SELECT 
        customer_id,
        cus_net_amount,
        cus_order_count,
        (cus_net_amount / cus_order_count) as cus_average_transaction_value
    FROM customer_order_totals_joined

), customer_atv as (
    
    SELECT 
        customer_id,
        cus_average_transaction_value
    FROM customer_atv_details

), atv as (
    
    SELECT 
        (sum(cus_net_amount) / sum(cus_order_count) ) as total_average_transaction_value
    FROM customer_atv_details

)

SELECT * 
FROM atv