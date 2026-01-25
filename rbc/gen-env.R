# This script defines the polyglot environment our pipeline will run in.
# It uses the {rix} package to create a 'default.nix' file, which serves
# as a blueprint for a fully reproducible environment.

library(rix)

# Define the complete execution environment
rix(
  # Pin the environment to a specific date to ensure that all package
  # versions are resolved as they were on this day.
  date = "2026-01-19",

  # 1. R Packages
  # We need packages for plotting, data manipulation, and reading arrow files.
  # We also include reticulate as it can be useful for rixpress internals.
  r_pkgs = c(
    "ggplot2",
    "ggdag",
    "dplyr",
    "arrow",
    "quarto"
  ),

  git_pkgs = list(
    package_name = "rixpress",
    repo_url = "https://github.com/ropensci/rixpress",
    commit = "HEAD"
  ),
  
  # 2. Julia Configuration
  # We specify the Julia version and the list of packages needed
  # for our manual RBC model simulation.
  jl_conf = list(
    jl_version = "lts",
    jl_pkgs = c(
      "Distributions", # For creating random shocks
      "DataFrames", # For structuring the output
      "Arrow", # For saving the data in a cross-language format
      "Random"
    )
  ),

  # 3. Python Configuration
  # We specify the Python version and the packages needed for the
  # machine learning step.
  py_conf = list(
    py_version = "3.13",
    py_pkgs = c(
      "pandas",
      "scikit-learn",
      "xgboost",
      "pyarrow"
    ),
    git_pkgs = list(
      list(
        package_name = "ryxpress",
        repo_url = "https://github.com/b-rodrigues/ryxpress",
        commit = "HEAD"
      )
    )
  ),

  # We set the IDE to 'none' for a minimal environment. You could change
  # this to "rstudio" if you prefer to work interactively in RStudio.
  ide = "none",

  # Define the project path and allow overwriting the default.nix file.
  project_path = ".",
  overwrite = TRUE
)

# A message to confirm the script has run successfully.
message("Successfully generated 'default.nix' environment file.")
