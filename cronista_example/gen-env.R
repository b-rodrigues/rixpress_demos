library(rix)

# Define execution environment with cronista for Python Maybe pattern pipelines
rix(
  date = "2026-01-19",
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
      ),
      list(
        package_name = "cronista",
        repo_url = "https://github.com/b-rodrigues/cronista",
        commit = "HEAD"
      ),
      list(
        package_name = "talvez",
        repo_url = "https://github.com/b-rodrigues/talvez",
        commit = "HEAD"
      )
    )
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
