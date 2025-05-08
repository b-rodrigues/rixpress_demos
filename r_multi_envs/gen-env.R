library(rix)

# Environment to run some derivations
rix(
  date = "2025-03-31",
  py_conf = list(
    "py_version" = "3.12",
    "py_pkgs" = c("pandas", "polars", "pyarrow")
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)

file.rename("default.nix", "py-env.nix")

rix(
  date = "2025-03-31",
  r_pkgs = c("dplyr"),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)

file.rename("default.nix", "default2.nix")

# Environment to compile Quarto
rix(
  date = "2025-03-31",
  r_pkgs = c("quarto", "chronicler"),
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
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)

file.rename("default.nix", "quarto-env.nix")

# Main environment to run the pipeline
rix(
  date = "2025-03-31",
  r_pkgs = c("igraph", "reticulate"),
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
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
