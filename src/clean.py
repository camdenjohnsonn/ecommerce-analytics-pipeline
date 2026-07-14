"""Clean the sampled ecommerce CSV and save it as data/clean_events.csv.

Usage:
    python src/clean.py     (from the project root)
"""

import pandas as pd

RAW_FILE = "data/2019-Oct-sample.csv"
CLEAN_FILE = "data/clean_events.csv"

df = pd.read_csv(RAW_FILE)
print(f"rows read: {len(df):,}")

# drop exact duplicate rows
before = len(df)
df = df.drop_duplicates()
print(f"duplicate rows dropped: {before - len(df):,}")

# turn event_time into a real timestamp; anything that fails to parse
# becomes NaT (not-a-time) and gets dropped on the next line
df["event_time"] = pd.to_datetime(df["event_time"], format="%Y-%m-%d %H:%M:%S UTC",
                                  utc=True, errors="coerce")
before = len(df)
df = df.dropna(subset=["event_time"])
print(f"bad timestamps dropped: {before - len(df):,}")

# price must be a number that is zero or more
before = len(df)
df = df[df["price"] >= 0]
print(f"bad prices dropped: {before - len(df):,}")

# every row needs a session id (the funnel queries group by session)
before = len(df)
df = df.dropna(subset=["user_session"])
print(f"missing session dropped: {before - len(df):,}")

# missing brand/category are fine to keep - just report how common they are
print(f"rows kept: {len(df):,}")
print(f"  of those, missing brand: {df['brand'].isna().sum():,}")
print(f"  of those, missing category name: {df['category_code'].isna().sum():,}")

df.to_csv(CLEAN_FILE, index=False)
print(f"saved {CLEAN_FILE}")
