library(rixpress)

list(
  rxp_r_file(
    bayesian_linear_regression_model,
    "model.stan",
    readLines
  ),
  rxp_r(
    parameters,
    list(
      N = 100,
      alpha = 2,
      beta = -0.5,
      sigma = 1.e-1
    )
  ),
  rxp_r(
    x,
    rnorm(parameters$N, 0, 1)
  ),
  rxp_r(
    y,
    rnorm(
      n = parameters$N,
      mean = parameters$alpha + parameters$beta * x,
      sd = parameters$sigma
    )
  ),
  rxp_r(
    inputs,
    list(N = parameters$N, x = x, y = y)
  ),
  rxp_r(
    model,
    cmdstan_model_wrapper(
      stan_string = bayesian_linear_regression_model,
      inputs = inputs,
      seed = 22
    ),
    additional_files = "functions.R",
    serialize_function = "save_model",
    env_var = c("CMDSTAN" = "${defaultPkgs.cmdstan}/opt/cmdstan")
  )
) |>
  rixpress(build = FALSE)

# Plot DAG for CI
rxp_dag_for_ci()
