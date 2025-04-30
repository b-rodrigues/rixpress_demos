library(rixpress)

# Define the rixpress pipeline
list(
  # Load the dataset from the CSV file into a NumPy array
  rxp_py_file(
    name = dataset_np, # Keep name indicating NumPy array
    path = "data/pima-indians-diabetes.csv",
    # Ensure loadtxt is available (either via functions.py import or default.nix)
    read_function = "lambda x: loadtxt(x, delimiter=',')"
  ),

  # Extract features (columns 0 to 7)
  rxp_py(
    name = X,
    py_expr = "dataset_np[:,0:8]"
  ),

  # Extract target variable (column 8)
  rxp_py(
    name = Y,
    py_expr = "dataset_np[:,8]"
  ),

  # Create an array of indices for the original dataset
  rxp_py(
    name = indices,
    # Ensure arange is available
    py_expr = "arange(X.shape[0])"
  ),

  # Split X, Y, and the indices array
  rxp_py(
    name = splits,
    py_expr = "train_test_split(X, Y, indices, test_size=0.33, random_state=7)"
  ),

  # Extract X_train (index 0)
  rxp_py(
    name = X_train,
    py_expr = "splits[0]"
  ),

  # Extract X_test (index 1)
  rxp_py(
    name = X_test,
    py_expr = "splits[1]"
  ),

  # Extract y_train (index 2)
  rxp_py(
    name = y_train,
    py_expr = "splits[2]"
  ),

  # Extract y_test (index 3)
  rxp_py(
    name = y_test,
    py_expr = "splits[3]"
  ),

  # Extract test_indices (index 5) - THIS IS WHAT WE NEED
  rxp_py(
    name = test_indices,
    py_expr = "splits[5]"
  ),

  # Train the XGBoost classifier
  rxp_py(
    name = model,
    py_expr = "XGBClassifier(use_label_encoder=False, eval_metric='logloss').fit(X_train, y_train)"
  ),

  # Make predictions on the test data
  rxp_py(
    name = y_pred,
    py_expr = "model.predict(X_test)"
  ),

  # Combine original data with predictions using your NumPy function
  rxp_py(
    name = combined_dataset_np, # Output is a NumPy array
    # Call your specific function
    py_expr = "combine_dataset_with_predictions(dataset_np, y_pred, test_indices)",
    # Specify the file containing the function
    additional_files = "functions.py",
    # Use your specific NumPy CSV writing function for serialization
    serialize_function = "write_to_csv"
  ),

  # Calculate the accuracy score
  rxp_py(
    name = accuracy,
    py_expr = "accuracy_score(y_test, y_pred)"
  )
) |>
  rixpress(build = FALSE)
  
adjust_import("import numpy", "from numpy import arange, array, column_stack, loadtxt, nan, savetxt")
adjust_import("import xgboost", "from xgboost import XGBClassifier")
adjust_import("import sklearn", "from sklearn.model_selection import train_test_split")
add_import("from sklearn.metrics import accuracy_score", "default.nix")
