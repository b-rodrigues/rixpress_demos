import polars
from pathlib import Path

def read_many_csvs(dir_path):
    folder = Path(dir_path)
    csv_files = folder.glob("*.csv")
    return polars.concat([polars.read_csv(f) for f in csv_files])
