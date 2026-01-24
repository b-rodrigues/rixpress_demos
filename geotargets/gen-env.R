library(rix)

# Define execution environment
rix(
  date = "2026-01-19",
  r_pkgs = c(
    "arrow",
    "codetools",
    "conflicted",
    "countrycode",
    "dotenv",
    "dplyr",
    "geoarrow",
    "geodata",
    "terra",
    "wk",
    "quarto"
  ),
  git_pkgs = list(
    list(
      package_name = "rixpress",
      repo_url = "https://github.com/ropensci/rixpress",
      commit = "HEAD"
    ),
    list(
      package_name = "sds",
      repo_url = "https://github.com/hypertidy/sds",
      commit = "aebd9f49fcec72b0767cb3328dae665125ac5860"
    ),
    list(
      package_name = "dsn",
      repo_url = "https://github.com/hypertidy/dsn",
      commit = "15743da3a6c892f6654a3deab707425f86cabe98"
    )
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
