library(rix)

# Define execution environment
rix(
  date = "2025-09-11",
  r_pkgs = c("dplyr"),
  git_pkgs = list(
    package_name = "rixpress",
    repo_url = "https://github.com/ropensci/rixpress",
    commit = "HEAD"
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
