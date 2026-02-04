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
    expr = "mtcars_pl.filter(polars.col('am') == 1).to_pandas()"
  ),

  rxp_py2r(
    name = mtcars_am,
    expr = mtcars_pl_am
  ),

  rxp_r(
    name = mtcars_head,
    expr = my_head(mtcars_am),
    user_functions = "functions.R"
  ),

  rxp_r2py(
    name = mtcars_head_py,
    expr = mtcars_head
  ),

  rxp_py(
    name = mtcars_tail_py,
    expr = 'mtcars_head_py.tail()'
  ),

  rxp_py2r(
    name = mtcars_tail,
    expr = mtcars_tail_py
  ),

  rxp_r(
    name = mtcars_mpg,
    expr = dplyr::select(mtcars_tail, mpg)
  ),

  rxp_qmd(
    name = page,
    qmd_file = "my_doc/page.qmd",
    additional_files = c("my_doc/content.qmd", "my_doc/images")
  )
) |>
  rxp_populate(project_path = ".", build = FALSE, verbose = 2)

# Plot DAG for CI
rxp_dag_for_ci()
