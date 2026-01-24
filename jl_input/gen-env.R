library(rix)

rix(
  date = "2025-09-04",
  r_pkgs = c(
    "dplyr",
    "arrow"
  ),
  py_conf = list(
    py_version = "3.13",
    py_pkgs = c("ryxpress", "biocframe", "rds2py", "pandas")
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
  jl_conf = list(
    jl_version = "1.10",
    jl_pkgs = c("Arrow", "CSV", "DataFrames")
  ),
  project_path = ".",
  overwrite = TRUE
)
