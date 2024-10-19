{{ config(materialized='view') }}

/*********************************
view monthly kpi

aggregate fact customer transaction by month

designed to measure the following KPIs:

Gross Merchandise Value (GMV) - total value of goods sold before deductions
Average Order Value (AOV) - mean value of a single purchase order
Average Basket Size (ABS) - mean count of items in a single purchase order
Active Customers (AC) - count of unique customers making a purchase

this should cover question 1
*********************************/


with by_month as (

	select	date_format(transaction_date,'%y') as year_num,
            date_format(transaction_date,'%m') as month_num,

			/*********************************
            measures like AC,AOV,ABS presumed to exclude discounts
            considered formatting here. decided to leave to reporting tool of choice.
            *********************************/
            sum(order_total_items_price_gmv) as GMV,
            sum(order_total_items_price) / count(case when is_refunded = 0 then 1 else 0 end) AOV,
            sum(order_total_items_quantity) / count(case when is_refunded = 0 then 1 else 0 end) ABS,
            count(distinct case when is_refunded = 0 then customer_id else null end) AC

	from 	{{ ref('mart_fact_customer_transactions') }}
    group by
        date_format(transaction_date,'%y'),
        date_format(transaction_date,'%m')
)

select  *
from    by_month
order by year_num, month_num

