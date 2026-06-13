import os
import pandas as pd
from sqlalchemy import create_engine, text

# config
DB_URI = os.environ.get("DATABASE_URL")
CSV_DIR = "."

# files from football-data.co.uk
SEASONS_DATA = {
    "E0.csv": "2025/26",
    "E0 (1).csv": "2024/25",
    "E0 (2).csv": "2023/24",
    "E0 (3).csv": "2022/23",
    "E0 (4).csv": "2021/22",
    "E0 (5).csv": "2020/21",
    "E0 (6).csv": "2019/20",
    "E0 (7).csv": "2018/19",
    "E0 (8).csv": "2017/18",
    "E0 (9).csv": "2016/17",
}


def get_era(season_str):
    if season_str in ("2016/17", "2017/18", "2018/19"):
        return "Pre-VAR"
    elif season_str == "2019/20":
        return "VAR Intro"
    elif season_str == "2020/21":
        return "Ghost Game"
    else:
        return "Post-VAR"


TARGET_COLS = [
    "Date",
    "HomeTeam",
    "AwayTeam",
    "FTHG",
    "FTAG",
    "FTR",
    "Referee",
    "HF",
    "AF",
    "HY",
    "AY",
    "HR",
    "AR",
]

# load and process
all_seasons = []

for filename, season in SEASONS_DATA.items():
    path = os.path.join(CSV_DIR, filename)

    if not os.path.exists(path):
        continue

    df = pd.read_csv(path, usecols=lambda c: c in TARGET_COLS)

    # drop empty trailing rows
    df = df.dropna(subset=["Date", "FTR"])

    # format dates
    df["Date"] = pd.to_datetime(df["Date"], dayfirst=True).dt.date

    df["season"] = season
    df["era"] = get_era(season)

    all_seasons.append(df)

# combine datasets
main_df = pd.concat(all_seasons)

# lowercase for sql
main_df.columns = [col.lower() for col in main_df.columns]

# database export
db_engine = create_engine(DB_URI)

with db_engine.connect() as connection:
    connection.execute(text("SELECT 1"))

main_df.to_sql(
    name="matches", con=db_engine, if_exists="replace", index=False, chunksize=500
)