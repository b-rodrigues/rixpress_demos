# Master Pipeline Script
#
# This script combines sub-pipelines from the pipelines/ folder
# using rxp_pipeline() to create named, color-coded groups.

library(rixpress)

# =============================================================================
# Create Named Pipelines with Colors
# =============================================================================

# Pass the path to the sub-pipeline scripts directly to rxp_pipeline()
# This avoids needing to manually source() the files.

pipe_data_prep <- rxp_pipeline(
  name = "Data Preparation",
  path = "pipelines/01_data_prep.R",
  color = "#E69F00"  # Orange
)

pipe_analysis <- rxp_pipeline(
  name = "Statistical Analysis",
  path = "pipelines/02_analysis.R",
  color = "#56B4E9"  # Blue
)

# =============================================================================
# Build the Combined Pipeline
# =============================================================================

# Pass the list of pipelines to rxp_populate()
# The pipelines are automatically flattened while preserving metadata

rxp_populate(
  list(pipe_data_prep, pipe_analysis),
  project_path = ".",
  build = FALSE
)

# Generate DAG for CI visualization
rxp_dag_for_ci()

# =============================================================================
# Print Summary
# =============================================================================

cat("\n")
cat("Pipeline generated successfully!\n")
cat("\n")
cat("Sub-pipelines:\n")
cat("  - Data Preparation (orange): 3 derivations\n")
cat("  - Statistical Analysis (blue): 4 derivations\n")
cat("\n")
cat("To build: rixpress::rxp_make()\n")
cat("To visualize: rixpress::rxp_visnetwork()  # Shows colored nodes by pipeline\n")
cat("              rixpress::rxp_visnetwork(color_by = 'type')  # Original type coloring\n")
