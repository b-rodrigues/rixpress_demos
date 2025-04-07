library(rixpress)
library(igraph)

d0 <- rxp_py_file(
  name = gorilla_pixels,
  path = 'md_source/gorilla/gorilla-waving-cartoon-black-white-outline-clipart-914.jpg',
  read_function = "read_image"
)

d1 <- rxp_py(
  name = threshold_level,
  py_expr = "50"
)

d2 <- rxp_py(
  name = py_coords,
  py_expr = "numpy.column_stack(numpy.where(gorilla_pixels < threshold_level))",
  additional_files = "functions.py"
)

d3 <- rxp_py2r(
  name = raw_coords,
  expr = py_coords
)

d4 <- rxp_r(
  name = coords,
  expr = clean_coords(raw_coords),
  additional_files = "functions.R"
)

d5 <- rxp_r(
  name = gender_dist,
  expr = gender_distribution(raw_coords),
  additional_files = "functions.R"
)

d6 <- rxp_r(
  name = plot1,
  expr = make_plot1(raw_coords),
  additional_files = "functions.R"
)

d7 <- rxp_r(
  name = plot2,
  expr = make_plot2(raw_coords),
  additional_files = "functions.R"
)

doc <- rxp_quarto(
  name = page,
  qmd_file = "md_source/source.qmd",
  additional_files = c("md_source/gorilla")
)

rxp_list <- list(d0, d1, d2, d3, d4, d5, d6, d7, doc)

rixpress(rxp_list, project_path = ".")

# Plot DAG for CI
dag_obj <- plot_dag(return_igraph = TRUE)

dag_obj <- set_vertex_attr(dag_obj, "label", value = V(dag_obj)$name)

# Step 2: Delete the "name" attribute
dag_obj <- delete_vertex_attr(dag_obj, "name")

igraph::write_graph(dag_obj, file = "dag.dot", format = "dot")
