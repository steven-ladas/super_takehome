{{ config(materialized='table') }}

/*********************************
fact customer transactions

each record represents summary order detail, aggregating the line items details where necessary

designed to measure the following KPIs:

Gross Merchandise Value (GMV) - total value of goods sold before deductions
Average Order Value (AOV) - mean value of a single purchase order
Average Basket Size (ABS) - mean count of items in a single purchase order
Active Customers (AC) - count of unique customers making a purchase
Customer Lifetime Value (CLV) - total  value for a given customer
Customer Retention Rate* (CRR) - count of customers transacting in a specific

* CRR will require a little more finesse than this table facilitates

*********************************/

with agg_order_line_items as (

	select	order_id,
			sum(quantity) order_total_items_quantity,
			sum(total_price) order_total_items_price				
            /*********************************
            total price can come from order level but felt more appropriate
            to aggregate from line items
            *********************************/
	from 	{{ ref('staging_order_line_items') }}
    group by
		order_id
),

pre_refunds as (

    select  o.created_at as transaction_date,
            o.id as order_id,
            o.customer_id,
            agg_order_line_items.order_total_items_price,
            agg_order_line_items.order_total_items_quantity,
            case when o.refunded_at is not null then 1 else 0 end is_refunded

    from 	{{ ref('staging_orders') }} o 
            inner join 
            agg_order_line_items
    on      o.id = agg_order_line_items.order_id
)

select  transaction_date
        ,order_id
        ,customer_id
        ,order_total_items_price as order_total_items_price_gmv
        ,case when is_refunded = 1 then 0 else order_total_items_price end as order_total_items_price
        ,case when is_refunded = 1 then 0 else order_total_items_quantity end as order_total_items_quantity
        ,is_refunded
from 	pre_refunds 
