library(rixpress)
library(igraph)

list(
  rxp_r_file(
    name = mtcars,
    path = 'data/mtcars.csv',
    read_function = \(x) (read.csv(file = x, sep = "|"))
  ),

  rxp_r(
    name = filtered_mtcars,
    expr = dplyr::filter(mtcars, am == 1),
    encoder = qs2::qsave
  ),

  rxp_r(
    name = mtcars_mpg,
    expr = dplyr::select(filtered_mtcars, mpg),
    decoder = qs2::qread
  ),

  rxp_r(
    name = mtcars_mpg_head,
    expr = head(mtcars_mpg)
  )
) |>
  rxp_populate(project_path = ".", build = FALSE)

# Plot DAG for CI
rxp_dag_for_ci()
