-- Customer orders
WITH order_line_item_aggregate as (

    SELECT
        order_id,
        sum(gross_sales_money) as order_gross_sales_money,
        sum(total_tax_money) as order_total_tax_money,
        sum(total_discount_money) as order_total_discount_money
        sum(total_money) as order_total_money
    FROM order_line_item
    GROUP BY 1

), orders as (

    SELECT
        *,
        order_gross_sales_money 
    FROM orders

), customer_order_totals as (
    
    SELECT
        customer_id,
        count(CASE WHEN state IN ('open','completed')
                THEN 1
                ELSE 0 END) as cus_order_count,
        count(CASE WHEN state = 'canceled'
                THEN 1
                ELSE 0 END) as cus_canceled_order_count,        
        sum(total_money) as cus_total_money,
        sum(refund_amount) as cus_refund_amount,
        sum(net_amount) as cus_net_amount,
        sum(total_tax_money) as cus_total_tax_money,
        sum(total_discount_money) as cus_total_discount_money
        sum(order_gross_sales_money) as cus_order_gross_sales_money
    FROM orders
    GROUP BY 1
)

SELECT *
FROM customer_order_totals