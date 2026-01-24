# Analysis Sub-Pipeline
#
# This script defines the analysis phase of the pipeline.
# It depends on outputs from the data preparation sub-pipeline.

library(rixpress)

list(
  # Compute summary statistics
  rxp_r(
    name = summary_stats,
    expr = summary(selected_mtcars)
  ),

  # Compute mean mpg by cylinder count
  rxp_r(
    name = mpg_by_cyl,
    expr = dplyr::group_by(selected_mtcars, cyl) |>
      dplyr::summarise(mean_mpg = mean(mpg), .groups = "drop")
  ),

  # Create a simple linear model
  rxp_r(
    name = mpg_model,
    expr = lm(mpg ~ hp + wt, data = selected_mtcars)
  ),

  # Extract model coefficients
  rxp_r(
    name = model_coefs,
    expr = coef(mpg_model)
  )
)
