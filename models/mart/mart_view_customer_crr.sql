{{ config(materialized='view') }}

/*********************************
view customer crr

aggregate fact customer transaction by customer by month

designed to measure the following KPIs:

Customer Retention Rate

this should cover the other part of question 2

1 - get superset of customers and months
2 - get tots by specific months transacted
3 - combine
4 - agg over using window function

NOTE:  not sure this is the simplest way to get there
*********************************/

with year_and_month as (

    select  distinct
            date_format(transaction_date,'%y') as year_num,
            date_format(transaction_date,'%m') as month_num,
            date_format(transaction_date,'%y%m') as yyyymm
    from    {{ ref('mart_fact_customer_transactions') }}

),

customers as (

    select  customer_id,
            date_format(min(transaction_date),'%y') as cohort_year_num,
            date_format(min(transaction_date),'%m') as cohort_month_num,
            date_format(min(transaction_date),'%y%m') yyyymm
    from    {{ ref('mart_fact_customer_transactions') }}         
    group by
        customer_id
),

cohort_count as (

    select  cohort_year_num,
            cohort_month_num,
            count(*) as cohort_count
    from    customers         
    group by
        cohort_year_num,
        cohort_month_num
),

customers_by_month as (

    select  customers.customer_id,
            customers.cohort_year_num,
            customers.cohort_month_num,
            year_and_month.year_num,
            year_and_month.month_num
    from    customers
            cross join
            year_and_month
    where   year_and_month.yyyymm > customers.yyyymm
    -- do not need to include first month hence > here
),

customer_trans as (

	select	distinct
            date_format(transaction_date,'%y') as year_num,
            date_format(transaction_date,'%m') as month_num,
            customer_id
	from 	{{ ref('mart_fact_customer_transactions') }} 
),

cohort_by_month as (

select  customers_by_month.cohort_year_num,
        customers_by_month.cohort_month_num,
        customers_by_month.year_num subsequent_year_num,
        customers_by_month.month_num subsequent_month_num,

        -- measures
        count(distinct customer_trans.customer_id) repeat_transacting_customer_count

from    customers_by_month
        left join
        customer_trans
on      customers_by_month.year_num = customer_trans.year_num            
and     customers_by_month.month_num = customer_trans.month_num
and     customers_by_month.customer_id = customer_trans.customer_id

group by 
    customers_by_month.cohort_year_num, 
    customers_by_month.cohort_month_num,
    customers_by_month.year_num, 
    customers_by_month.month_num
)

select  cohort_by_month.*,
        100.00 * repeat_transacting_customer_count / cohort_count.cohort_count CRR,
        cohort_count.cohort_count
from    cohort_by_month
        inner join 
        cohort_count
on      cohort_by_month.cohort_year_num = cohort_count.cohort_year_num
and     cohort_by_month.cohort_month_num = cohort_count.cohort_month_num

order by 
    cohort_by_month.cohort_year_num, 
    cohort_by_month.cohort_month_num,
    cohort_by_month.subsequent_year_num, 
    cohort_by_month.subsequent_month_num    