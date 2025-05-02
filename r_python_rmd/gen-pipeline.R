library(rixpress)
library(igraph)

list(
  rxp_py_file(
    name = mtcars_pl,
    path = 'data/mtcars.csv',
    read_function = "lambda x: polars.read_csv(x, separator='|')"
  ),

  rxp_py(
    # reticulate doesn't support polars DFs yet, so need to convert
    # first to pandas DF
    name = mtcars_pl_am,
    py_expr = "mtcars_pl.filter(polars.col('am') == 1).to_pandas()"
  ),

  rxp_py2r(
    name = mtcars_am,
    expr = mtcars_pl_am
  ),

  rxp_r(
    name = mtcars_head,
    expr = my_head(mtcars_am),
    additional_files = "functions.R"
  ),

  rxp_r2py(
    name = mtcars_head_py,
    expr = mtcars_head
  ),

  rxp_py(
    name = mtcars_tail_py,
    py_expr = 'mtcars_head_py.tail()'
  ),

  rxp_py2r(
    name = mtcars_tail,
    expr = mtcars_tail_py
  ),

  rxp_r(
    name = mtcars_mpg,
    expr = dplyr::select(mtcars_tail, mpg)
  ),

  rxp_rmd(
    name = page,
    rmd_file = "my_doc/page.rmd",
    additional_files = "my_doc/images"
  )
) |>
  rixpress(project_path = ".")


# Plot DAG for CI
dag_for_ci()
