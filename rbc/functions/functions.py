# This script contains the helper functions for the Python portion of the pipeline.
# It defines the ML model training and prediction logic.

# 1. Load required Python packages
# This is only needed if you run this script by hand,
# in which case, uncomment lines 8 to 11.
# With rixpress, the packages get loaded automatically.
#import pandas as pd
#import pyarrow.feather as feather
#from sklearn.model_selection import train_test_split
#import xgboost as xgb
# This script contains the helper functions for the Python portion of the pipeline.
# It defines the ML model training and prediction logic as a pure function.
# This script contains the helper functions for the Python portion of the pipeline.
# It defines the ML model training and prediction logic as a pure function.


"""
train_and_predict_output(simulated_df: pd.DataFrame) -> pd.DataFrame:
    Takes a pandas DataFrame of simulated RBC data, trains an XGBoost model
    to predict the next period's output, and returns a DataFrame containing
    the actual vs. predicted values for the test set.
"""
def train_and_predict_output(simulated_df: pd.DataFrame) -> pd.DataFrame:
    df = simulated_df.copy()

    # Create lagged features (using t-1 to predict t)
    df['output_lag1'] = df['output'].shift(1)
    df['consumption_lag1'] = df['consumption'].shift(1)
    df['investment_lag1'] = df['investment'].shift(1)
    df['capital_lag1'] = df['capital'].shift(1)
    df['technology_lag1'] = df['technology'].shift(1)

    # Target: next period's output
    df['output_target'] = df['output'].shift(-1)

    # Drop rows with NaN (first and last rows)
    df.dropna(inplace=True)

    features = ['output_lag1', 'consumption_lag1', 'investment_lag1', 
                'capital_lag1', 'technology_lag1']

    X = df[features]
    y = df['output_target']

    # Time-series split (no shuffling!)
    train_size = int(0.75 * len(df))
    X_train, X_test = X[:train_size], X[train_size:]
    y_train, y_test = y[:train_size], y[train_size:]

    model = xgb.XGBRegressor(
        objective='reg:squarederror',
        n_estimators=100,
        learning_rate=0.1,
        max_depth=3,
        random_state=42
    )

    model.fit(X_train, y_train)
    predictions = model.predict(X_test)

    results_df = pd.DataFrame({
        'period': y_test.index,
        'actual_output': y_test.values,
        'predicted_output': predictions
    })

    return results_df

"""
save_arrow(df: pd.DataFrame, path: str)
    Encoder function to save a pandas DataFrame to an Arrow file.
"""
def save_arrow(df: pd.DataFrame, path: str):
    feather.write_feather(df, path)
