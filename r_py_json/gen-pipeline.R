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
    py_expr = "mtcars_pl.filter(polars.col('am') == 1)",
    additional_files = "functions.py",
    serialize_function = "serialize_to_json",
  ),

  rxp_r(
    name = mtcars_head,
    expr = my_head(mtcars_pl_am),
    additional_files = "functions.R",
    unserialize_function = "jsonlite::fromJSON"
  ),

  rxp_r(
    name = mtcars_mpg,
    expr = dplyr::select(mtcars_head, mpg)
  )
) |>
  rixpress(project_path = ".", build = FALSE)


# Plot DAG for CI
dag_for_ci()
