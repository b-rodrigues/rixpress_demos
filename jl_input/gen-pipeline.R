library(rixpress)

list(
  rxp_jl_file(
    mtcars,
    path = "data/mtcars.csv",
    read_function = "read_csv",
    user_functions = "functions.jl",
    encoder = "write_arrow"
  ),

  rxp_r(
    mtcars2,
    select(mtcars, am, cyl, mpg),
    decoder = "read_feather"
  )
) |>
  rxp_populate(build = FALSE)

rxp_dag_for_ci()

#rxp_make()using CSV, DataFrames, Arrow
