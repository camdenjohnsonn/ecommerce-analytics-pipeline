"""Clean the sampled ecommerce CSV and write data/clean_events.csv.

Usage:
    python src/clean.py     (from the project root)
"""

import pandas as pd

RAW_FILE = "data/2019-Oct-sample.csv"
CLEAN_FILE = "data/clean_events.csv"

df = pd.read_csv(RAW_FILE)
print(f"rows read: {len(df):,}")

before = len(df)
df = df.drop_duplicates()
print(f"duplicate rows dropped: {before - len(df):,}")

df["event_time"] = pd.to_datetime(df["event_time"], format="%Y-%m-%d %H:%M:%S UTC",
                                  utc=True, errors="coerce")
before = len(df)
df = df.dropna(subset=["event_time"])
print(f"bad timestamps dropped: {before - len(df):,}")

before = len(df)
df = df[df["price"] >= 0]
print(f"bad prices dropped: {before - len(df):,}")

before = len(df)
df = df.dropna(subset=["user_session"])
print(f"missing session dropped: {before - len(df):,}")

print(f"rows kept: {len(df):,}")
print(f"  of those, missing brand: {df['brand'].isna().sum():,}")
print(f"  of those, missing category name: {df['category_code'].isna().sum():,}")

df.to_csv(CLEAN_FILE, index=False)
print(f"saved {CLEAN_FILE}")
