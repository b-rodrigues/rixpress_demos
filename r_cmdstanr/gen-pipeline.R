library(rixpress)

list(
  rxp_r(
    bayesian_linear_regression_model,
    '
data {
  int<lower=1> N;
  vector[N] x;
  vector[N] y;
}
parameters {
  real alpha;
  real beta;
  real<lower=0> sigma;
}
model {
  // Priors
  alpha ~ normal(0, 5);
  beta  ~ normal(0, 5);
  sigma ~ inv_gamma(1, 1);

  // Likelihood
  y ~ normal(alpha + beta * x, sigma);
}
'
  ),
  rxp_r(
    model,
    cmdstan_model_wrapper(bayesian_linear_regression_model, compile = FALSE),
    additional_files = "functions.R"
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
    fit,
    model$compile$sample(data = inputs, seed = 22)
  )
) |>
  rixpress()
