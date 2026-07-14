-- Top 15 brands by purchase revenue.

SELECT
    coalesce(p.brand, 'other') AS brand,
    count(*)                   AS items_purchased,
    round(sum(e.price), 2)     AS revenue,
    round(avg(e.price), 2)     AS avg_item_price
FROM events e
JOIN products p ON p.product_id = e.product_id
WHERE e.event_type = 'purchase'
GROUP BY brand
ORDER BY revenue DESC
LIMIT 15;
