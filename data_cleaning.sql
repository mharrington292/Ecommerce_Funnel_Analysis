/*
DATA CLEANING:
*/

CREATE TABLE `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data_cleaned` AS (
  SELECT DISTINCT 
    event_time,
    EXTRACT(HOUR FROM event_time) AS event_hour,
    EXTRACT(DAYOFWEEK FROM event_time) AS day_of_week,
    FORMAT_DATE('%A', DATE(event_time)) AS day_name, 
    DATE(event_time) AS event_date,
    event_type,
    product_id,
    category_id,
    COALESCE(category_code, 'unknown') AS category_code,
    COALESCE(brand, 'unknown') AS brand,
    price,
    CASE WHEN price = 0 THEN 1 ELSE 0 END AS price_zero_flag,
    user_id,
    user_session
  FROM 
  `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data`

  WHERE user_session IS NOT NULL
);
