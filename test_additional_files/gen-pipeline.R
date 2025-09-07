library(rixpress)
library(igraph)

list(
  rxp_py(
    name = python_example,
    expr = "read_first_n_lines_two_files('example.txt', 'another.txt', 10)",
    additional_files = c("example.txt", "another.txt"),
    user_functions = "functions.py"

  ),

  rxp_r(
    name = r_example,
    expr = read_first_n_lines_two_files('example.txt', 'another.txt', 10),
    additional_files = c("example.txt", "another.txt"),
    user_functions = "functions.R"
  ),

  rxp_r(
    name = r_head,
    expr = head(r_example)
  )
) |>
  rxp_populate(project_path = ".", build = FALSE)


# Plot DAG for CI
rxp_dag_for_ci()
