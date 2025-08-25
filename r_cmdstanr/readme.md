# Using cmdstanr with rixpress

`{cmdstanr}` is an R package that simplifies defining and estimating parameters
of Bayesian statistical models using `stan`.

Available only on GitHub, `{cmdstanr}` serves as a high-level interface to
`cmdstan`, a command-line tool. The interaction between `cmdstan` and
`{cmdstanr}` can present challenges when used with `{rixpress}`. This example
illustrates how to use `{rixpress}` effectively with `{cmdstanr}`.

The first step, as always, is to define the pipeline's execution environment:

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

Note that `cmdstan` is added as a system package, and `{cmdstanr}` is installed
from GitHub, as it is not available on CRAN.

Next, we define the pipeline:

```r
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
  rxp_populate()
```

Several important points to note:

- The Stan model is written in a text file named `model.stan` and included in
  the pipeline using `readLines()`. This might seem unusual to those familiar
  with `{cmdstanr}`; bear with me for now.
- We then define parameters and data: `parameters`, `y`, `x`, and `inputs`.
- The model and inputs are passed to a custom function,
  `cmdstan_model_wrapper()`. Here is the wrapper's definition:

  ```r
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

    model$sample(data = inputs, seed = seed) # Use the passed seed
  }
  ```
  This wrapper function takes the model code as a string and writes it to a
  temporary file. This step is necessary because, even though the model exists
  as a file in the project, this method ensures the model code is accessible
  within the hermetic build environment (sandbox) of `{rixpress}`. Using the
  `additional_files` argument of `rxp_r()` for the `.stan` file can lead to
  permission errors when `cmdstan` attempts to compile the model, possibly due
  to interactions with the Nix sandbox. This wrapper approach bypasses that
  issue. Furthermore, both model compilation (implicitly by `cmdstan_model`) and
  sampling (`model$sample`) must occur within the same pipeline step (and thus
  the same sandbox). This is because the `model` object returned by
  `cmdstan_model` primarily contains a path to the compiled Stan executable. If
  compilation and sampling were in separate steps, the path to the compiled
  model would not be valid in the subsequent sandbox, causing `model$sample` to
  fail.

- Finally, it's important to use a custom serialization function, `save_model`:
  ```r
  save_model <- function(fitted_model, path, ...) {
    fitted_model$save_object(path, ...)
  }
  ```
  The `{cmdstanr}` documentation recommends using the `$save_object()` method to
  ensure a fitted Stan model can be reliably saved and reused. This method is
  essentially a wrapper around `saveRDS()` that handles the specific needs of
  `cmdstanr` objects. Since it uses `saveRDS()` internally, the saved model can
  be loaded as usual with `readRDS()`, for example, via `rxp_read("model")`.
