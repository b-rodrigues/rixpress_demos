library(rix)

# Define execution environment
rix(
  date = "2025-04-11",
  r_pkgs = c("dplyr", "igraph", "qs"),
  git_pkgs = list(
    package_name = "rixpress",
    repo_url = "https://github.com/b-rodrigues/rixpress",
    commit = "HEAD"
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
