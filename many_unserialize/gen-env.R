library(rix)

# Environment to run some derivations
rix(
  date = "2025-08-25",
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
  r_pkgs = c("dplyr", "qs"),
  py_conf = list(
    py_version = "3.13",
    py_pkgs = c("ryxpress", "biocframe", "rds2py", "pandas")
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)

file.rename("default.nix", "default2.nix")

rix(
  date = "2025-08-25",
  r_pkgs = "readr",
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
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
