"""Load data/clean_events.csv into Postgres as a star schema.

Usage:
    python src/load_data.py     (from the project root)
"""

import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

user = os.getenv("POSTGRES_USER")
password = os.getenv("POSTGRES_PASSWORD")
host = os.getenv("POSTGRES_HOST")
port = os.getenv("POSTGRES_PORT")
db = os.getenv("POSTGRES_DB")
engine = create_engine(f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}")

df = pd.read_csv("data/clean_events.csv")

categories = df[["category_id", "category_code"]].sort_values("category_code")
categories = categories.drop_duplicates("category_id")
categories["category_code"] = categories["category_code"].fillna("other")
categories["category_group"] = categories["category_code"].str.split(".").str[0]

products = df.sort_values("event_time").drop_duplicates("product_id", keep="last")
products = products[["product_id", "brand", "category_id"]]
products["brand"] = products["brand"].fillna("other")

events = df[["event_time", "event_type", "product_id", "user_id", "user_session", "price"]]

with engine.begin() as conn:
    conn.execute(text("TRUNCATE events, products, categories RESTART IDENTITY;"))

categories.to_sql("categories", engine, if_exists="append", index=False,
                  chunksize=10_000, method="multi")
print(f"inserted {len(categories):,} rows into categories")

products.to_sql("products", engine, if_exists="append", index=False,
                chunksize=10_000, method="multi")
print(f"inserted {len(products):,} rows into products")

events.to_sql("events", engine, if_exists="append", index=False,
              chunksize=10_000, method="multi")
print(f"inserted {len(events):,} rows into events")

with engine.connect() as conn:
    for table in ["categories", "products", "events"]:
        count = conn.execute(text(f"SELECT count(*) FROM {table}")).scalar()
        print(f"{table} now has {count:,} rows")
