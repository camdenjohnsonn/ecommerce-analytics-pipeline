-- Star schema for the ecommerce events dataset (rerunnable).

DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
    category_id    BIGINT PRIMARY KEY,
    category_code  TEXT,
    category_group TEXT
);

CREATE TABLE products (
    product_id  BIGINT PRIMARY KEY,
    brand       TEXT,
    category_id BIGINT REFERENCES categories (category_id)
);

CREATE TABLE events (
    event_id     BIGSERIAL PRIMARY KEY,
    event_time   TIMESTAMP NOT NULL,
    event_type   TEXT      NOT NULL,
    product_id   BIGINT    NOT NULL REFERENCES products (product_id),
    user_id      BIGINT    NOT NULL,
    user_session TEXT,
    price        NUMERIC(10, 2)
);

CREATE INDEX idx_events_event_time ON events (event_time);
CREATE INDEX idx_events_event_type ON events (event_type);
CREATE INDEX idx_events_user_id    ON events (user_id);
CREATE INDEX idx_events_product_id ON events (product_id);
