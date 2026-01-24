library(rix)

rix(
  date = "2026-01-19",
  r_pkgs = c("dplyr", "ggplot2", "reticulate", "quarto"),
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
    py_pkgs = c("ryxpress", "numpy", "pillow", "biocframe", "rds2py", "pandas")
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
