# Master Pipeline Script
#
# This script combines sub-pipelines from the pipelines/ folder
# using rxp_pipeline() to create named, color-coded groups.

library(rixpress)

# =============================================================================
# Source Sub-Pipelines
# =============================================================================

# Each sub-pipeline is defined in a separate file and returns a list of
# derivations. Using source()$value extracts the returned list.

data_prep_derivs <- source("pipelines/01_data_prep.R")$value
analysis_derivs <- source("pipelines/02_analysis.R")$value

# =============================================================================
# Create Named Pipelines with Colors
# =============================================================================

# Wrap each list of derivations in rxp_pipeline() to:
# 1. Give it a name that appears in the DAG legend
# 2. Assign a color for visual distinction

pipe_data_prep <- rxp_pipeline(
  name = "Data Preparation",
  derivs = data_prep_derivs,
  color = "#E69F00"  # Orange
)

pipe_analysis <- rxp_pipeline(
  name = "Statistical Analysis",
  derivs = analysis_derivs,
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
