library(rixpress)
library(igraph)

list(
  rxp_py_file(
    name = gdf,
    # We need to copy the whole folder to the build sandbox
    # geopandas.read_file needs the path to the shapefile, but other files are required
    # to be in the same folder
    # We thus wrote a function called `read_shp` which is a wrapper around
    # geopandas.read_file, which takes the path to the data folder as an input
    # the function then detects the shapefile and passes it to geopandas.read_file
    path = 'data',
    read_function = "read_shp",
    user_functions = "functions.py"
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
    # The api is down, and thus this derivation does
    # build. But even if it were up, it couldn't be
    # accesses from the build sandbox.
    noop_build = TRUE
  )

  #doc = rxp_qmd(
  #  name = page,
  #  qmd_file = "my_doc/page.qmd",
  #  additional_files = c("my_doc/content.qmd", "my_doc/images")
  #)
) |>
  rxp_populate(
    project_path = ".",
    py_imports = c(geopandas = "import geopandas as gpd")
  )

# This is needed for the function defined in functions.py
add_import("import os", "default.nix")
add_import("import glob", "default.nix")

# Plot DAG for CI
rxp_dag_for_ci()
