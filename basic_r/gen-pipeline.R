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
    expr = dplyr::filter(mtcars, am == 1)
  ),

  rxp_r(
    name = mtcars_mpg,
    expr = dplyr::select(filtered_mtcars, mpg)
  )
) |>
  rixpress(project_path = ".", build = FALSE)

# Plot DAG for CI
dag_obj <- plot_dag(return_igraph = TRUE)

dag_obj <- set_vertex_attr(dag_obj, "label", value = V(dag_obj)$name)

# Step 2: Delete the "name" attribute
dag_obj <- delete_vertex_attr(dag_obj, "name")

igraph::write_graph(dag_obj, file = "dag.dot", format = "dot")
