from numpy import array, loadtxt
import pandas
import pickle
from sklearn.model_selection import train_test_split
from xgboost import XGBClassifier
def write_to_csv(df, path):
    df.to_csv(path, index=False)
from sklearn.metrics import accuracy_score
from pandas import DataFrame
