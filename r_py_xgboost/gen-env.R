library(rix)

rix(
  date = "2025-04-29",
  r_pkgs = c(
    "dplyr",
    "ggplot2",
    "reticulate",
    "yardstick"
  ),
  git_pkgs = list(
    list(
      package_name = "rix",
      repo_url = "https://github.com/ropensci/rix/",
      commit = "HEAD"
    ),
    list(
      package_name = "rixpress",
      repo_url = "https://github.com/ropensci/rixpress",
      commit = "HEAD"
    )
  ),
  py_conf = list(
    py_version = "3.13",
    py_pkgs = c(
      "numpy",
      "pandas",
      "scikit-learn",
      "xgboost"
    ),
    git_pkgs = list(
      list(
        package_name = "ryxpress",
        repo_url = "https://github.com/b-rodrigues/ryxpress",
        commit = "HEAD"
      )
    )
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
