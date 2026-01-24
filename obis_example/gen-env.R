library(rix)

rix(
  date = "2025-03-31",
  r_pkgs = c("robis", "ggplot2", "dplyr", "igraph", "reticulate", "quarto"),
  git_pkgs = list(
    list(
      package_name = "obistools",
      repo_url = "https://github.com/iobis/obistools/",
      commit = "9df1c36fbae597d0b129649f7dcab17770a866be"
    ),
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
    py_pkgs = c("geopandas", "fiona", "pandas", "folium", "ryxpress", "biocframe", "rds2py")
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
