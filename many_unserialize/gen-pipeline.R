library(rixpress)
library(igraph)

d0 <- rxp_r_file(
  mtcars,
  'mtcars.csv',
  \(x) (read.csv(file = x, sep = "|")),
  nix_env = "default.nix"
)
d1 <- rxp_r(
  mtcars_am,
  filter(mtcars, TRUE),
  nix_env = "default2.nix"
)

d2 <- rxp_r(
  mtcars_head,
  my_head(mtcars_am, 100),
  user_functions = "my_head.R",
  nix_env = "default.nix",
  serialize_function = write.csv
)

d3 <- rxp_r(
  mtcars_tail,
  my_tail(mtcars_head),
  user_functions = "my_tail.R",
  nix_env = "default2.nix",
  serialize_function = qs::qsave,
  unserialize_function = read.csv
)

d4 <- rxp_r(
  mtcars_mpg,
  full_join(mtcars_tail, mtcars_head),
  nix_env = "default2.nix",
  unserialize_function = c(mtcars_tail = "qs::qread", mtcars_head = "read.csv")
)

derivs <- list(d0, d1, d2, d3, d4)

rxp_populate(derivs, project_path = ".", build = FALSE)

rxp_make(verbose = 0)
