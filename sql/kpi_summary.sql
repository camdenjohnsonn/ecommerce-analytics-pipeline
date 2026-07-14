-- Headline numbers for the dashboard KPI cards (an order = one session's purchases).

WITH totals AS (
    SELECT
        round(sum(price) FILTER (WHERE event_type = 'purchase'), 2) AS total_revenue,
        count(*) FILTER (WHERE event_type = 'purchase')             AS items_purchased,
        count(DISTINCT user_id)                                     AS total_users,
        count(DISTINCT user_id) FILTER (WHERE event_type = 'purchase') AS buyers
    FROM events
),
orders AS (
    SELECT user_session, sum(price) AS order_value
    FROM events
    WHERE event_type = 'purchase'
    GROUP BY user_session
)
SELECT
    totals.*,
    (SELECT count(*) FROM orders)                   AS total_orders,
    (SELECT round(avg(order_value), 2) FROM orders) AS avg_order_value
FROM totals;
