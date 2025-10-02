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
      commit = "949851554bfcd2ae64ae3bf5901ab79ad2106270"
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
