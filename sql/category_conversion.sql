-- Which category groups convert browsers into buyers best?
-- events (fact) -> products -> categories, then compare views vs purchases.
-- HAVING keeps only groups with enough traffic to be meaningful.

SELECT
    coalesce(c.category_group, 'other')             AS category_group,
    count(*) FILTER (WHERE e.event_type = 'view')     AS views,
    count(*) FILTER (WHERE e.event_type = 'purchase') AS purchases,
    round(100.0 * count(*) FILTER (WHERE e.event_type = 'purchase')
        / nullif(count(*) FILTER (WHERE e.event_type = 'view'), 0), 2)
                                                      AS view_to_purchase_pct,
    round(sum(e.price) FILTER (WHERE e.event_type = 'purchase'), 2) AS revenue
FROM events e
JOIN products p ON p.product_id = e.product_id
LEFT JOIN categories c ON c.category_id = p.category_id
GROUP BY category_group
HAVING count(*) FILTER (WHERE e.event_type = 'view') > 10000
ORDER BY view_to_purchase_pct DESC;
