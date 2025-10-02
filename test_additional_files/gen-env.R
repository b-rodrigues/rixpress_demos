library(rix)

rix(
  date = "2025-05-05",
  r_pkgs = "dplyr",
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
    py_version = "3.12",
    py_pkgs = "polars"
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
