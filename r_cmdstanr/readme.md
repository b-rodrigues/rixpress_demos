# Using cmdstanr with rixpress

`{cmdstanr}` is a package that simplifies the process of defining and 
estimating the parameters of bayesian statistical models using `stan`.

It is only available on GitHub, and is actually a high-level interface
to a command-line tool called `cmdstan`. The way `cmdstan` and `{cmdstanr}`
work can make it tricky to use with `{rixpress}`, so this example
will illustrate how to use it.

The first step is of course to define the execution environment of the 
pipeline, as usual:

```r
library(rix)

rix(
  date = "2025-04-29",
  r_pkgs = c("readr", "dplyr", "ggplot2", "brms", "quarto"),
  system_pkgs = "cmdstan",
  git_pkgs = list(
    list(
      package_name = "cmdstanr",
      repo_url = "https://github.com/stan-dev/cmdstanr",
      commit = "79d37792d8e4ffcf3cf721b8d7ee4316a1234b0c"
    ),
    list(
      package_name = "rixpress",
      repo_url = "https://github.com/b-rodrigues/rixpress",
      commit = "HEAD"
    )
  ),
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
```

Note that `cmdstan` is added to the system packages and that `{cmdstanr}` is
installed from GitHub (as it is not available from CRAN).

Then, we define the pipeline:

```r
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
  rixpress()
```

There are several important things that you should take note of:

- the model is written as a string, but it could be defined in a file (in which
  case you would then use `rxp_r_file()` with `readLines()` to bring the model
  into the pipeline)
- 
