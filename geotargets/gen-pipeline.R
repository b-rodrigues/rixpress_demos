library(rixpress)

list(
  rxp_r(
    name = example_rast,
    expr = get_example_rast(),
    user_functions = "functions.R"
  ),

  rxp_r(
    name = example_shapefile,
    expr = get_example_shapefile(),
    user_functions = "functions.R"
  ),

  rxp_r(
    name = country_codes,
    expr = country_codes(query = "Australia")
  ),

  rxp_r(
    name = example_gadm,
    expr = get_gadm_country(c("Australia", "New Zealand")),
    user_functions = "functions.R"
  ),

  rxp_r(
    name = example_cgaz_countries,
    expr = cgaz_country("Australia"),
    user_functions = "functions.R"
  )
) |>
  rxp_populate(project_path = ".", build = TRUE)

# Plot DAG for CI
#dag_obj <- plot_dag(return_igraph = TRUE)
#
#dag_obj <- set_vertex_attr(dag_obj, "label", value = V(dag_obj)$name)
#
## Step 2: Delete the "name" attribute
#dag_obj <- delete_vertex_attr(dag_obj, "name")
#
#igraph::write_graph(dag_obj, file = "dag.dot", format = "dot")
