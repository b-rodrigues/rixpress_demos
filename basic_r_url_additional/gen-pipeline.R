library(rixpress)
library(igraph)

list(
  rxp_r_file(
    name = mtcars,
    path = 'https://raw.githubusercontent.com/b-rodrigues/rixpress_demos/refs/heads/master/basic_r/data/mtcars.csv',
    read_function = "read_tsv",
    user_functions = "functions.R"
  ),

  rxp_r(
    name = filtered_mtcars,
    expr = dplyr::filter(mtcars, am == 1)
  ),

  rxp_r(
    name = mtcars_mpg,
    expr = dplyr::select(filtered_mtcars, mpg)
  )
) |>
  rxp_populate(project_path = ".", build = FALSE)

# Plot DAG for CI
rxp_dag_for_ci()
