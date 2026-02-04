library(rix)

rix(
  date = "2026-02-02",
  r_pkgs = c("chronicler", "dplyr", "igraph", "reticulate", "quarto"),
  git_pkgs = list(
    list(
      package_name = "rix",
      repo_url = "https://github.com/ropensci/rix/",
      commit = "HEAD"
    ),
    list(
      package_name = "rixpress",
      repo_url = "https://github.com/ropensci/rixpress",
      commit = "e06f98488c151ae1060b837cfdfe73ab75395800"
    )
  ),
  py_conf = list(
    py_version = "3.12",
    py_pkgs = c("pandas", "polars", "pyarrow", "numpy"),
    git_pkgs = list(
      list(
        package_name = "ryxpress",
        repo_url = "https://github.com/b-rodrigues/ryxpress",
        commit = "HEAD"
      )
    )
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
