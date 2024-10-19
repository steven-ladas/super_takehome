{{ config(materialized='table') }}

/*********************************
clean up products 
*********************************/

with products_clean as (
    select  product as id,
            title,
            category,
            price,
            cost,
            vendor as vendor_id,
            str_to_date(created_at,'%m/%d/%Y %H:%i:%s') created_at
    from    {{ ref('source_products') }}
)

select  *
from    products_clean
