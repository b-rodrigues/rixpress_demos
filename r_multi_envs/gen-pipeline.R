library(rixpress)
library(igraph)

d0 <- rxp_r_file(
  mtcars,
  'mtcars.csv',
  \(x) (read.csv(file = x, sep = "|")),
  nix_env = "default.nix"
)
d1 <- rxp_r(mtcars_am, filter(mtcars, am == 1), nix_env = "default2.nix")

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

d4 <- rxp_r(mtcars_mpg, select(mtcars_tail, mpg), nix_env = "default2.nix")

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
