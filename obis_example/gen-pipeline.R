library(rixpress)
library(igraph)

list(
  rxp_py_file(
    name = gdf,
    path = 'data/oceans.shp',
    read_function = "lambda x: geopandas.read_file(x, driver='ESRI Shapefile')",
    copy_data_folder = TRUE # to read in oceans.shp, other files, included in data/ need to
    # accessible to the build sandbox
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

  #doc = rxp_qmd(
  #  name = page,
  #  qmd_file = "my_doc/page.qmd",
  #  additional_files = c("my_doc/content.qmd", "my_doc/images")
  #)
) |>
  rxp_populate(project_path = ".", build = TRUE)

# Plot DAG for CI
rxp_dag_for_ci()
