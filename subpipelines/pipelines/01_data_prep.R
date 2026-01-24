# Data Preparation Sub-Pipeline
#
# This script defines the data preparation phase of the pipeline.
# It returns a list of derivations that can be combined with other sub-pipelines.

library(rixpress)

list(
  # Load the raw data
  rxp_r(
    name = raw_mtcars,
    expr = mtcars
  ),

  # Filter to automatic transmission cars only
  rxp_r(
    name = clean_mtcars,
    expr = dplyr::filter(raw_mtcars, am == 1)
  ),

  # Select relevant columns
  rxp_r(
    name = selected_mtcars,
    expr = dplyr::select(clean_mtcars, mpg, cyl, hp, wt)
  )
)
