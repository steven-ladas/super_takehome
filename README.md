Yougrow Data Mart

### Using the mart


#### good to knows:
my first crack at starting a DBT project (im sure there are some awkward decisions present)
used mysql 8 out of convenience (had a local setup already)
sample app data very small.  loaded as seeds.
three stages as resource prefixes:
    source  - from app source, the downloaded seed csvs.
    staging - any cleanup required on source.  This mainly meant transforming strings to datetimes and making some of the naming uniform.
    mart    - production resources used to generate KPIs or other conduct analyses.

##### question 1:
attempted answer with a single persisted model - mart_fact_customer_transactions
added view - mart_view_monthly_kpi

fact table aggregates everything as I wanted it.  I considered adding year/month here but instead choose to use the view.  I might choose to persist that view as a table if there were performance considerations.

###### RESULT OF select * from mart_view_monthly_kpi attached in /results

##### question 2:
attempted answers with mart_views...
  customer LTV by month - mart_view_customer_ltv
  customer CRR by month - mart_view_customer_crr

Both of these KPIs are aggregated by month.  If I was doing this again I might try and find a simpler approach.  I think it became a bit more complicated than I would have liked.  Perhaps prepping/staging more of the intermediate steps was in order.

On flexibility:

first purchase attributes and user demographics would require some rework here.  I imagine I could add this by persisting the customer IDs by cohort month in a separate model and then attaching customer specific dimensional attribution.

RESULT OF select * from mart_view_customer_ltv

###### RESULT OF select * from mart_view_customer_(ltv/crr) attached in /results

##### question 3:
Integration of a subscription product is an interesting idea.  I imagine it would be useful to separate the idea of a more customer driven purchase and one on a cadence.  I might make an indicator on the order suggesting it is part of a subscription.  I might use this indicator to remove subscriptions from certain KPIs.  The original KPIs might require some tuning if it is decided that a subscription not have a quantity as an example.