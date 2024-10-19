{{ config(materialized='table') }}

/*********************************
clean up order line items

nothing needed here just passthru
*********************************/

with order_line_items_clean as (
    select  id,
            order_id,
            product_id,
            quantity,
            total_price
    from    {{ ref('source_order_line_items') }}
)

select  * 
from    order_line_items_clean
