library(rixpress)
library(igraph)

d0 <- rxp_py(
  name = gdf,
  py_expr = "geopandas.read_file('data/oceans.shp', driver='ESRI Shapefile')",
  additional_files = c("data/oceans.shp", "data/oceans.shx", "data/oceans.dbf", "data/oceans.prj")
)

d1 <- rxp_py(
  name = sa,
  py_expr = "gdf.loc[gdf['Oceans'] == 'South Atlantic Ocean']['geometry'].loc[0]"
)

d2 <- rxp_py(
  name = atlantic,
  py_expr = "sa.wkt"
)

d3 <- rxp_r(
  name = species,
  expr = set_species(),
  additional_files = "functions.R"
)

d4 <- rxp_r_file(
  name = matches,
  path = 'data/matches.csv',
  read_function = "read.csv"
)


#doc <- rxp_quarto(
#  name = page,
#  qmd_file = "my_doc/page.qmd",
#  additional_files = c("my_doc/content.qmd", "my_doc/images")
#)

rxp_list <- list(d0, d1, d2, d3, d4)

rixpress(rxp_list, project_path = ".")

# Plot DAG for CI
dag_obj <- plot_dag(return_igraph = TRUE)

dag_obj <- set_vertex_attr(dag_obj, "label", value = V(dag_obj)$name)

# Step 2: Delete the "name" attribute
dag_obj <- delete_vertex_attr(dag_obj, "name")

igraph::write_graph(dag_obj, file = "dag.dot", format = "dot")
