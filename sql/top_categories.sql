-- Top 15 categories by purchase revenue.
-- Two joins: events (fact) -> products -> categories.
-- LEFT JOIN because a product's category can be unknown.

SELECT
    coalesce(c.category_code, 'other')  AS category,
    coalesce(c.category_group, 'other') AS category_group,
    count(*)                              AS items_purchased,
    round(sum(e.price), 2)                AS revenue
FROM events e
JOIN products p ON p.product_id = e.product_id
LEFT JOIN categories c ON c.category_id = p.category_id
WHERE e.event_type = 'purchase'
GROUP BY category, category_group
ORDER BY revenue DESC
LIMIT 15;
