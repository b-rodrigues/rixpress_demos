library(rixpress)
library(igraph)

d0 <- rxp_py_file(
  name = mtcars_pl,
  path = 'data/mtcars.csv',
  read_function = "lambda x: polars.read_csv(x, separator='|')",
  nix_env = "py-env.nix"
)

d1 <- rxp_py(
# reticulate doesn't support polars DFs yet, so need to convert
# first to pandas DF
  name = mtcars_pl_am,
  py_expr = "mtcars_pl.filter(polars.col('am') == 1).to_pandas()",
  nix_env = "py-env.nix"
)


d2 <- rxp_r(
  mtcars_head,
  my_head(mtcars_am),
  additional_files = "functions.R",
  nix_env = "default.nix"
)

d3 <- rxp_r(
  mtcars_tail,
  my_tail(mtcars_head),
  additional_files = "functions.R",
  nix_env = "default.nix"
)

d4 <- rxp_r(
  mtcars_mpg,
  select(mtcars_tail, mpg),
  nix_env = "default2.nix"
)

doc <- rxp_quarto(
  page,
  "page.qmd",
  additional_files = c("content.qmd", "images"),
  nix_env = "quarto-env.nix"
)

derivs <- list(d0, d1, d2, d3, d4, doc)

rixpress(derivs, project_path = ".")

# Plot DAG for CI
dag_for_ci()
