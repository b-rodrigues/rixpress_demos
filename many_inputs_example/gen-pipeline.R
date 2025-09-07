library(rixpress)

list(
  rxp_r_file(
    name = mtcars_r,
    path = 'data',
    read_function = \(x) {
      (readr::read_delim(list.files(x, full.names = TRUE), delim = '|'))
    }
  ),
  rxp_py_file(
    name = mtcars_py,
    path = 'data',
    read_function = "read_many_csvs",
    user_functions = "functions.py"
  ),
  rxp_py(
    name = head_mtcars,
    expr = "mtcars_py.head()",
    user_functions = "functions.py"
  )
) |>
  rxp_populate(project_path = ".", build = TRUE)
