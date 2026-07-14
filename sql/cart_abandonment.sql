-- Share of cart sessions that ended without a purchase.

WITH sessions AS (
    SELECT
        user_session,
        bool_or(event_type = 'cart')     AS added_to_cart,
        bool_or(event_type = 'purchase') AS purchased
    FROM events
    GROUP BY user_session
)
SELECT
    count(*) FILTER (WHERE added_to_cart)                   AS sessions_with_cart,
    count(*) FILTER (WHERE added_to_cart AND purchased)     AS converted,
    count(*) FILTER (WHERE added_to_cart AND NOT purchased) AS abandoned,
    round(100.0 * count(*) FILTER (WHERE added_to_cart AND NOT purchased)
        / count(*) FILTER (WHERE added_to_cart), 2)         AS abandonment_pct
FROM sessions;
