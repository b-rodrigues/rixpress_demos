library(rixpress)

list(
  rxp_r_file(
    name = mtcars_r,
    path = 'data',
    read_function = \(x)
      (readr::read_delim(list.files(x, full.names = TRUE), delim = '|')),
    copy_data_folder = TRUE
  ),
  rxp_py_file(
    name = mtcars_py,
    path = 'data',
    read_function = "read_many_csvs",
    copy_data_folder = TRUE
  ),
  rxp_py(
    name = head_mtcars,
    py_expr = "mtcars_py.head()",
    additional_files = "functions.py"
  )
) |>
  rixpress(project_path = ".")
