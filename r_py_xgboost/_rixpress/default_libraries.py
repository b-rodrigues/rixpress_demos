from numpy import array, column_stack, loadtxt, nan, savetxt
import pickle
from sklearn.model_selection import train_test_split
from xgboost import XGBClassifier
def write_to_csv(data, file_path):
    """
    Save a NumPy array to a CSV file.

    Parameters:
    data (numpy.ndarray): The NumPy array to save.
    file_path (str): The path where the CSV file will be saved.
    """
    # Using '%s' will save numbers as strings, including 'nan'.
    # If you need specific numeric formatting, adjust 'fmt'.
    savetxt(file_path, data, delimiter=',', fmt='%s')

def combine_dataset_with_predictions(dataset, y_pred, test_indices):
    """
    Combine the original dataset with predicted values, placing predictions
    at test set indices and NaN elsewhere.

    Parameters:
    dataset (numpy.ndarray): The original dataset.
    y_pred (numpy.ndarray): Predicted values for the test set.
    test_indices (numpy.ndarray): Indices of the test set rows in the original dataset.

    Returns:
    numpy.ndarray: The combined dataset with an additional predictions column.
    """
    # Convert test_indices to a list for index() method, ensure y_pred is aligned
    test_indices_list = list(test_indices)
    # Create the prediction column
    pred_column = [y_pred[test_indices_list.index(i)] if i in test_indices_list else nan
                   for i in range(dataset.shape[0])]

    # Stack the original dataset and the new prediction column
    # Ensure the new column is treated as a column vector for stacking
    combined = column_stack((dataset, array(pred_column).reshape(-1, 1)))
    return combined
from sklearn.metrics import accuracy_score
