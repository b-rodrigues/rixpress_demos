cmdstan_model_wrapper <- function(
  stan_string = NULL,
  inputs,
  seed,
  ...
) {
  stan_file <- tempfile(pattern = "model_", fileext = ".stan")

  writeLines(stan_string, con = stan_file)

  model <- cmdstanr::cmdstan_model(
    stan_file = stan_file,
    ...
  )

  model$sample(data = inputs, seed = 22)
}


save_model <- function(fitted_model, path, ...) {
  fitted_model$save_object(path, ...)
}
