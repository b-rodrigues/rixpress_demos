library(rixpress)
library(igraph)

list(
  rxp_py_file(
    name = mtcars_pl,
    path = "data/mtcars.csv",
    read_function = "lambda x: polars.read_csv(x, separator='|')"
  ),

  rxp_py(
    name = mtcars_pl_am,
    expr = "mtcars_pl.filter(polars.col('am') == 1)",
    user_functions = "functions.py",
    encoder = "serialize_to_json",
  ),

  rxp_r(
    name = mtcars_head,
    expr = my_head(mtcars_pl_am),
    user_functions = "functions.R",
    decoder = "jsonlite::fromJSON"
  ),

  rxp_r(
    name = mtcars_mpg,
    expr = dplyr::select(mtcars_head, mpg)
  )
) |>
  rxp_populate(project_path = ".", build = FALSE)


# Plot DAG for CI
rxp_dag_for_ci()
