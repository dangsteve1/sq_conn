WITH order_line_item_aggregates as (

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
    FROM order
    JOIN order_line_item_aggregates.order_id = orders.id

), customer_order_aggregates as (
    
    SELECT
        customer_id,
        count(CASE WHEN state IN ('OPEN','COMPLETED')
                THEN 1
                ELSE 0 END) as cus_order_count,
        count(CASE WHEN state = 'CANCELED'
                THEN 1
                ELSE 0 END) as cus_canceled_order_count,
        count(*) as cus_total_order_count,        
        sum(total_money) as lifetime_total_spent,
        sum(refund_amount) as lifetime_total_refunded,
        sum(net_amount) as lifetime_net_total_amount,
        sum(total_tax_money) as lifetime_total_tax_money,
        sum(total_discount_money) as lifetime_total_discount_money,
        sum(order_gross_sales_money) as lifetime_gross_sales_money,
        (coalesce(lifetime_gross_sales_money,0) / (coalesce(cus_order_count,0)) as average_order_value,
        (coalesce(lifetime_net_total_amount,0) / (coalesce(cus_order_count,0)) as average_transaction_value,
        min(created_at) OVER (PARTITION BY customer_id) as cus_first_order,
        max(created_at) OVER (PARTITION BY customer_id) as cus_most_recent_order
    FROM orders
    GROUP BY 1

), square_customers as(
    
    SELECT
        customer.*,
        customer_order_aggregates.cus_first_order as first_order,
        customer_order_aggregates.cus_most_recent_order as most_recent_order,
        coalesce(average_order_value,0) as average_order_value,
        coalesce(lifetime_total_spent,0) as lifetime_total_spent,
        coalesce(lifetime_total_refunded,0) as lifetime_total_refunded,
        coalesce(lifetime_net_total_amount,0) as lifetime_net_total_amount,
        coalesce(cus_canceled_order_count,0) as lifetime_canceled_order_count,
        coalesce(cus_order_count,0) as lifetime_order_count        
    FROM customer
    LEFT JOIN customer_order_aggregates.customer_id = customer.id
)

SELECT *
FROM square_customers