-- Star schema for the ecommerce events dataset.
-- load_data.py derives the three tables from the clean CSV with pandas
-- and bulk-loads them. Rerunnable: drops and recreates everything.

DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;

-- dimension: one row per category
CREATE TABLE categories (
    category_id    BIGINT PRIMARY KEY,
    category_code  TEXT,   -- e.g. electronics.smartphone (often missing)
    category_group TEXT    -- first part of the code, e.g. electronics
);

-- dimension: one row per product
CREATE TABLE products (
    product_id  BIGINT PRIMARY KEY,
    brand       TEXT,
    category_id BIGINT REFERENCES categories (category_id)
);

-- fact: one row per user action
CREATE TABLE events (
    event_id     BIGSERIAL PRIMARY KEY,
    -- plain TIMESTAMP (no time zone), always UTC. A timezone-aware column
    -- gets silently converted to the viewer's local time by BI tools.
    event_time   TIMESTAMP NOT NULL,
    event_type   TEXT      NOT NULL,     -- view / cart / purchase
    product_id   BIGINT      NOT NULL REFERENCES products (product_id),
    user_id      BIGINT      NOT NULL,
    user_session TEXT,
    price        NUMERIC(10, 2)          -- price at the time of the event
);

CREATE INDEX idx_events_event_time ON events (event_time);
CREATE INDEX idx_events_event_type ON events (event_type);
CREATE INDEX idx_events_user_id    ON events (user_id);
CREATE INDEX idx_events_product_id ON events (product_id);
