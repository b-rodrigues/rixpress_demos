library(rix)

rix(
  date = "2025-03-31",
  r_pkgs = c("dplyr", "ggplot2", "reticulate", "quarto"),
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
  py_pkgs = list(
    py_version = "3.12",
    py_pkgs = c("numpy", "pillow")
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
