# Cronista Example Pipeline
#
# This pipeline demonstrates using cronista (Python chronicler) with rixpress.
# Cronista captures errors as Maybe values (Just/Nothing) instead of failing,
# allowing pipelines to continue even when parts fail.

library(rixpress)

list(
  # ============================================================================
  # Successful computations - these will return Just values
  # ============================================================================
  
  # Step 1: Compute sqrt of 16 - SUCCESS (returns Just(4.0))
  rxp_py(
    name = sqrt_result,
    expr = "r_sqrt(16)",
    user_functions = "functions.py"
  ),

  # Step 2: Filter positive values from a list - SUCCESS
  rxp_py(
    name = filtered_values,
    expr = "filter_positive([3, -1, 4, -2, 5, -3, 6])",
    user_functions = "functions.py"
  ),
  
  # Step 3: Compute mean of filtered values - SUCCESS
  # Note: bind_record extracts value from chronicle before passing to next function
  rxp_py(
    name = mean_result,
    expr = "filtered_values.bind_record(r_mean)",
    user_functions = "functions.py"
  ),
  
  # Step 4: Compute stats - SUCCESS
  rxp_py(
    name = stats_result,
    expr = "filtered_values.bind_record(compute_stats)",
    user_functions = "functions.py"
  ),

  # ============================================================================
  # Intentional failures - these will return Nothing values
  # ============================================================================
  
  # Step 5: sqrt of -1 produces NaN (domain error) -> Nothing
  rxp_py(
    name = sqrt_negative,
    expr = "r_sqrt(-1)",
    user_functions = "functions.py"
  ),

  # Step 6: Division by zero - NOTHING (error captured)
  rxp_py(
    name = div_by_zero,
    expr = "divide_by_zero()",
    user_functions = "functions.py"
  ),
  
  # Step 7: Downstream of Nothing - also becomes Nothing
  # When upstream is Nothing, bind_record propagates Nothing
  rxp_py(
    name = downstream_of_nothing,
    expr = "div_by_zero.bind_record(downstream_calc)",
    user_functions = "functions.py"
  )
) |>
  rxp_populate(build = FALSE)

# Generate DAG for CI visualization  
rxp_dag_for_ci()

cat("\n")
cat("Pipeline generated successfully!\n")
cat("\n")
cat("Expected results:\n")
cat("  - sqrt_result: Just(4.0) - SUCCESS\n")
cat("  - filtered_values: Just([3, 4, 5, 6]) - SUCCESS\n")
cat("  - mean_result: Just(4.5) - SUCCESS\n")
cat("  - stats_result: Just({mean: 4.5, ...}) - SUCCESS\n")
cat("  - sqrt_negative: Nothing - FAILURE (domain error)\n")
cat("  - div_by_zero: Nothing - FAILURE (ZeroDivisionError)\n")
cat("  - downstream_of_nothing: Nothing - FAILURE (upstream Nothing)\n")
cat("\n")
cat("Build with: rixpress::rxp_make()\n")
cat("Check chronicle status: from ryxpress import rxp_check_chronicles\n")
