library(rixpress)
library(dplyr)

# Define and build the pipeline
list(
  # === R Data Loading ===
  rxp_r_file(
    name = train_data, # Output: R data.table
    path = "data/train.csv",
    read_function = load_dataset,
  ),
  rxp_r_file(
    name = test_data, # Output: R data.table
    path = "data/test.csv",
    read_function = load_dataset,
  ),

  # === R Preprocessing and Plotting (Parallel Branch) ===
  rxp_r(
    name = processed_train, # Output: R data.frame/tibble
    expr = pre_process(train_data),
    additional_files = "functions.R"
  ),
  rxp_r(
    name = processed_test, # Output: R data.frame/tibble
    expr = pre_process(test_data),
    additional_files = "functions.R"
  ),
  rxp_r(
    name = plot_train_sex, # Output: R ggplot object (RDS)
    expr = bar_plot(df = processed_train, col = 'Sex', insight = 'Train Data Sex Distribution', flip = FALSE),
    additional_files = "functions.R"
  ),
  rxp_r(
    name = plot_test_pclass, # Output: R ggplot object (RDS)
    expr = bar_plot(df = processed_test, col = 'Pclass', insight = 'Test Data Pclass Distribution', flip = FALSE),
    additional_files = "functions.R"
  ),

  # === Transfer R data.tables to CSV files ===
  rxp_r(
    name = train_data_csv, # Output: Directory containing train_data_csv file
    expr = train_data,     # Input is the R object
    # Use fwrite to write the CSV. It writes a file named 'train_data_csv' inside the output dir.
    serialize_function = data.table::fwrite
  ),
  rxp_r(
    name = test_data_csv, # Output: Directory containing test_data_csv file
    expr = test_data,
    serialize_function = data.table::fwrite
  ),

  # === Python Preprocessing & Modeling Steps (Reads CSVs) ===
  rxp_py(
    name = preprocess_train_step, # Output: Python tuple (df, stats) pickled
    # Read the CSV using pandas inside the expression
    # The path is ${derivation_name}/derivation_name
    py_expr = "df = pd.read_csv(f'{train_data_csv}/train_data_csv'); preprocess_dataframe(df, is_train=True)",
    additional_files = "functions.py"
    # No unserialize_function needed here; the input CSV is read explicitly
  ),

  # Extract processed training data (DataFrame)
  rxp_py(
      name = py_processed_train,
      py_expr = "preprocess_train_step[0]"
  ),

  # Extract training statistics (dict)
  rxp_py(
      name = train_stats,
      py_expr = "preprocess_train_step[1]"
  ),

  # Preprocess test data using training stats (DataFrame)
  rxp_py(
    name = py_processed_test,
     # Read the test CSV using pandas inside the expression
    py_expr = "df = pd.read_csv(f'{test_data_csv}/test_data_csv'); preprocess_dataframe(df, is_train=False, train_stats=train_stats)",
    additional_files = "functions.py"
  ),

  # Feature/Target Split (Python) - uses Python processed data
  rxp_py(
    name = split_train_data,
    py_expr = "split_predictors_target(py_processed_train)",
    additional_files = "functions.py"
  ),
  # Predictors contain PassengerId at this stage
  rxp_py( name = predictors_train_py, py_expr = "split_train_data[0]" ),
  rxp_py( name = target_train_py,     py_expr = "split_train_data[1]" ),

  # Drop PassengerId from predictors *before* train/test split for modeling
  rxp_py(
    name = predictors_train_final,
    py_expr = "predictors_train_py.drop('PassengerId', axis=1, errors='ignore')"
  ),

  # Train/Validation Split (Python) - Uses predictors without PassengerId
  rxp_py(
    name = train_val_split_data,
    py_expr = "train_test_split(predictors_train_final, target_train_py, test_size=0.2, random_state=0)"
  ),
  rxp_py(name = X_train, py_expr = "train_val_split_data[0]"),
  rxp_py(name = X_val,   py_expr = "train_val_split_data[1]"),
  rxp_py(name = y_train, py_expr = "train_val_split_data[2]"),
  rxp_py(name = y_val,   py_expr = "train_val_split_data[3]"),

  # Model Training (Python)
  rxp_py(
    name = model,
    py_expr = "RandomForestClassifier(random_state=42).fit(X_train, y_train)"
  ),

  # Validation (Python)
  rxp_py( name = y_pred_val, py_expr = "model.predict(X_val)" ),
  rxp_py( name = validation_accuracy, py_expr = "accuracy_score(y_val, y_pred_val)" ),

  # Test Set Prediction (Python)
  # Extract PassengerId from the Python-processed test data
   rxp_py(
       name = test_ids_py,
       py_expr = "py_processed_test['PassengerId']" # Assumes PassengerId is still present
   ),
   # Prepare test features (drop PassengerId)
   rxp_py(
       name = py_test_features,
       py_expr = "py_processed_test.drop('PassengerId', axis=1, errors='ignore')"
   ),
  # Predict
  rxp_py(
    name = test_predictions,
    py_expr = "model.predict(py_test_features)"
  ),

  # Combine IDs and predictions (Python DataFrame)
  rxp_py(
    name = output_df,
    py_expr = "pd.DataFrame({'PassengerId': test_ids_py, 'Survived': test_predictions})",
    additional_files = "functions.py" # For pd.DataFrame
  ),

  # Final Output CSV (Python) - Using custom serialization function
  rxp_py(
    name = result_csv,
    py_expr = "output_df",
    additional_files = "functions.py",
    serialize_function = "write_dataframe_to_csv"
  )
) |>
  rixpress(build = FALSE) # Generate pipeline.nix first

# --- Build Setup (Adjust Imports) ---
# Add required Python imports
adjust_import("import pandas", "import pandas as pd")
adjust_import("import numpy", "import numpy as np")
adjust_import("import pickle", "import pickle") # Still potentially used by defaults
adjust_import("import sklearn", "from sklearn.model_selection import train_test_split")
adjust_import("import sklearn", "from sklearn.ensemble import RandomForestClassifier", append=TRUE)
adjust_import("import sklearn", "from sklearn.metrics import accuracy_score", append=TRUE)
# No need to adjust R imports unless using packages not in the base env

# --- Build the pipeline ---
# dag_for_ci() # Optional
rxp_make()   # Trigger the build
