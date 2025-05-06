library(rixpress)
library(igraph)

list(
  rxp_py(
    name = python_example,
    py_expr = "read_first_n_lines_two_files('example.txt', 'another.txt', 10)",
    additional_files = c("functions.py", "example.txt", "another.txt")
  ),

  rxp_r(
    name = r_example,
    expr = read_first_n_lines_two_files('example.txt', 'another.txt', 10),
    additional_files = c("functions.R", "example.txt", "another.txt")
  ),

  rxp_r(
    name = r_head,
    expr = head(r_example)
  )

) |>
  rixpress(project_path = ".", build = FALSE)


# Plot DAG for CI
dag_for_ci()
