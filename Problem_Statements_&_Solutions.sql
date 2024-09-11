#Digital_Analysis
/*Q1
Your task, as a Data Analyst at Clique Bait, is to determine the number of unique users who accessed the website.
This analysis will serve as a foundation for various other analyses that the Digital Analytics team 
aims to perform to understand the digital engagement on the platform better.
 */
 
select count(distinct user_id) from users;


/*Q2
Your task, as a Data Analyst at Clique Bait, is to calculate the average number of cookies all users have on the platform.
The result should be rounded to the nearest integer.
This analysis will provide insights into the data footprint per user and will be instrumental for the data management policies.
 */
 
 with cte as(
select user_id,count(cookie_id) as cc  from users
group by user_id
) 
select round(avg(cc)) average_cookies_per_user
from cte ;


/*Q3
Your role as a Data Analyst is to derive the unique number of visits by all users for each month. 
This data will be a cornerstone for the discussion in the upcoming meeting.
*/

select month(event_time) Month,
count(distinct visit_id) unique_visit_count
from events
where event_type=1
group by Month;


/*Q4
Your task, as a Data Analyst at Clique Bait, is to calculate the number of events for each event type. 
This analysis will provide a comprehensive view of the distribution of different types of interactions on 
the platform, aiding in various strategic decisions across departments.
*/

select ef.event_name,count(e.visit_id) event_count
from events e inner join event_identifier ef 
on e.event_type=ef.event_type
group by 1;


/*Q5
Your task, as a Data Analyst at Clique Bait, is to determine the percentage of visits
 that view the checkout page but do not have a purchase event. This analysis will help in understanding user behaviour 
 at a crucial stage in the purchase funnel and will be instrumental in devising strategies to improve the conversion rate.
*/
with cte as
(
select
sum(case when event_type= 1 and page_id=12 then 1 else 0 end) as checkout,
sum(case when event_type= 3 then 1 else 0 end) as purchase
from events
)
select 
(1-purchase/checkout)*100 as percentage_checkout_view_with_no_purchase
from cte;

/*Q6
You are a Data Analyst at Clique Bait and have been entrusted with the task of identifying the top 3 pages 
on the platform that have garnered the most views.This insight will serve as a compass guiding their redesign strategy.
*/

select ph.page_name,count(*)
from events e inner join page_hierarchy ph
on e.page_id=ph.page_id
where e.event_type=1
and ph.product_id is not null
group by ph.page_name 
order by count(*) desc limit 3;


/*Q7
Your task, as a Data Analyst at Clique Bait, is to analyze the number of views and cart adds for each product category. 
This analysis will aid the Inventory Manager in making informed decisions for managing the inventory 
and the Marketing team in strategizing the upcoming campaigns.
*/

select ph.product_category,
sum(case when e.event_type=1 then 1 else 0 end) page_views,
sum(case when e.event_type=2 then 1 else 0 end) cart_add
from events e inner join page_hierarchy ph
on e.page_id=ph.page_id
where ph.product_id is not null
group by 1 order by 1 desc;

/*Q8
What is the percentage of visits which have a purchase event?
*/

select round(sum(case when event_type="3" then
1 else 0 end)/count(distinct visit_id),3)*100 as purchase_percentage
from events;


##Product_Funnel_Analysis
/*Q1
You, being the adept Data Analyst at Clique Bait, have been assigned the task of identifying the product category that 
hosts  the maximum number of products. Your findings will serve as a precursor for the team's market analysis 
and strategy formulation.
*/
select product_category,count(distinct product_id)
from page_hierarchy
where product_category is not null
group by product_category
order by 2 desc limit 1;


/*Q2
As a Data Analyst at Clique Bait, you are entrusted with the task of analyzing user behavior concerning 
product views and purchases.
This analysis will serve as a cornerstone for the Product Recommendation Team to fine-tune the recommendation engine 
and for the Marketing Team to devise strategies to boost the visibility of lesser-viewed products.
*/

select u.user_id,
sum(case when e.event_type=1 then 1 else 0 end) product_views,
sum(case when e.event_type=3 then 1 else 0 end) purchase
from events e inner join users u
on e.cookie_id=u.cookie_id
group by 1;


/*Q3
Your task, as a Data Analyst at Clique Bait, is to identify the most viewed product and least viewed product on the website. 
This analysis will play a pivotal role in understanding user preferences and planning marketing strategies accordingly.
*/
select ph.page_name, ph.product_category,count(*) views
from events e inner join page_hierarchy ph
on e.page_id=ph.page_id
where e.event_type=1
and ph.product_id is not null
group by 1,2 
order by 3 desc limit 1;

select ph.page_name,ph.product_category,count(*) views
from events e inner join page_hierarchy ph
on e.page_id=ph.page_id
where e.event_type=1
and ph.product_id is not null
group by 1,2
order by 3 asc limit 1;


##Campaigns_performance_Analysis
/*Q1
As the entrusted Data Analyst of Clique Bait, your task is to identify the number of page views each campaign generated. 
This analysis will help the marketing team in understanding the outreach of their campaigns and in strategizing the 
future campaigns more effectively.
*/
select pci.campaign_name,count(e.visit_id) page_views
from events e inner join page_hierarchy ph
on e.page_id=ph.page_id
inner join campaign_identifier pci 
on pci.product_id=ph.product_id
where e.event_type=1
group by pci.campaign_name
order by 2 desc;


/*Q2
Your task, as a Data Analyst at Clique Bait, is to calculate the total number of unique visits for each campaign. 
This analysis will help the Campaign Management Team in understanding the reach and effectiveness of each campaign.
*/
select pci.campaign_name,
count(distinct e.cookie_id) unique_visitors
from events e inner join page_hierarchy ph
on e.page_id=ph.page_id
inner join campaign_identifier pci 
on pci.product_id=ph.product_id
group by pci.campaign_name;


##Temporal_Analysis
/*Q1
Your task, as a Data Analyst at Clique Bait, is to calculate the number of events recorded on each day in the "events" table. 
This initial analysis will help in understanding the distribution of user interactions over different days, 
paving the way for a deeper dive into temporal patterns of user behavior.
*/
select date(event_time) event_date,
count(visit_id) total_events
from events group by 1;


/*Q2
What is the total number of Ad Impression and Ad Click generated by all users per month?
This analysis will help The Marketing Team to strategically refine top-performing ads, CTR and 
identify user engagement patterns optimizing the impact of advertising campaigns.
*/
select month(event_time) as "Month" ,
sum(case when event_type=4 then 1 else 0 end) as Ad_Impression_Count,
sum(case when event_type=5 then 1 else 0 end) as Ad_Click_Count
from events
group by month(event_time) order by 1;



##User_behavior_Analysis
/*Q1
Your task, as a Data Analyst at Clique Bait, is to determine the number of sessions each user had on the website. 
This analysis will provide a lens into the user engagement on the platform and will be instrumental in strategizing 
user engagement initiatives.
*/
select user_id,
count(distinct visit_id) session_count
from users u inner join events e 
on u.cookie_id=e.cookie_id
group by 1 order by 2 desc;

/*Q2
Your mission, as a Data Analyst at Clique Bait, is to identify the number of users who have made a purchase and 
order them in descending order based on their order counts. 
This analysis will be pivotal in designing the loyalty rewards program.
*/
select user_id,count(visit_id) no_of_time_purchase
from users u inner join events e 
on u.cookie_id=e.cookie_id
where event_type=3
group by 1 order by 2 desc;

/*Q3
As a Data Analyst at Clique Bait, you are tasked with analyzing the user behavior in terms of visiting the pages 
and identifying the page that each user visits the most. This analysis will serve as a foundation for the UX team 
to devise strategies for enhancing user engagement on the platform. Add an additional column as well for the window 
function used showcasing that the page mentioned for the user is the first one from the top, ie, the most viewed page.
*/
with cte as(
select u.user_id,ph.page_name,count(*),
dense_rank() over(partition by u.user_id order by count(*) desc) as k
from users u inner join events e on u.cookie_id=e.cookie_id 
inner join page_hierarchy ph on e.page_id=ph.page_id
where ph.product_id is not null
group by 1,2
)
select * from cte where k=1;