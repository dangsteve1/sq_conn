-- CTE refers to square_customers.sql
WITH square_customers_joined as(

    SELECT * FROM square_customers

)
aov as (

    SELECT 
    ( sum(lifetime_gross_sales_money) / sum(lifetime_order_count) ) as average_order_value
    FROM square_customers_joined
    WHERE lifetime_order_count <> 0
)

SELECT * FROM aov