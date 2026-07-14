-- Funnel by user: cart->purchase measured on users who did both steps
-- (this dataset records some purchases with no preceding cart event).

WITH per_user AS (
    SELECT
        user_id,
        bool_or(event_type = 'view')     AS viewed,
        bool_or(event_type = 'cart')     AS carted,
        bool_or(event_type = 'purchase') AS bought
    FROM events
    GROUP BY user_id
)
SELECT
    count(*) FILTER (WHERE viewed)             AS viewers,
    count(*) FILTER (WHERE carted)             AS carters,
    count(*) FILTER (WHERE bought)             AS buyers,
    round(100.0 * count(*) FILTER (WHERE viewed AND carted)
        / count(*) FILTER (WHERE viewed), 2)   AS pct_view_to_cart,
    round(100.0 * count(*) FILTER (WHERE carted AND bought)
        / count(*) FILTER (WHERE carted), 2)   AS pct_cart_to_purchase,
    round(100.0 * count(*) FILTER (WHERE viewed AND bought)
        / count(*) FILTER (WHERE viewed), 2)   AS pct_view_to_purchase
FROM per_user;
