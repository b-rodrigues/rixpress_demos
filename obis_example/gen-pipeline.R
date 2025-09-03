library(rixpress)
library(igraph)

list(
  rxp_py_file(
    name = gdf,
    # We need to copy the whole folder to the build sandbox
    # even though only path to the shapefile needs to be provided to geopandas.read_file
    # all the other files need to be present
    # we need to provide an anonymous function but with a hardcoded path
    path = 'data',
    read_function = "lambda x: geopandas.read_file(input_folder/data/oceans.shp, driver='ESRI Shapefile')"
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
    user_functions = "functions.R"
  ),

  rxp_r_file(
    name = matches,
    path = 'data/matches.csv',
    read_function = "read.csv"
  ),

  rxp_r(
    name = turtles,
    expr = occurrence(species, geometry = atlantic),
    noop_build = TRUE
  )

  #doc = rxp_qmd(
  #  name = page,
  #  qmd_file = "my_doc/page.qmd",
  #  additional_files = c("my_doc/content.qmd", "my_doc/images")
  #)
) |>
  rxp_populate(project_path = ".")

# Plot DAG for CI
rxp_dag_for_ci()
