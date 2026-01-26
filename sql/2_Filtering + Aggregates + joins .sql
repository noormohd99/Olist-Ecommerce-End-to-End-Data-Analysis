-- 3.1 Filter orders that were delivered late
select 
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_estimated_delivery_date,
    order_delivered_customer_date,
    actual_delivery_days,
    is_delayed
from Orders
where is_delayed = 'True'
    and order_status = 'delivered'
order by actual_delivery_days desc;

-- 3.1 Filter products by category
select 
    product_id,
    product_category_name_english,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
from Products
where product_category_name_english in ('electronics', 'computers_accessories', 'telephony')
    and product_weight_g > 1000
order by product_weight_g desc;




--**************************************************


-- 3.2 Aggregate sales metrics by product category
select 
    p.product_category_name_english,
    count(distinct oi.order_id) as total_orders,
    count(oi.order_item_id) as total_items_sold,
    sum(oi.price) as total_revenue,
    avg(oi.price) as average_price,
    sum(oi.freight_value) as total_freight_cost
from OrderItems oi
join Products p on oi.product_id = p.product_id
group by  p.product_category_name_english
having count(distinct oi.order_id) > 50
order by total_revenue desc;

-- 3.2 Aggregate customer metrics by state
select 
    top 10 (c.customer_state),
    count(distinct o.order_id) as total_orders,
    count(distinct c.customer_unique_id) as unique_customers,
    sum(oi.price) as total_spent,
    avg(p.review_score) as avg_review_score
from Customers c
join Orders o on c.customer_id = o.customer_id
join OrderItems oi on o.order_id = oi.order_id
left join Reviews p on o.order_id = p.order_id
group by c.customer_state
order by total_spent desc;


--**************************************************

-- 3.3 Join multiple tables for complete order analysis
select 
    o.order_id,
    o.order_purchase_timestamp,
    o.order_status,
    c.customer_city,
    c.customer_state,
    s.seller_city,
    s.seller_state,
    p.product_category_name_english,
    oi.price,
    oi.freight_value,
    r.review_score
from Orders o
join Customers c on o.customer_id = c.customer_id
join OrderItems oi on o.order_id = oi.order_id
join Products p on oi.product_id = p.product_id
join Sellers s on oi.seller_id = s.seller_id
left join Reviews r on o.order_id = r.order_id
left join Payments py on o.order_id = py.order_id
where o.order_status = 'delivered'
    and o.order_purchase_timestamp >= '2018-01-01'
order by o.order_purchase_timestamp desc;



-- 3.3 Join for customer lifetime value analysis
select 
    c.customer_unique_id,
    c.customer_state,
    count(distinct o.order_id) as total_orders,
    sum(oi.price + oi.freight_value) as total_spent,
    avg(r.review_score) as avg_satisfaction,
    min(o.order_purchase_timestamp) as first_order_date,
    max(o.order_purchase_timestamp) as last_order_date
from Customers c
join Orders o on c.customer_id = o.customer_id
join OrderItems oi on o.order_id = oi.order_id
left join Reviews r on o.order_id = r.order_id
group by c.customer_unique_id, c.customer_state
having count(distinct o.order_id) > 1
order by total_spent desc;