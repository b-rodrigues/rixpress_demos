library(rix)

# Define execution environment
rix(
  date = "2026-01-19",
  r_pkgs = c("dplyr", "igraph"),
  py_conf = list(
    py_version = "3.13",
    py_pkgs = c("biocframe", "rds2py", "pandas"),
    git_pkgs = list(
      list(
        package_name = "ryxpress",
        repo_url = "https://github.com/b-rodrigues/ryxpress",
        commit = "HEAD"
      )
    )
  ),
  git_pkgs = list(
    package_name = "rixpress",
    repo_url = "https://github.com/ropensci/rixpress",
    commit = "HEAD"
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
