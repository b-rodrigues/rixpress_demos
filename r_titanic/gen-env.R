library(rix)

rix(
  date = "2025-04-29", # Or keep your original date
  r_pkgs = c(
    "dplyr",
    "data.table", # Needed for the R loading function
    "ggplot2",
    "scales",
    "readr",
    "rlang"
  ),
  py_conf = list(
    py_version = "3.13",
    py_pkgs = c(
    "pandas",
    "numpy",
    "scikit-learn"
    )
  ),
  git_pkgs = list(
    list(
      package_name = "rix",
      repo_url = "https://github.com/ropensci/rix/",
      commit = "HEAD"
    ),
    list(
      package_name = "rixpress",
      repo_url = "https://github.com/b-rodrigues/rixpress",
      commit = "HEAD"
    )
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
