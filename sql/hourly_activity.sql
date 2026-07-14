-- Event counts by hour of day (UTC) and event type.

SELECT
    extract(hour FROM event_time) AS hour_utc,
    event_type,
    count(*)                      AS events
FROM events
GROUP BY hour_utc, event_type
ORDER BY hour_utc, event_type;
