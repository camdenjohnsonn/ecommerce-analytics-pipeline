-- Revenue, purchases, and unique buyers per day (main trend line).

SELECT
    event_time::date            AS day,
    count(*)                    AS items_purchased,
    count(DISTINCT user_id)     AS buyers,
    round(sum(price), 2)        AS revenue
FROM events
WHERE event_type = 'purchase'
GROUP BY day
ORDER BY day;
