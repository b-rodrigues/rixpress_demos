This example illustrates how each derivation can run in a dedicated environment.
Start by looking at `gen-env.R`. This script uses `{rix}` to generate 4 environments:

- py-env.nix: Python environment
- default2.nix: Environment with dplyr
- quarto-env.nix: Environment that contains Quarto
- default.nix: the main environment that executes the pipeline

In `gen-pipeline.nix` you'll see individual derivation use different environments
using the `nix_env` argument of `rxp_r()` and `rxp_py()` functions.
