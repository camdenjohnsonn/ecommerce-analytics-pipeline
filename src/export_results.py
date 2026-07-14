"""Run each dashboard query and save its result as a CSV in outputs/.

These CSVs feed the Excel analysis, and work as a Power BI import
fallback if the direct Postgres connection gives trouble.

Usage:
    python src/export_results.py     (from the project root)
"""

import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv()

user = os.getenv("POSTGRES_USER")
password = os.getenv("POSTGRES_PASSWORD")
host = os.getenv("POSTGRES_HOST")
port = os.getenv("POSTGRES_PORT")
db = os.getenv("POSTGRES_DB")
engine = create_engine(f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}")

QUERIES = [
    "kpi_summary",
    "daily_revenue",
    "funnel_conversion",
    "cart_abandonment",
    "top_categories",
    "top_brands",
    "category_conversion",
    "hourly_activity",
]

os.makedirs("outputs", exist_ok=True)

for name in QUERIES:
    with open(f"sql/{name}.sql") as f:
        query = f.read()
    result = pd.read_sql(query, engine)
    result.to_csv(f"outputs/{name}.csv", index=False)
    print(f"outputs/{name}.csv: {len(result)} rows")

# row-level purchases extract for the Excel analysis - bigger than the
# dashboard results above, so it gets its own folder
os.makedirs("excel", exist_ok=True)
with open("sql/purchases_extract.sql") as f:
    query = f.read()
purchases = pd.read_sql(query, engine)
purchases.to_csv("excel/purchases.csv", index=False)
print(f"excel/purchases.csv: {len(purchases)} rows")
