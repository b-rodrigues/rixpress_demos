library(rix)

# Define execution environment
rix(
  date = "2025-09-11",
  r_pkgs = c("dplyr"),
  git_pkgs = list(
    package_name = "rixpress",
    repo_url = "https://github.com/ropensci/rixpress",
    commit = "HEAD"
  ),
  py_conf = list(
    py_version = "3.13",
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
