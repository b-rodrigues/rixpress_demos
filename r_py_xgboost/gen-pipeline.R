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

  # Split X and Y
  rxp_py(
    name = splits,
    py_expr = "train_test_split(X, Y, test_size=0.33, random_state=7)"
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

  rxp_py(
    name = combined_df,
    py_expr = "DataFrame({'truth': y_test, 'estimate': y_pred})"
  ),

  rxp_py(
    name = combined_csv,
    py_expr = "combined_df",
    additional_files = "functions.py",
    serialize_function = "write_to_csv"
  ),

  # yardstick::conf_mat needs factor variables
  rxp_r(
    combined_factor,
    expr = mutate(
      combined_csv,
      across(.cols = everything(), .fns = factor)
    ),
    unserialize_function = "read.csv"
  ),

  rxp_r(
    name = confusion_matrix,
    expr = conf_mat(
      combined_factor,
      truth,
      estimate
    )
  ),

  # Calculate the accuracy score
  rxp_py(
    name = accuracy,
    py_expr = "accuracy_score(y_test, y_pred)"
  )
) |>
  rixpress(build = FALSE) # Need to set to FALSE because we
# adjust imports first

adjust_import(
  "import numpy",
  "from numpy import array, loadtxt"
)

adjust_import("import xgboost", "from xgboost import XGBClassifier")

adjust_import(
  "import sklearn",
  "from sklearn.model_selection import train_test_split"
)

add_import("from sklearn.metrics import accuracy_score", "default.nix")
add_import("from pandas import DataFrame", "default.nix")

# Now we can build
rxp_make()
