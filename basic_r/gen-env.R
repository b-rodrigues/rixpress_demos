library(rix)

# Define execution environment
rix(
  date = "2025-04-11",
  r_pkgs = "dplyr",
  git_pkgs = list(
    package_name = "rixpress",
    repo_url = "https://github.com/b-rodrigues/rixpress",
    commit = "HEAD"
  ),
  ide = "rstudio",
  project_path = ".",
  overwrite = TRUE
)
