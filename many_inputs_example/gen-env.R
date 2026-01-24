library(rix)


rix(
  date = "2025-04-14",
  r_pkgs = c("quarto", "readr", "reticulate"),
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
    py_pkgs = c("polars", "ryxpress", "biocframe", "rds2py", "pandas")
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
