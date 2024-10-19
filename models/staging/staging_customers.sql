{{ config(materialized='table') }}

/*********************************
clean up customers
*********************************/

with customers_clean as (
    select  id,
            name,
            gender,
            email,
            state,
            country,
            str_to_date(created_at,'%m/%d/%Y %H:%i:%s') created_at
    from    {{ ref('source_customers') }}
)

select  *
from    customers_clean