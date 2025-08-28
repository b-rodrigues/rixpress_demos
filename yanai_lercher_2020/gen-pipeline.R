library(rixpress)
library(igraph)

d0 <- rxp_py_file(
  name = gorilla_pixels,
  path = 'md_source/gorilla/gorilla-waving-cartoon-black-white-outline-clipart-914.jpg',
  read_function = "read_image",
  user_functions = "functions.py"
)

d1 <- rxp_py(
  name = threshold_level,
  py_expr = "50"
)

d2 <- rxp_py(
  name = py_coords,
  py_expr = "numpy.column_stack(numpy.where(gorilla_pixels < threshold_level))",
  user_functions = "functions.py"
)

d3 <- rxp_py2r(
  name = raw_coords,
  expr = py_coords
)

d4 <- rxp_r(
  name = coords,
  expr = clean_coords(raw_coords),
  user_functions = "functions.R"
)

d5 <- rxp_r(
  name = gender_dist,
  expr = gender_distribution(coords),
  user_functions = "functions.R"
)

d6 <- rxp_r(
  name = plot1,
  expr = make_plot1(coords),
  user_functions = "functions.R"
)

d7 <- rxp_r(
  name = plot2,
  expr = make_plot2(coords),
  user_functions = "functions.R"
)

doc <- rxp_qmd(
  name = doc,
  qmd_file = "md_source/source.qmd",
  additional_files = c("md_source/gorilla")
)

rxp_list <- list(d0, d1, d2, d3, d4, d5, d6, d7, doc)

# Set build to FALSE, because I need to adjust imports
rxp_populate(
  rxp_list,
  project_path = ".", build = FALSE,
  py_imports = c(pillow = "from PIL import Image")
)

# Plot DAG for CI
rxp_dag_for_ci()
