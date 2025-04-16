library(rixpress)
library(igraph)

d0 <- rxp_py_file(
  name = mtcars_pl,
  path = 'data/mtcars.csv',
  read_function = "lambda x: polars.read_csv(x, separator='|')"
)

d1 <- rxp_py(
  # reticulate doesn't support polars DFs yet, so need to convert
  # first to pandas DF
  name = mtcars_pl_am,
  py_expr = "mtcars_pl.filter(polars.col('am') == 1).to_pandas()"
)

d2 <- rxp_py2r(
  name = mtcars_am,
  expr = mtcars_pl_am
)

d3 <- rxp_r(
  name = mtcars_head,
  expr = my_head(mtcars_am),
  additional_files = "functions.R"
)

d3_1 <- rxp_r2py(
  name = mtcars_head_py,
  expr = mtcars_head
)

d4 <- rxp_py(
  name = mtcars_tail_py,
  py_expr = 'mtcars_head_py.tail()'
)

d4_1 <- rxp_py2r(
  name = mtcars_tail,
  expr = mtcars_tail_py
)

d5 <- rxp_r(
  name = mtcars_mpg,
  expr = dplyr::select(mtcars_tail, mpg)
)

doc <- rxp_quarto(
  name = page,
  qmd_file = "my_doc/page.qmd",
  additional_files = c("my_doc/content.qmd", "my_doc/images"),
  args = "--to typst"
)

rxp_list <- list(d0, d1, d2, d3, d3_1, d4, d4_1, d5, doc)

rixpress(rxp_list, project_path = ".")

# Plot DAG for CI
dag_for_ci()
