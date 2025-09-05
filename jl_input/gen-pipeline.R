library(rixpress)

list(
  rxp_jl_file(
    mtcars,
    path = "data/mtcars.csv",
    read_function = "read_csv",
    user_functions = "functions.jl",
    serialize_function = "write_arrow"
  ),

  rxp_r(
    mtcars2,
    select(mtcars, am, cyl, mpg),
    unserialize_function = "read_feather"
  )
) |>
  rxp_populate(build = FALSE)

rxp_dag_for_ci()

#rxp_make()using CSV, DataFrames, Arrow
