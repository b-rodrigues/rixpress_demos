cmdstan_model_wrapper <- function(
  model_stan_path,
  inputs,
  seed,
  ...
) {
  model <- cmdstanr::cmdstan_model(
    stan_file = model_stan_path,
    ...
  )

  model$sample(data = inputs, seed = 22)
}


save_model <- function(fitted_model, path, ...) {
  fitted_model$save_object(path, ...)
}
