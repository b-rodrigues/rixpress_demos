library(rix)

# Define execution environment with chronicler for monadic pipelines
rix(
  date = "2026-01-19",
  r_pkgs = c("dplyr", "chronicler"),
  git_pkgs = list(
    package_name = "rixpress",
    repo_url = "https://github.com/ropensci/rixpress",
    commit = "HEAD"
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
