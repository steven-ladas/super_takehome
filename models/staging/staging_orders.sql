{{ config(materialized='table') }}

/*********************************
clean up orders
*********************************/

with orders_clean as (
    select  id,
            customer_id,
            currency,
            total_price,
            str_to_date(created_at,'%m/%d/%Y %H:%i:%s') created_at,
            str_to_date(refunded_at,'%m/%d/%Y %H:%i:%s') refunded_at
    from    {{ ref('source_orders') }}
)

select  *
from    orders_clean
