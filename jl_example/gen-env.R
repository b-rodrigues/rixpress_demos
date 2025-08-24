library(rix)

rix(
  date = "2025-08-11",
  r_pkgs = c(
    "arrow",
    "dplyr",
    "ggplot2",
    "hexbin",
    "quarto",
    "tidyr",
    "visNetwork"
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
    jl_version = "1.11",
    jl_pkgs = c(
      "Arrow",
      "DataFrames",
      "SparseArrays",
      "LinearAlgebra",
      "Tidier"
    )
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
