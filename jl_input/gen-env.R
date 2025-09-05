library(rix)

rix(
  date = "2025-09-04",
  r_pkgs = c(
    "dplyr",
    "arrow"
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
  jl_conf = list(
    jl_version = "1.10",
    jl_pkgs = c("Arrow", "CSV", "DataFrames")
  ),
  project_path = ".",
  overwrite = TRUE
)
