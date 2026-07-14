"""Create the database tables by running sql/schema.sql against Postgres.

Usage:
    python src/build_tables.py     (from the project root)
"""

import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

user = os.getenv("POSTGRES_USER")
password = os.getenv("POSTGRES_PASSWORD")
host = os.getenv("POSTGRES_HOST")
port = os.getenv("POSTGRES_PORT")
db = os.getenv("POSTGRES_DB")
engine = create_engine(f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}")

with open("sql/schema.sql") as f:
    schema_sql = f.read()

with engine.begin() as conn:
    conn.execute(text(schema_sql))

print("created empty tables: categories, products, events")
