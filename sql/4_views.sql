-- view 1: monthly sales summary
create view vw_monthly_sales as
select 
    year(o.order_purchase_timestamp) as order_year,
    month(o.order_purchase_timestamp) as order_month,
    datename(month, o.order_purchase_timestamp) as month_name,
    count(distinct o.order_id) as total_orders,
    count(distinct o.customer_id) as unique_customers,
    sum(oi.item_total) as total_revenue,
    avg(oi.item_total) as avg_order_value
from orders o
join orderitems oi on o.order_id = oi.order_id
where o.order_status = 'delivered'
group by year(o.order_purchase_timestamp), month(o.order_purchase_timestamp), 
         datename(month, o.order_purchase_timestamp);




-- view 2: category performance
create view vw_category_performance as
select 
    p.product_category_name_english as category,
    count(distinct oi.order_id) as total_orders,
    count(distinct oi.product_id) as unique_products,
    sum(oi.item_total) as total_revenue,
    avg(oi.price) as avg_product_price,
    avg(r.review_score) as avg_review_score
from products p
join orderitems oi on p.product_id = oi.product_id
join orders o on oi.order_id = o.order_id
left join reviews r on o.order_id = r.order_id
where o.order_status = 'delivered'
group by p.product_category_name_english;



-- view 3: delivery performance by state
create view vw_delivery_performance as
select 
    c.customer_state,
    count(distinct o.order_id) as total_orders,
    avg(o.actual_delivery_days) as avg_delivery_days,
    sum(case when o.order_delivered_customer_date <= o.order_estimated_delivery_date 
             then 1 else 0 end) as on_time_orders,
    sum(case when o.order_delivered_customer_date > o.order_estimated_delivery_date 
             then 1 else 0 end) as delayed_orders,
    cast(sum(case when o.order_delivered_customer_date <= o.order_estimated_delivery_date 
                  then 1 else 0 end) * 100.0 / count(*) as decimal(5,2)) as on_time_percentage
from orders o
join customers c on o.customer_id = c.customer_id
where o.order_status = 'delivered'
    and o.actual_delivery_days is not null
group by c.customer_state;


-- view 4: seller performance metrics
create view vw_seller_performance as
select 
    s.seller_id,
    s.seller_state,
    s.seller_city,
    count(distinct oi.order_id) as total_orders,
    sum(oi.item_total) as total_revenue,
    avg(oi.item_total) as avg_order_value,
    avg(r.review_score) as avg_review_score,
    count(distinct p.product_category_name_english) as categories_sold
from sellers s
join orderitems oi on s.seller_id = oi.seller_id
join orders o on oi.order_id = o.order_id
join products p on oi.product_id = p.product_id
left join reviews r on o.order_id = r.order_id
where o.order_status = 'delivered'
group by s.seller_id, s.seller_state, s.seller_city;



---*******************************************

-- cte 1: customer lifetime value
with customer_ltv as (
    select 
        c.customer_unique_id,
        count(distinct o.order_id) as total_orders,
        sum(oi.item_total) as lifetime_value,
        avg(r.review_score) as avg_review_score,
        min(o.order_purchase_timestamp) as first_order_date,
        max(o.order_purchase_timestamp) as last_order_date
    from customers c
    join orders o on c.customer_id = o.customer_id
    join orderitems oi on o.order_id = oi.order_id
    left join reviews r on o.order_id = r.order_id
    where o.order_status = 'delivered'
    group by c.customer_unique_id
)
select 
    case 
        when total_orders = 1 then 'one-time buyer'
        when total_orders between 2 and 3 then 'repeat buyer'
        else 'loyal customer'
    end as customer_segment,
    count(*) as customer_count,
    avg(lifetime_value) as avg_lifetime_value,
    avg(avg_review_score) as avg_satisfaction
from customer_ltv
group by 
    case 
        when total_orders = 1 then 'one-time buyer'
        when total_orders between 2 and 3 then 'repeat buyer'
        else 'loyal customer'
    end
order by avg_lifetime_value desc;



-- cte 2: review impact analysis
with review_impact as (
    select 
        r.review_score,
        count(distinct o.order_id) as order_count,
        avg(o.actual_delivery_days) as avg_delivery_days,
        avg(oi.item_total) as avg_order_value
    from reviews r
    join orders o on r.order_id = o.order_id
    join orderitems oi on o.order_id = oi.order_id
    where o.order_status = 'delivered'
        and o.actual_delivery_days is not null
    group by r.review_score
)
select 
    review_score,
    order_count,
    cast(avg_delivery_days as decimal(5,2)) as avg_delivery_days,
    cast(avg_order_value as decimal(10,2)) as avg_order_value
from review_impact
order by review_score desc;



-- cte 3: regional sales ranking
with regional_sales as (
    select 
        c.customer_state,
        sum(oi.item_total) as total_revenue,
        count(distinct o.order_id) as total_orders,
        avg(o.actual_delivery_days) as avg_delivery_days
    from orders o
    join customers c on o.customer_id = c.customer_id
    join orderitems oi on o.order_id = oi.order_id
    where o.order_status = 'delivered'
    group by c.customer_state
)
select 
    customer_state,
    total_revenue,
    total_orders,
    cast(avg_delivery_days as decimal(5,2)) as avg_delivery_days,
    rank() over (order by total_revenue desc) as revenue_rank,
    rank() over (order by avg_delivery_days asc) as delivery_rank
from regional_sales
order by revenue_rank;