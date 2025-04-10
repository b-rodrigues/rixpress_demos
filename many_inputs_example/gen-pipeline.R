library(rixpress)

list(
  rxp_r_file(
    name = mtcars_parts,
    path = 'data',
    read_function = \(x)(readr::read_delim(list.files(x, full.names = TRUE), delim = '|')),
    copy_data_folder = TRUE
  )
) |>
  rixpress(project_path = ".")
