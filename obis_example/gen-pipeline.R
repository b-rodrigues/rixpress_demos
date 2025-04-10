library(rixpress)
library(igraph)

list(
  rxp_py_file(
    name = gdf,
    path = 'data/oceans.shp',
    read_function = "lambda x: geopandas.read_file(x, driver='ESRI Shapefile')",
    copy_data_folder = TRUE
  ),
  
  rxp_py(
    name = sa,
    py_expr = "gdf.loc[gdf['Oceans'] == 'South Atlantic Ocean']['geometry'].loc[0]"
  ),
  
  rxp_py(
    name = atlantic_py,
    py_expr = "sa.wkt"
  ),
  
  rxp_py2r(
    name = atlantic,
    expr = atlantic_py
  ),
  
  rxp_r(
    name = species,
    expr = set_species(),
    additional_files = "functions.R"
  ),
  
  rxp_r_file(
    name = matches,
    path = 'data/matches.csv',
    read_function = "read.csv"
  ),
  
  rxp_r(
    name = turtles,
    expr = occurrence(species, geometry = atlantic)
  )
  
  #doc = rxp_quarto(
  #  name = page,
  #  qmd_file = "my_doc/page.qmd",
  #  additional_files = c("my_doc/content.qmd", "my_doc/images")
  #)
) |>
  rixpress(project_path = ".")

# Plot DAG for CI
dag_obj <- plot_dag(return_igraph = TRUE)

dag_obj <- set_vertex_attr(dag_obj, "label", value = V(dag_obj)$name)

# Step 2: Delete the "name" attribute
dag_obj <- delete_vertex_attr(dag_obj, "name")

igraph::write_graph(dag_obj, file = "dag.dot", format = "dot")
