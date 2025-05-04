cmdstan_model_wrapper <- function(
  stan_string = NULL,
  ...
) {
  stan_file <- tempfile(pattern = "model_", fileext = ".stan")

  writeLines(stan_string, con = stan_file)

  cmdstanr::cmdstan_model(
    stan_file = stan_file,
    ...
  )
}
