library(rix)

# Define execution environment at the project root level
# This environment will be referenced from subdirectories using relative paths
rix(
  date = "2025-09-11",
  r_pkgs = c("dplyr"),
  py_conf = list(
    py_version = "3.13",
    py_pkgs = c("ryxpress", "biocframe", "rds2py", "pandas")
  ),
  git_pkgs = list(
    package_name = "rixpress",
    repo_url = "https://github.com/ropensci/rixpress",
    commit = "HEAD"
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
