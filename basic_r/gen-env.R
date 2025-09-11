library(rix)

# Define execution environment
rix(
  date = "2025-09-11",
  r_pkgs = c("dplyr", "igraph"),
  py_conf = list(
    py_version = "3.13",
    py_pkgs = c("ryxpress", "biocframe", "rds2py", "pandas")
  ),
  git_pkgs = list(
    package_name = "rixpress",
    repo_url = "https://github.com/b-rodrigues/rixpress",
    commit = "HEAD"
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
