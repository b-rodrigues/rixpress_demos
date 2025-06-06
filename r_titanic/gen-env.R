library(rix)

rix(
  date = "2025-04-29",
  r_pkgs = c(
    "dplyr",
    "data.table",
    "ggplot2",
    "scales",
    "readr",
    "rlang"
  ),
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
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
