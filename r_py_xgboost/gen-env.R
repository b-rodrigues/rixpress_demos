library(rix)

rix(
  date = "2025-04-29",
  r_pkgs = c("ggplot2", "reticulate", "yardstick"),
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
  py_conf = list(
    py_version = "3.13",
    py_pkgs = c("numpy", "xgboost", "scikit-learn")
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
