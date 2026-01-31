library(rixpress)
library(chronicler)

# Create recorded (decorated) versions of functions
# These functions capture errors and warnings instead of failing
r_filter <- record(dplyr::filter)
r_select <- record(dplyr::select)
r_sqrt <- record(sqrt)
r_mean <- record(mean)

list(
  # Step 1: Read CSV file (standard rxp_r_file, no chronicler)
  rxp_r_file(
    name = mtcars,
    path = "data/mtcars.csv",
    read_function = \(x) (read.csv(file = x, sep = "|"))
  ),

  # Step 2: Filter using chronicler - this will SUCCEED
  # The result is a chronicle object with Just(value) and a log
  rxp_r(
    name = filtered_mtcars,
    expr = mtcars |> r_filter(am == 1)
  ),

  # Step 3: Select using chronicler - chains from previous chronicle
  # Uses bind_record to chain chronicle operations
  rxp_r(
    name = mtcars_mpg,
    expr = filtered_mtcars |> bind_record(r_select, mpg)
  ),

  # Step 4: Compute mean of mpg - should SUCCEED
  rxp_r(
    name = mean_mpg,
    expr = mtcars_mpg |>
      bind_record(\(df) r_mean(df$mpg))
  ),

  # Step 5: Intentionally cause a WARNING that becomes Nothing

  # sqrt of negative number produces NaN with warning
  # chronicler (with default strict=2) catches warnings and returns Nothing
  rxp_r(
    name = sqrt_of_negative,
    expr = r_sqrt(-1)
  ),

  # Step 6: Downstream of Nothing - will also be Nothing
  # When upstream is Nothing, the computation propagates Nothing
  rxp_r(
    name = downstream_of_nothing,
    expr = sqrt_of_negative |> bind_record(\(x) r_mean(x))
  )
) |>
  rxp_populate(project_path = ".", build = FALSE)

# After building with rxp_make(), you can check for Nothing values:
# rxp_check_chronicles()
#
# Expected output:
# Chronicle status:
# ✓ filtered_mtcars (chronicle: OK)
# ✓ mtcars_mpg (chronicle: OK)
# ✓ mean_mpg (chronicle: OK)
# ✗ sqrt_of_negative (chronicle: NOTHING)
#     Failed: sqrt
#     Message: NaNs produced
# ✗ downstream_of_nothing (chronicle: NOTHING)
#     Failed: (anonymous)
#     Message: Pipeline failed upstream
#
# Summary: 3 success, 0 with warnings, 2 nothing
# Warning: 2 derivation(s) contain Nothing values!
