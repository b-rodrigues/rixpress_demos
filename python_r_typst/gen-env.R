library(rix)

rix(
  date = "2025-04-14",
  r_pkgs = c("chronicler", "dplyr", "igraph", "reticulate", "quarto"),
  system_pkgs = "typst",
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
  py_conf = list(
    py_version = "3.12",
    py_pkgs = c("pandas", "polars", "pyarrow")
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
