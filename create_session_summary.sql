--SESSION SUMMARY TABLE 

CREATE TABLE `funnel-analysis-498323.eCommerce_data.session_summary_table` AS (
SELECT 
  user_session,
  ANY_VALUE(user_id) AS user_id,
  MIN(event_time) AS session_start_time,
  MAX(event_time) AS session_end_time,
  TIMESTAMP_DIFF(MAX(event_time), MIN(event_time), MINUTE) AS session_duration_minutes,
  COUNT(*) AS event_count,
  COUNTIF(event_type = 'view') AS view_count,
  COUNTIF(event_type = 'cart') AS cart_count,
  COUNTIF(event_type = 'purchase') AS purchase_count,


  COUNT(DISTINCT IF(event_type = 'view', product_id, NULL)) AS products_viewed,
  COUNT(DISTINCT IF(event_type = 'cart', product_id, NULL)) AS products_carted,
  COUNT(DISTINCT IF(event_type = 'purchase', product_id, NULL)) AS products_purchased,
  SUM(IF(event_type = 'purchase', price, 0)) AS total_purchase_value

FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data_cleaned`
GROUP BY user_session

);