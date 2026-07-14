# E-Commerce Event Analytics

End-to-end analytics project on 42M e-commerce events: Python cleaning → PostgreSQL star
schema → SQL analysis → Power BI dashboard → Excel business case.

**Data:** [eCommerce behavior data from multi category store](https://www.kaggle.com/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store)
(Kaggle) — one month (Oct 2019) of view/cart/purchase events from a large online retailer.

## Key findings

- **$23.4M revenue, 63K orders, $371 average order value** (10% user sample)
- **11.5% of visitors purchase**; electronics converts browsers to buyers at **2.8%** — over 5x apparel's 0.5%
- Smartphones drive **70% of revenue**; Apple alone is ~half at a $790 average item price
- **48.7% of carts are abandoned** — recovering just 10% of them is worth **~$1M/month** (+4.4% revenue)
- Traffic peaks at ~9pm local time; the store is effectively dead 3–6am

## Results

- [`powerbi/dashboard.pdf`](powerbi/dashboard.pdf) — 3-page Power BI dashboard (overview, products, behavior), connected live to Postgres
- [`excel/ecommerce_analytics.xlsx`](excel/ecommerce_analytics.xlsx) — pivot analysis, XLOOKUP/SUMIFS lookup cards, and a cart-recovery what-if calculator
- [`sql/`](sql/) — the eight analysis queries behind the dashboard metrics

## How it works

```
raw CSV (5.3GB, 42M rows)
   │  sample 1-in-10 users (sessions stay complete)
   ▼
clean.py        pandas: dedupe, validate timestamps/prices, quality report
   ▼
load_data.py    split into a star schema, bulk-insert into Postgres
   ▼
sql/*.sql       revenue, funnel, abandonment, conversion queries
   ▼
Power BI (live connection) · Excel (row-level purchase extract)
```

### Star schema

```
categories (614)          products (116K)          events (4.2M)
-----------------         ----------------         -------------------------
category_id (PK)  <----   category_id (FK)         event_id (PK)
category_code             product_id (PK)  <----   product_id (FK)
category_group            brand                    event_time, event_type
                                                   user_id, user_session, price
```

## Running it

```bash
docker compose up -d                    # Postgres 16 on localhost:5434
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# put the Kaggle 2019-Oct.csv in data/, then:
awk -F, 'NR==1 || $8 % 10 == 0' data/2019-Oct.csv > data/2019-Oct-sample.csv

python src/build_tables.py              # create empty tables from sql/schema.sql
python src/clean.py                     # raw sample -> data/clean_events.csv
python src/load_data.py                 # clean CSV -> star schema in Postgres
python src/export_results.py            # run queries -> outputs/*.csv + excel extract
```

Credentials live in `.env` (see `.env.example`). Power BI connects to
`localhost:5434`, database `ecommerce`.

## Notes & lessons

- **Sampling by user, not by row** — random rows would orphan purchases from their
  sessions and corrupt funnel metrics; keeping 1-in-10 users intact preserves them.
- **The funnel that read 103%** — this dataset records purchases with no preceding cart
  event. Conversion is measured on users who did *both* steps (see `sql/funnel_conversion.sql`).
- **The heatmap that was wrong twice** — timestamps are UTC but customers are ~UTC+5, and
  BI tools silently convert timezone-aware columns to the viewer's local time. Fixed by
  storing naive UTC timestamps and shifting explicitly in the model.
- ~32% of rows lack a category label and 14% lack a brand; they're kept as `other` in
  composition views and excluded from rankings.
