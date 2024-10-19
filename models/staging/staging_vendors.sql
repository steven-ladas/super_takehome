{{ config(materialized='table') }}

/*********************************
clean up vendors
*********************************/

with vendors_clean as (
    select  id,
            title,
            str_to_date(created_at,'%m/%d/%Y %H:%i:%s') created_at
    from    {{ ref('source_vendors') }}
)

select  *
from    vendors_clean
