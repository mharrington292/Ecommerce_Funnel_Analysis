-- DATA EXPLORATION (before cleaning)


--count the nulls in each column 
SELECT 
  COUNTIF(event_time IS NULL) AS null_event_time_count,
  COUNTIF(event_type IS NULL) AS null_event_type_count,
  COUNTIF(product_id IS NULL) AS null_product_id_count,
  COUNTIF(category_id IS NULL) AS null_category_id_count,
  COUNTIF(category_code IS NULL) AS null_category_code_count,
  COUNTIF(brand IS NULL) AS null_brand_count,
  COUNTIF(price IS NULL) AS null_price_count,
  COUNTIF(user_id IS NULL) AS null_user_id_count,
  COUNTIF(user_session IS NULL) AS null_user_session_count
FROM 
  `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`;


/*
NULLS:
category_code: 21,898,171 (about 32% of data)
brand: 9218235 
user_session: 10 (can probably delete these 10 rows because without they are useless data)
Rest of the columns say 0 
*/


-- count the number of entries in each category 
SELECT 
  COUNT(*)
FROM 
  `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`;

-- the number of total rows is 67,501,979


--count the number of event types: only view, cart, purchase 

SELECT 
  event_type,
  COUNT(event_type) AS count_event_type
FROM 
  `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`
GROUP BY event_type
ORDER BY count_event_type DESC;

/*
Results:
  view: 63,556,110
  cart: 3,028,930
  purchase: 916,939
*/

--number of unique users and sessions 

SELECT 
  COUNT(DISTINCT user_id) AS count_user_id,
  COUNT(DISTINCT user_session) AS count_user_session, 
  COUNT(DISTINCT product_id) AS count_product_id,
  COUNT(DISTINCT category_id) AS count_category_id,
  COUNT(DISTINCT category_code) AS count_category_code,
  COUNT(DISTINCT brand) AS count_brand
FROM 
  `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`;

/*
Results:
user_is: 3,696,117
sessions: 13,776,050 (average 5 events a session then?)
products: 190,662
category_id: 684
category_code: 129
brands: 4201
*/

--examining price column

SELECT 
  MAX(price) AS max_price,
  MIN(price) AS min_price,
  ROUND(AVG(price),2) AS average_price
FROM 
  `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`;

/*
Results:
Max: $2574.07
Min: $0
Average: $292.46
*/

--how many entries have $0 price?

SELECT 
  COUNT(*) AS count_no_price
FROM 
  `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`
WHERE price = 0.0;

-- there are 188,088 entries with no price, are these then useless rows to use?

--then examine the rows with $0 and see if they are just missing the entry and their item code comes up somewhere else 
SELECT 
  *
FROM 
  `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`
WHERE price = 0.0
LIMIT 100;

--check an example of a product
SELECT 
  *
FROM 
  `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`
WHERE product_id = 1001618;
*/

--check what event types the 0's are for to determine how it effects the data 

SELECT event_type,
       COUNT(*)
FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`
WHERE price = 0
GROUP BY event_type;

--cart: 4408, view: 183680

--check how many non-zero prices an object has 

SELECT
    product_id,
    COUNT(DISTINCT price) AS distinct_prices
FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`
WHERE price > 0
GROUP BY product_id
ORDER BY distinct_prices DESC;


--check if there are duplicate rows in the dataset 

SELECT 
  *,
 COUNT(*) AS row_count
FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`
GROUP BY 
  event_time,
  event_type,
  product_id,
  category_id,
  category_code,
  brand,
  price,
  user_id,
  user_session
HAVING COUNT(*) > 1
ORDER BY row_count DESC;

/*
Results:
- there are 57553 duplicate row entries, the maximum count of duplicate rows is 78
Would there be a logical explanation for this? 
Is it possible the same person could do multiple of the same action in the exact same second?, seems like there are duplicate rows for cart, purchase and view (not remove from cart)
*/

--get the total amount of duplicate rows 
SELECT
    SUM(cnt - 1) AS total_duplicate_rows
FROM (
    SELECT
        *,
        COUNT(*) AS cnt
    FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`
    GROUP BY
      event_time,
      event_type,
      product_id,
      category_id,
      category_code,
      brand,
      price,
      user_id,
      user_session
    HAVING COUNT(*) > 1
) total_count;

-- total amount of duplicates is 100519


--check the length of columns are consistent 
SELECT
  LENGTH(user_session) AS session_length,
  COUNT(*) AS count_rows
FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`
GROUP BY session_length
ORDER BY session_length;
--reveals all lengths are 36 or 10 null values 


--checking brands 
SELECT
  brand,
  COUNT(brand) AS count_brand
FROM 
  `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`
GROUP BY brand
ORDER BY count_brand DESC;

/*
Have 4202 brands for events in general (viewing also), 
Top Brands: 
Samsung: 7889245
Apple: 6259379
Xiaomi: 4638062
There are several brands with just a 1 count, what does this mean 
*/

--checking types of category codes 

SELECT
  category_code,
  COUNT(category_code) AS count_category_code
FROM 
  `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`
GROUP BY category_code
ORDER BY count_category_code DESC;

/*
130 categories:
Highest event categories:
electronics.smartphone: 16375000
electronics.video.tv: 2208046
computers.notebook: 2180554
*/


-- check if the timestamps are all actually in november and that they are all in the same format
--all timestamps are in november 

SELECT
  DATE(event_time) AS day,
  COUNT(event_time) AS events_per_day
FROM 
  `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`
GROUP BY DATE(event_time)
ORDER BY day DESC;



--check all timestamps are in consistent format 
SELECT
  MIN(event_time) AS earliest,
  MAX(event_time) AS latest
FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`;

--checking for timezone inconsistencies 
SELECT
  EXTRACT(HOUR FROM event_time) AS hour,
  COUNT(*) AS count
FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`
GROUP BY hour
ORDER BY hour;
