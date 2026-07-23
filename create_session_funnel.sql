--create session level funnel 

CREATE TABLE `funnel-analysis-498323.eCommerce_data.session_funnel_table` AS

WITH session_flags AS (
  SELECT
    user_session,

    -- event flags
    MAX(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS viewed,
    MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS carted,
    MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased,

    -- first event timestamps
    MIN(CASE WHEN event_type = 'view' THEN event_time END) AS first_view_time,
    MIN(CASE WHEN event_type = 'cart' THEN event_time END) AS first_cart_time,
    MIN(CASE WHEN event_type = 'purchase' THEN event_time END) AS first_purchase_time,

    -- last event timestamps
    MAX(CASE WHEN event_type = 'view' THEN event_time END) AS last_view_time,
    MAX(CASE WHEN event_type = 'cart' THEN event_time END) AS last_cart_time,
    MAX(CASE WHEN event_type = 'purchase' THEN event_time END) AS last_purchase_time

  FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data_cleaned`
  GROUP BY user_session
),

cart_after_view AS (
  SELECT
    e.user_session,
    MIN(e.event_time) AS first_cart_after_view_time
  FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data_cleaned` e
  JOIN session_flags s
    ON e.user_session = s.user_session
  WHERE e.event_type = 'cart'
    AND e.event_time > s.first_view_time
  GROUP BY e.user_session
),

purchase_after_cart AS (
  SELECT
    e.user_session,
    MIN(e.event_time) AS first_purchase_after_cart_time
  FROM `funnel-analysis-498323.eCommerce_data.nov_2019_behaviour_data_cleaned` e
  JOIN cart_after_view c
    ON e.user_session = c.user_session
  WHERE e.event_type = 'purchase'
    AND e.event_time > c.first_cart_after_view_time
  GROUP BY e.user_session
)

SELECT
  s.user_session,

  -- flags
  s.viewed,
  s.carted,
  s.purchased,

  -- original first timestamps
  s.first_view_time,
  s.first_cart_time,
  s.first_purchase_time,

  -- valid ordered funnel timestamps
  c.first_cart_after_view_time,
  p.first_purchase_after_cart_time,

  -- valid funnel logic
  CASE
    WHEN s.first_view_time IS NOT NULL
     AND c.first_cart_after_view_time IS NOT NULL
     AND p.first_purchase_after_cart_time IS NOT NULL
    THEN 1
    ELSE 0
  END AS valid_full_funnel,

  CASE 
    WHEN c.first_cart_after_view_time IS NOT NULL 
    THEN 1 ELSE 0 
  END AS valid_view_to_cart,

  -- entry type
  CASE
    WHEN s.first_view_time IS NOT NULL
     AND s.first_view_time <= COALESCE(s.first_cart_time, TIMESTAMP '9999-12-31')
     AND s.first_view_time <= COALESCE(s.first_purchase_time, TIMESTAMP '9999-12-31')
    THEN 'view_entry'

    WHEN s.first_cart_time IS NOT NULL
     AND s.first_cart_time <= COALESCE(s.first_view_time, TIMESTAMP '9999-12-31')
     AND s.first_cart_time <= COALESCE(s.first_purchase_time, TIMESTAMP '9999-12-31')
    THEN 'cart_entry'

    WHEN s.first_purchase_time IS NOT NULL
     AND s.first_purchase_time <= COALESCE(s.first_view_time, TIMESTAMP '9999-12-31')
     AND s.first_purchase_time <= COALESCE(s.first_cart_time, TIMESTAMP '9999-12-31')
    THEN 'purchase_entry'

    ELSE 'unknown_entry'
  END AS entry_type,

  CASE
    WHEN s.last_view_time IS NOT NULL
     AND s.last_view_time >= COALESCE(s.last_cart_time, TIMESTAMP '0001-01-01')
     AND s.last_view_time >= COALESCE(s.last_purchase_time, TIMESTAMP '0001-01-01')
    THEN 'view_exit'

    WHEN s.last_cart_time IS NOT NULL
     AND s.last_cart_time >= COALESCE(s.last_view_time, TIMESTAMP '0001-01-01')
     AND s.last_cart_time >= COALESCE(s.last_purchase_time, TIMESTAMP '0001-01-01')
    THEN 'cart_exit'

    WHEN s.last_purchase_time IS NOT NULL
     AND s.last_purchase_time >= COALESCE(s.last_view_time, TIMESTAMP '0001-01-01')
     AND s.last_purchase_time >= COALESCE(s.last_cart_time, TIMESTAMP '0001-01-01')
    THEN 'purchase_exit'

    ELSE 'unknown_exit'
  END AS exit_type,

  -- session type
  CASE
    WHEN s.first_view_time IS NOT NULL
     AND c.first_cart_after_view_time IS NOT NULL
     AND p.first_purchase_after_cart_time IS NOT NULL
    THEN 'standard_full_funnel'

    WHEN s.viewed = 1 AND s.carted = 1 AND s.purchased = 0
    THEN 'view_and_cart_no_purchase'

    WHEN s.viewed = 1 AND s.carted = 0 AND s.purchased = 0
    THEN 'view_only'

    WHEN s.viewed = 0 AND s.carted = 1 AND s.purchased = 1
    THEN 'bottom_funnel'

    WHEN s.viewed = 0 AND s.carted = 0 AND s.purchased = 1
    THEN 'direct_purchase'

    WHEN s.viewed = 1 AND s.carted = 0 AND s.purchased = 1
    THEN 'view_and_purchase_no_cart'

    WHEN s.viewed = 0 AND s.carted = 1 AND s.purchased = 0
    THEN 'cart_only'

    ELSE 'other'
  END AS session_type

FROM session_flags s
LEFT JOIN cart_after_view c
  ON s.user_session = c.user_session
LEFT JOIN purchase_after_cart p
  ON s.user_session = p.user_session;