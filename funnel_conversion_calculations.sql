-- FUNNEL CONVERSION RATES 


SELECT 
  'View' AS stage, 
  COUNTIF(viewed = 1) AS sessions,
  NULL AS rate_from_previous_stage
FROM `funnel-analysis-498323.eCommerce_data.session_funnel_table`

UNION ALL

SELECT 
  'Cart' AS stage, 
  COUNTIF(carted = 1) AS sessions,
  ROUND(
    SAFE_DIVIDE(
      COUNTIF(carted = 1),
      COUNTIF(viewed = 1)
    ) * 100 , 2
  ) AS rate_from_previous_stage
FROM `funnel-analysis-498323.eCommerce_data.session_funnel_table`

UNION ALL

SELECT 
  'Purchase' AS stage, 
  COUNTIF(purchased = 1) AS sessions,
  ROUND(SAFE_DIVIDE(
    COUNTIF(purchased = 1),
    COUNTIF(carted = 1)
    ) * 100 , 2
  ) AS rate_from_previous_stage
FROM `funnel-analysis-498323.eCommerce_data.session_funnel_table`


ORDER BY 
  CASE 
    WHEN stage = 'View' THEN 1 
    WHEN stage = 'Cart' THEN 2 
    WHEN stage = 'Purchase' THEN 3 
  END,
  stage;

/*
RESULTS:
View:   13766768
Cart:    1743342
Purchase: 773214
*/


--Funnel Conversion Rates
/*
SELECT 
  ROUND(
  SAFE_DIVIDE(
    COUNTIF(carted = 1),
    COUNTIF(viewed = 1)
  ) * 100 , 2
  ) AS view_to_cart_rate,

  ROUND(
  SAFE_DIVIDE(
    COUNTIF(purchased = 1),
    COUNTIF(carted = 1)
  ) * 100 , 2
  ) AS cart_to_purchase_rate,

  ROUND(
  SAFE_DIVIDE(
    COUNTIF(purchased = 1),
    COUNTIF(viewed = 1)
  ) * 100 , 2
  ) AS overall_funnel_conversion_rate,
FROM `funnel-analysis-498323.eCommerce_data.session_funnel_table`; 

/*
view to cart: 12.66%
cart to purchase: 44.35%
overall funnel: 5.62%
*/

--Session TYPES 
/*
SELECT 
  session_type,
  COUNT(*) AS sessions,
  
FROM `funnel-analysis-498323.eCommerce_data.session_funnel_table`
GROUP BY session_type
ORDER BY sessions DESC;


--entry type conversion

SELECT 
  entry_type, 
  COUNT(*) AS sessions,
  SUM(valid_full_funnel) AS conversions,

  ROUND(
  SAFE_DIVIDE(
    SUM(valid_full_funnel),
    COUNT(*)
  ) * 100 , 2
  ) AS conversion_rate,
FROM `funnel-analysis-498323.eCommerce_data.session_funnel_table`
GROUP BY entry_type;
*/


--exit drop-offs
/* 
SELECT 
  exit_type,
  COUNT(*) AS sessions
FROM `funnel-analysis-498323.eCommerce_data.session_funnel_table`
GROUP BY exit_type
ORDER BY sessions DESC;
*/
/*
view_exit: 12905861
cart_exit: 471818
purchase_exit: 398371
*/

--TIME DATA 

--sessions per hour 
/*
SELECT 
  
  EXTRACT(HOUR FROM session_start_time) AS event_hour,
  COUNT(DISTINCT user_session) AS sessions_count

FROM `funnel-analysis-498323.eCommerce_data.session_summary_table`

GROUP BY event_hour
ORDER BY event_hour;
*/
--largest number of sessions is between 1-4pm

--create full table from sessions break down by hour 
/*
SELECT 
  EXTRACT(HOUR FROM s.session_start_time) AS start_hour,
  COUNT(*) AS sessions, 
  SUM(f.valid_full_funnel) AS valid_full_funnels,
  ROUND(SAFE_DIVIDE(SUM(f.valid_full_funnel), COUNT(*))*100, 2) AS conversion_rate,
  SUM(f.viewed) AS browsing_sessions
FROM `funnel-analysis-498323.eCommerce_data.session_funnel_table` f
JOIN `funnel-analysis-498323.eCommerce_data.session_summary_table` s
  ON f.user_session = s.user_session
GROUP BY start_hour
ORDER BY start_hour;
*/

--exact same thing but broken down by day
/* 
SELECT 
  EXTRACT(DAYOFWEEK FROM s.session_start_time) AS day_of_week,
  COUNT(*) AS sessions, 
  SUM(f.valid_full_funnel) AS valid_full_funnels,
  ROUND(SAFE_DIVIDE(SUM(f.valid_full_funnel), COUNT(*))*100, 2) AS conversion_rate,
  SUM(f.viewed) AS browsing_sessions
FROM `funnel-analysis-498323.eCommerce_data.session_funnel_table` f
JOIN `funnel-analysis-498323.eCommerce_data.session_summary_table` s
  ON f.user_session = s.user_session
GROUP BY day_of_week
ORDER BY day_of_week;
*/
--1 is sunday, has almost double all the conversion rates of all other days of week 