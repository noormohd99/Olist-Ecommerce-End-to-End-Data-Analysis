--create the Database
CREATE DATABASE OlistEcommerce;

-- create tables 

-- table 1: orders
create table Orders (
    order_id varchar(50) primary key,
    customer_id varchar(50) not null,
    order_status varchar(20) not null,
    order_purchase_timestamp datetime not null,
    order_approved_at datetime,
    order_delivered_carrier_date datetime,
    order_delivered_customer_date datetime,
    order_estimated_delivery_date datetime,
    actual_delivery_days int,
    is_delayed varchar(10)
);


-- table 2: order items
create table OrderItems (
    order_id varchar(50) not null,
    order_item_id int not null,
    product_id varchar(50) not null,
    seller_id varchar(50) not null,
    shipping_limit_date datetime not null,
    price decimal(10, 2) not null,
    freight_value decimal(10, 2) not null,
    item_total decimal(10, 2) not null,
    primary key (order_id, order_item_id)
);

-- table 3: customers
create table Customers (
    customer_id varchar(50) primary key,
    customer_unique_id varchar(50) not null,
    customer_zip_code_prefix varchar(10) not null,
    customer_city varchar(100) not null,
    customer_state varchar(5) not null,
    zip_length int
);

-- table 4: products
create table Products (
    product_id varchar(50) primary key,
    product_category_name varchar(100),
    product_name_lenght float,
    product_description_lenght float,
    product_photos_qty float,
    product_weight_g decimal(10, 2),
    product_length_cm float,
    product_height_cm float,
    product_width_cm float,
    product_category_name_english varchar(100)
);



-- table 5: sellers
create table Sellers (
    seller_id varchar(50) primary key,
    seller_zip_code_prefix varchar(10) not null,
    seller_city varchar(100) not null,
    seller_state varchar(30) not null
);



-- table 6: reviews
create table Reviews (
    review_id varchar(50),
    order_id varchar(50) not null,
    review_score int not null,
    review_comment_title varchar(50),
    review_comment_message varchar(50),
    review_creation_date datetime not null,
    review_answer_timestamp datetime not null
);


-- table 7: payments
create table Payments (
    order_id varchar(50) not null,
    payment_sequential int not null,
    payment_type varchar(50) not null,
    payment_installments int not null,
    payment_value decimal(10, 2) not null,
    primary key (order_id, payment_sequential)
);

-----------------------

-- Staging table for Products (accepts any data format)
CREATE TABLE Products_Staging (
    product_id VARCHAR(MAX),
    product_category_name VARCHAR(MAX),
    product_name_lenght VARCHAR(MAX),
    product_description_lenght VARCHAR(MAX),
    product_photos_qty VARCHAR(MAX),
    product_weight_g VARCHAR(MAX),
    product_length_cm VARCHAR(MAX),
    product_height_cm VARCHAR(MAX),
    product_width_cm VARCHAR(MAX),
    product_category_name_english VARCHAR(MAX)
);

-- Load Products into staging
BULK INSERT Products_Staging
FROM 'G:\.shortcut-targets-by-id\1Nw-pjDV4GyQtOiPmrhkXftNS9eD5F7Th\End to End Data Analysis Project\data_clean\Products_categories_clean .csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);


-- Transfer Products
INSERT INTO Products (
    product_id, product_category_name, product_name_lenght,
    product_description_lenght, product_photos_qty, product_weight_g,
    product_length_cm, product_height_cm, product_width_cm,
    product_category_name_english
)
SELECT 
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    TRY_CONVERT(FLOAT, product_weight_g),
    product_length_cm,
    product_height_cm,
    product_width_cm,
    product_category_name_english
FROM Products_Staging;


-------------------------------------
-------------------------------------


-- Staging table for Payments
CREATE TABLE Payments_Staging (
    order_id VARCHAR(MAX),
    payment_sequential VARCHAR(MAX),
    payment_type VARCHAR(MAX),
    payment_installments VARCHAR(MAX),
    payment_value VARCHAR(MAX)
);

-- Load Payments into staging
BULK INSERT Payments_Staging
FROM 'G:\.shortcut-targets-by-id\1Nw-pjDV4GyQtOiPmrhkXftNS9eD5F7Th\End to End Data Analysis Project\data_clean\olist_order_payments_dataset.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);


-- Transfer Payments
INSERT INTO Payments (
    order_id, payment_sequential, payment_type,
    payment_installments, payment_value
)
SELECT 
    order_id,
    TRY_CONVERT(INT, payment_sequential),
    payment_type,
    TRY_CONVERT(INT, payment_installments),
    TRY_CONVERT(FLOAT, payment_value)
FROM Payments_Staging;



------------------------------------
------------------------------------

-- Staging table for Reviews
CREATE TABLE Reviews_Staging_Fixed (
    review_id VARCHAR(MAX),
    order_id VARCHAR(MAX),
    review_score VARCHAR(MAX),
    review_comment_title VARCHAR(MAX), -- Set appropriate limits
    review_comment_message VARCHAR(MAX), -- Use MAX to avoid truncation
    review_creation_date VARCHAR(MAX),
    review_answer_timestamp VARCHAR(MAX)
);

truncate table Reviews_Staging_Fixed;

-- Load Reviews into staging
BULK INSERT Reviews_Staging_Fixed
FROM 'C:\Users\DELL\OneDrive\Desktop\End to End Data Analysis Project\data_clean\reviews_clean.csv'
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    ROWTERMINATOR = '0x0a',
    TABLOCK,
    CODEPAGE = '65001'  -- UTF-8
);



ALTER TABLE Reviews
ALTER COLUMN review_comment_title VARCHAR(100);
ALTER TABLE Reviews
ALTER COLUMN review_comment_message VARCHAR(2000);

-- Transfer Reviews
INSERT INTO Reviews (
    review_id, order_id, review_score, review_comment_title,
    review_comment_message, review_creation_date, review_answer_timestamp
)
SELECT 
    review_id,
    order_id,
    TRY_CONVERT(INT, review_score),
    review_comment_title,
    review_comment_message,
    TRY_CONVERT(DATETIME, review_creation_date),
    TRY_CONVERT(DATETIME, review_answer_timestamp)
FROM Reviews_Staging_Fixed;



---------------------------------
----------------------------------


-- Staging table for Orders
CREATE TABLE Orders_Staging (
    order_id VARCHAR(MAX),
    customer_id VARCHAR(MAX),
    order_status VARCHAR(MAX),
    order_purchase_timestamp VARCHAR(MAX),
    order_approved_at VARCHAR(MAX),
    order_delivered_carrier_date VARCHAR(MAX),
    order_delivered_customer_date VARCHAR(MAX),
    order_estimated_delivery_date VARCHAR(MAX),
    actual_delivery_days VARCHAR(MAX),
    is_delayed VARCHAR(MAX)
);



-- Load Orders into staging
BULK INSERT Orders_Staging
FROM 'C:\Users\DELL\OneDrive\Desktop\End to End Data Analysis Project\data_clean\orders_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);


-- Transfer Orders
INSERT INTO Orders (
    order_id, customer_id, order_status, order_purchase_timestamp,
    order_approved_at, order_delivered_carrier_date, order_delivered_customer_date,
    order_estimated_delivery_date, actual_delivery_days, is_delayed
)
SELECT 
    order_id,
    customer_id,
    order_status,
    TRY_CONVERT(DATETIME, order_purchase_timestamp),
    TRY_CONVERT(DATETIME, order_approved_at),
    TRY_CONVERT(DATETIME, order_delivered_carrier_date),
    TRY_CONVERT(DATETIME, order_delivered_customer_date),
    TRY_CONVERT(DATETIME, order_estimated_delivery_date),
    TRY_CONVERT(INT, actual_delivery_days),
    is_delayed
FROM Orders_Staging;



------------------------------
------------------------------

-- Staging table for OrderItems
CREATE TABLE OrderItems_Staging (
    order_id VARCHAR(MAX),
    order_item_id VARCHAR(MAX),
    product_id VARCHAR(MAX),
    seller_id VARCHAR(MAX),
    shipping_limit_date VARCHAR(MAX),
    price VARCHAR(MAX),
    freight_value VARCHAR(MAX),
    item_total VARCHAR(MAX)
);


-- Load OrderItems into staging
BULK INSERT OrderItems_Staging
FROM 'C:\Users\DELL\OneDrive\Desktop\End to End Data Analysis Project\data_clean\order_items_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK,
    CODEPAGE = '65001'  -- UTF-8
);


-- Transfer OrderItems
INSERT INTO OrderItems (
    order_id, order_item_id, product_id, seller_id,
    shipping_limit_date, price, freight_value, item_total
)
SELECT 
    order_id,
    TRY_CONVERT(INT, order_item_id),
    product_id,
    seller_id,
    TRY_CONVERT(DATETIME, shipping_limit_date),
    TRY_CONVERT(FLOAT, price),
    TRY_CONVERT(FLOAT, freight_value),
    TRY_CONVERT(FLOAT, item_total)
FROM OrderItems_Staging;


------------------------------
------------------------------

-- Staging table for Customers
CREATE TABLE Customers_Staging (
    customer_id VARCHAR(MAX),
    customer_unique_id VARCHAR(MAX),
    customer_zip_code_prefix VARCHAR(MAX),
    customer_city VARCHAR(MAX),
    customer_state VARCHAR(MAX),
    zip_length VARCHAR(MAX)
);


-- Load Customers into staging
BULK INSERT Customers_Staging
FROM 'C:\Users\DELL\OneDrive\Desktop\End to End Data Analysis Project\data_clean\customers_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK,
    CODEPAGE = '65001'  -- UTF-8
);


-- Transfer Customers
INSERT INTO Customers (
    customer_id, customer_unique_id, customer_zip_code_prefix,
    customer_city, customer_state, zip_length
)
SELECT 
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    TRY_CONVERT(INT, zip_length)
FROM Customers_Staging;



------------------------------
------------------------------

-- Staging table for Sellers
CREATE TABLE Sellers_Staging (
    seller_id VARCHAR(MAX),
    seller_zip_code_prefix VARCHAR(MAX),
    seller_city VARCHAR(MAX),
    seller_state VARCHAR(MAX)
);


-- Load Sellers into staging
BULK INSERT Sellers_Staging
FROM 'C:\Users\DELL\OneDrive\Desktop\End to End Data Analysis Project\data_clean\sellers_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);


-- Transfer Sellers
INSERT INTO Sellers (
    seller_id, seller_zip_code_prefix, seller_city, seller_state
)
SELECT 
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM Sellers_Staging;



-----------------------
--Drop Staging Tables
-----------------------

DROP TABLE  Orders_Staging;
DROP TABLE  OrderItems_Staging;
DROP TABLE  Customers_Staging;
DROP TABLE  Products_Staging;
DROP TABLE  Sellers_Staging;
DROP TABLE  Reviews_Staging_Fixed;
DROP TABLE  Payments_Staging;