{{ config(materialized='view') }}

/*********************************
view customer ltv

aggregate fact customer transaction by customer by month

designed to measure the following KPIs:

Customer lifetime value

this should cover part of question 2

1 - get superset of customers and months
2 - get tots by specific months transacted
3 - combine
4 - agg over using window function

NOTE:  in retrospect, maybe should have persisted a cust_by_month resource
*********************************/

with year_and_month as (

    select  distinct
            date_format(transaction_date,'%y') as year_num,
            date_format(transaction_date,'%m') as month_num,
            date_format(transaction_date,'%y%m') as yymm
    from    {{ ref('mart_fact_customer_transactions') }}

),

customers as (

    select  customer_id,
            date_format(min(transaction_date),'%y') as year_num,
            date_format(min(transaction_date),'%m') as month_num,
            date_format(min(transaction_date),'%y%m') yyyymm
    from    {{ ref('mart_fact_customer_transactions') }}         
    group by
        customer_id
),

customers_by_month as (

    select  customers.customer_id,
            year_and_month.year_num,
            year_and_month.month_num
    from    customers
            cross join
            year_and_month
    where   year_and_month.yyyymm >= customers.yyyymm
),

customer_trans as (

	select	date_format(transaction_date,'%y') as year_num,
            date_format(transaction_date,'%m') as month_num,
            customer_id,
            sum(order_total_items_price) total_price

	from 	{{ ref('mart_fact_customer_transactions') }} 
    group by
        date_format(transaction_date,'%y'),
        date_format(transaction_date,'%m'),
        customer_id
)

select  customers_by_month.year_num,
        customers_by_month.month_num,
        customers_by_month.customer_id,
        sum(total_price) over (
            partition by customers_by_month.customer_id
            order by customers_by_month.year_num, customers_by_month.month_num
        ) LTV
from    customers_by_month
        left join
        customer_trans
on      customers_by_month.year_num = customer_trans.year_num            
and     customers_by_month.month_num = customer_trans.month_num
and     customers_by_month.customer_id = customer_trans.customer_id
order by 
    customers_by_month.customer_id,
    customers_by_month.year_num, 
    customers_by_month.month_num