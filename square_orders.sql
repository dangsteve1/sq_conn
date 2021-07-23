WITH order_line_item_aggregates as (

    SELECT
        order_id,
        sum(gross_sales_money) as order_gross_sales_money,
        sum(total_tax_money) as order_total_tax_money,
        sum(total_discount_money) as order_total_discount_money
        sum(total_money) as order_total_money
        count(*) as order_line_item_count
    FROM order_line_item
    GROUP BY 1

), orders as (

    SELECT
        *,
        order_gross_sales_money 
    FROM order
    JOIN order_line_item_aggregates.order_id = orders.id

), refunds as (

    SELECT * FROM refund
    WHERE status IN ('APPROVED','PENDING')

), refund_aggregates as (

    SELECT 
        order_id, 
        sum(amount_money) as order_refund_amount,
        sum(processing_fee_money) as order_processing_fee_refund_amount
    FROM refunds  

), order_adjustments as (

    SELECT
        order_return.source_order_id as order_id,
        order_return_line_item.*
    FROM order_return
    JOIN order_return_line_item on order_return_line_item.order_return_id = order_return.uid
    JOIN order_line_item on order_line_item.uid = order_return_line_item.source_line_item_id

), order_adjustments_aggregates as (

    SELECT
        order_id,
        sum(variation_total_price_money) as order_adjustment_variation_total_amount
        sum(gross_sales_money) as order_adjustment_gross_amount
        sum(total_tax_money) as order_adjustment_tax_amount
        sum(total_discount_money) as order_adjustment_discount_amount
        sum(total_money) as order_adjustment_total_amount
    FROM order_adjustments
    GROUP BY 1

), joined as (

    SELECT 
        orders.*,
        order_adjustments_aggregates.order_adjustment_amount,
        order_adjustments_aggregates.order_adjustment_tax_amount,
        refund_aggregates.order_refund_amount,
        (orders.total_money + coalesce(order_adjustments_aggregates.order_adjustment_amount,0) + coalesce(order_adjustments_aggregates.order_adjustment_tax_amount,0) - coalesce(refund_aggregates.order_refund_amount,0)) as order_adjusted_total,
        order_line_item_aggregates.order_line_item_count
    FROM orders
    LEFT JOIN order_line_item_aggregates 
        on orders.id = order_line_item_aggregates.order_id
    LEFT JOIN refund_aggregates
        on order.id = refund_aggregates.order_id
    LEFT JOIN order_adjustments_aggregates
        on orders.id = order_adjustments_aggregates.order_id

), windows as (

    select 
        *,
        row_number() over (partition by customer_id order by created_at) as customer_order_seq_number
    from joined

), new_vs_repeat as (

    select 
        *,
        case 
            when customer_order_seq_number = 1 then 'new'
            else 'repeat'
        end as new_vs_repeat
    from windows

)

select *
from new_vs_repeat