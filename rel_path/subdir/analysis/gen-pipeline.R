# Pipeline definition using a relative path to reach the parent's default.nix
#
# This script is located at: rel_path/subdir/analysis/gen-pipeline.R
# The Nix environment is at: rel_path/default.nix
# So we use "../../default.nix" to reference it.

library(rixpress)

list(
  # First derivation using relative path to parent's default.nix
  rxp_r(
    name = mtcars_am,
    expr = dplyr::filter(mtcars, am == 1),
    nix_env = "../../default.nix"  # Relative path to parent directory
  ),

  # Second derivation, also using the same relative path
  rxp_r(
    name = mtcars_head,
    expr = head(mtcars_am, 3),
    nix_env = "../../default.nix"
  ),

  # Third derivation computing summary statistics
  rxp_r(
    name = mtcars_summary,
    expr = summary(mtcars_head),
    nix_env = "../../default.nix"
  )
) |>
  rxp_populate(project_path = ".", build = FALSE)

# Print success message
cat("\nPipeline generated successfully!\n")
cat("The relative path '../../default.nix' was correctly handled.\n")
cat("Check pipeline.nix to see that 'defaultBuildInputs' and 'defaultConfigurePhase'\n")
cat("are used (not '______defaultBuildInputs' etc.)\n\n")
cat("To build the pipeline, run: rixpress::rxp_make()\n")
