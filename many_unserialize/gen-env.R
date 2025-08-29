library(rix)

# Environment to run some derivations
rix(
  date = "2025-08-25",
  r_pkgs = c("dplyr", "qs"),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)

file.rename("default.nix", "default2.nix")

rix(
  date = "2025-08-25",
  r_pkgs = "readr",
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
