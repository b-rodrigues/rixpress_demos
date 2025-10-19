# This script defines and orchestrates the entire reproducible analytical pipeline
# using the {rixpress} package.

library(rixpress)

# Define the full pipeline as a list of derivations and pipe it to rxp_populate()
# to generate the Nix build instructions and execute the pipeline.
list(
  # STEP 0: Define RBC Model Parameters as Derivations
  # This makes the parameters an explicit part of the pipeline.
  # Changing a parameter will cause downstream steps to rebuild.
  rxp_jl(alpha, 0.3), # Capital's share of income
  rxp_jl(beta, 1 / 1.01), # Discount factor
  rxp_jl(delta, 0.025), # Depreciation rate
  rxp_jl(rho, 0.95), # Technology shock persistence
  rxp_jl(sigma, 1.0), # Risk aversion (log-utility)
  rxp_jl(sigma_z, 0.01), # Technology shock standard deviation

  # STEP 1: Julia - Simulate a Real Business Cycle (RBC) model.
  # This derivation runs our Julia script to generate the source data.
  rxp_jl(
    name = simulated_rbc_data,
    expr = "simulate_rbc_model(alpha, beta, delta, rho, sigma, sigma_z)",
    user_functions = "functions/functions.jl", # The file containing the function
    encoder = "arrow_write" # The function to use for saving the output
  ),

  # STEP 2: Python - Train an XGBoost model on the simulated data.
  # This derivation depends on the output of the Julia step.
  rxp_py(
    name = predictions,
    # The expression is now a clean function call. {rixpress} handles
    # passing the `simulated_rbc_data` DataFrame as the argument.
    expr = "train_and_predict_output(simulated_rbc_data)",
    user_functions = "functions/functions.py",
    # The decoder is still needed to convert the .arrow file from Julia
    # into the pandas DataFrame that our function expects.
    decoder = "feather.read_feather",
    # The encoder is still needed to take the DataFrame returned by our
    # function and save it to a .arrow file for the next step.
    encoder = "save_arrow"
  ),

  # STEP 3: R - Visualize the predictions from the Python model.
  # This final derivation depends on the output of the Python step.
  rxp_r(
    name = output_plot,
    expr = plot_predictions(predictions), # The function to call from functions.R
    user_functions = "functions/functions.R",
    # Specify how to load the upstream data (from Python) into R.
    decoder = arrow::read_ipc_file
  ),

  # STEP 4: Quarto - Compile the final report.
  rxp_qmd(
    name = final_report,
    qmd_file = "readme.qmd"
  )
) |>
  rxp_populate(
    py_imports = c(
      pandas = "import pandas as pd",
      pyarrow = "import pyarrow.feather as feather",
      sklearn = "from sklearn.model_selection import train_test_split",
      xgboost = "import xgboost as xgb"
    ),
    project_path = ".", # The root of our project
    build = TRUE, # Set to TRUE to execute the pipeline immediately
    verbose = 0
  )

# Plot DAG for CI
rxp_dag_for_ci()
