--This is running some quick checks when the cleaned chart is first made 


--count the nulls in each column, there are no nulls 
/*
SELECT 
  COUNTIF(event_time IS NULL) AS null_event_time_count,
  COUNTIF(event_hour IS NULL) AS null_event_hour_count,
  COUNTIF(day_of_week IS NULL) AS null_day_of_week_count,
  COUNTIF(day_name IS NULL) AS null_day_name_count,
  COUNTIF(event_date IS NULL) AS null_event_date_count,
  COUNTIF(event_type IS NULL) AS null_event_type_count,
  COUNTIF(product_id IS NULL) AS null_product_id_count,
  COUNTIF(category_id IS NULL) AS null_category_id_count,
  COUNTIF(category_code IS NULL) AS null_category_code_count,
  COUNTIF(brand IS NULL) AS null_brand_count,
  COUNTIF(price IS NULL) AS null_price_count,
  COUNTIF(price_zero_flag IS NULL) AS null_price_flag_count,
  COUNTIF(user_id IS NULL) AS null_user_id_count,
  COUNTIF(user_session IS NULL) AS null_user_session_count
FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data_cleaned` 
LIMIT 1000
*/

--there are no duplicate rows 
/*
SELECT 
  *,
 COUNT(*) AS row_count
FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data_cleaned`
GROUP BY 
  event_time,
  event_hour,
  day_of_week,
  day_name, 
  event_date,
  event_type,
  product_id,
  category_id,
  category_code,
  brand,
  price,
  price_zero_flag,
  user_id,
  user_session
HAVING COUNT(*) > 1
ORDER BY row_count DESC;
*/
/*
SELECT 
  COUNT(*)
FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data_cleaned`;
*/
/*
67,501,979 67,401,450, lost 100,529 rows 
- duplicates 100519, plus 10 rows with no session id, so that math makes sense 
*/

--count event types 
SELECT 
  event_type, 
  COUNT(*)
FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data_cleaned`
GROUP BY event_type;

/*
view: 63554512
cart: 2930008
purcahse: 916930
*/