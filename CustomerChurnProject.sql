CREATE DATABASE CustomerChurnDB;
GO

use customerchurndb;

-- 1. View first 5 rows of the data
select top 5 *
from customer_churn;


-- 2. Total number of customers
select count(*)
from customer_churn;

select distinct Churn
from customer_churn;

-- 3. Number of churned customers
select count(*)
from customer_churn
where churn='Yes';

-- 4. Number of customers who stayed (did not churn)
select count(*)
from customer_churn
where churn='No';

-- 5. Total vs churned customers
select 
count(*) as Total_customers,
sum(case when Churn = 'Yes' then 1 else 0 end) as churned_customers
from customer_churn;

-- 6. Churn percentage
select
count(*) as total_customers,
sum(case when churn = 'yes' then 1 else 0 end) as churned_customers,
round(100.0 * sum(case when churn = 'yes' then 1 else 0 end) / count(*),2) as churn_percentage
from customer_churn;

-- insight: around one-fourth of customers have churned, indicating a significant retention problem

-- 7. Churn by contract type
select contract,
count(*) as total_customers,
sum(case when churn = 'yes' then 1 else 0 end) as churned_customers,
round(100.0 * sum(case when churn = 'yes' then 1 else 0 end) / count(*),2) as churn_percentage
from customer_churn
group by contract
order by churn_percentage desc;

-- insight: month-to-month contracts show the highest churn, suggesting lack of long-term commitment

-- 8. Churn by payment method
select paymentmethod,
count(*) as total_customers,
sum(case when churn = 'yes' then 1 else 0 end) as churned_customers,
round(100.0 * sum(case when churn = 'yes' then 1 else 0 end) / count(*),2) as churn_percentage
from customer_churn
group by paymentmethod
order by churn_percentage desc;

-- insight: customers using electronic payment methods have higher churn compared to automatic payment options, 
-- suggesting trust or ease-of-use issues.

-- 9. Churn based on internet service type
select internetservice,
count(*) as total_customers,
sum(case when churn = 'yes' then 1 else 0 end) as churned_customers,
round(100.0 * sum(case when churn = 'yes' then 1 else 0 end) / count(*),2) as churn_percentage
from customer_churn
group by internetservice
order by churn_percentage desc;


-- 10. Compare average tenure of churned vs retained customers
select churn,
avg(cast(tenure as int)) as average_tenure
from customer_churn
group by churn;

-- insight: churned customers have much lower average tenure compared to retained customers

-- 11. calculate average monthly charges for churned vs retained customers
select churn,
avg(cast(MonthlyCharges as float)) as avg_monthly_charges
from customer_churn
group by churn;

-- 12. Show top 5 customers by monthly charges
select top 5
customerid,
monthlycharges
from customer_churn
order by monthlycharges desc;

-- 13. Identify high risk customers (short tenure and high monthly charges)
select customerid,
tenure,
monthlycharges,
churn
from customer_churn
where cast(tenure as int) < 12
and cast(monthlycharges as float) > 70
order by cast(monthlycharges as float) desc;

-- insight: customers with short tenure and high monthly charges
-- are more likely to churn and should be targeted early

-- 14. Estimate monthly revenue lost due to churn
select sum(cast(monthlycharges as float)) as monthly_revenue_lost
from customer_churn
where churn = 'yes';

-- insight: customer churn results in significant monthly revenue loss,
-- making retention financially critical

-- 15. Create a contract lookup table
create table contract_details (
contract varchar(50),
contract_type varchar(50));

insert into contract_details values
('month-to-month', 'short term'),
('one year', 'medium term'),
('two year', 'long term');


-- 16. Analyze churn by contract type using join
select cd.contract_type,
count(*) as total_customers,
sum(case when cc.churn = 'yes' then 1 else 0 end) as churned_customers
from customer_churn cc
join contract_details cd
on cc.contract = cd.contract
group by cd.contract_type;

-- insight: short-term contracts show higher churn compared to
-- medium and long-term contracts, highlighting the importance
-- of encouraging longer commitments
