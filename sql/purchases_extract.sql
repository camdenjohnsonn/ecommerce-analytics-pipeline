-- Row-level extract for the Excel analysis: one row per item purchased,
-- with brand and category names joined in (~74k rows, Excel-friendly).

SELECT
    e.event_time,
    e.event_time::date                    AS purchase_date,
    e.user_id,
    e.user_session,
    e.product_id,
    coalesce(p.brand, 'other')          AS brand,
    coalesce(c.category_code, 'other')  AS category,
    coalesce(c.category_group, 'other') AS category_group,
    e.price
FROM events e
JOIN products p ON p.product_id = e.product_id
LEFT JOIN categories c ON c.category_id = p.category_id
WHERE e.event_type = 'purchase'
ORDER BY e.event_time;
