--MORE SESSION CALCULATIONS

--average number of event types per each session type 
/*
SELECT 
  f.session_type,
  ROUND(AVG(s.event_count),0) AS average_events_per_session
FROM `funnel-analysis-498323.eCommerce_data.session_funnel_table` f
JOIN `funnel-analysis-498323.eCommerce_data.session_summary_table` s
  ON f.user_session = s.user_session
GROUP BY session_type

UNION ALL

SELECT 
  'TOTAL' AS session_type,
  ROUND(AVG(event_count),0) AS average_total
FROM `funnel-analysis-498323.eCommerce_data.session_summary_table`

ORDER BY 
  CASE
    WHEN session_type = 'TOTAL' THEN 1 
    ELSE 0 
  END,
  session_type;
*/

--average events per any session is 5 
--full funnel sessions have higher number of events (9)

--do the exact same thing but with duration of sessions 
/*
SELECT 
  f.session_type,
  ROUND(AVG(s.session_duration_minutes),2) AS average_session_duration
FROM `funnel-analysis-498323.eCommerce_data.session_funnel_table` f
JOIN `funnel-analysis-498323.eCommerce_data.session_summary_table` s
  ON f.user_session = s.user_session
GROUP BY session_type

UNION ALL

SELECT 
  'TOTAL' AS session_type,
  ROUND(AVG(session_duration_minutes),2) AS average_total
FROM `funnel-analysis-498323.eCommerce_data.session_summary_table`

ORDER BY 
  CASE
    WHEN session_type = 'TOTAL' THEN 1 
    ELSE 0 
  END,
  session_type;
*/

--most popular product information  
SELECT 
  product_id,
  ANY_VALUE(category_code) AS category_code,
  ANY_VALUE(brand) AS brand,
  COUNTIF(event_type = 'view') AS views,
  COUNTIF(event_type = 'cart') AS carts,
  COUNTIF(event_type = 'purchase') AS purchases,
  ROUND(SAFE_DIVIDE(
    COUNTIF(event_type = 'purchase'),
    COUNTIF(event_type = 'view')
  )*100, 2) AS view_to_purchase_rate
FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data_cleaned`
GROUP BY product_id
ORDER BY views DESC;