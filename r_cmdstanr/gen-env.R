library(rix)

rix(
  date = "2025-04-29",
  r_pkgs = c("readr", "dplyr", "ggplot2", "brms", "quarto"),
  system_pkgs = "cmdstan",
  git_pkgs = list(
    list(
      package_name = "cmdstanr",
      repo_url = "https://github.com/stan-dev/cmdstanr",
      commit = "79d37792d8e4ffcf3cf721b8d7ee4316a1234b0c"
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
