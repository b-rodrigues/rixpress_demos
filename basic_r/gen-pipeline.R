library(rixpress)

list(
  rxp_r_file(
    name = mtcars,
    path = 'data/mtcars.csv',
    read_function = \(x) (read.csv(file = x, sep = "|"))
  ),

  rxp_r(
    name = filtered_mtcars,
    expr = dplyr::filter(mtcars, am == 1)
  ),

  rxp_r(
    name = mtcars_mpg,
    expr = dplyr::select(filtered_mtcars, mpg)
  )
) |>
  rixpress(project_path = ".")
