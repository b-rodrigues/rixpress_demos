# Many inputs example

This very simple pipeline illustrates how to read in many csv files under the `data/` folder in one go.

To run this pipeline, first you need to generate the `default.nix` which will define the computational
environment the pipeline will run in. For this you need to execute the `gen-env.R` R script.
This R script uses the `{rix}` package to generate the `default.nix` file. If you 
have Nix installed, you can start an environment with R and `{rix}` by running in a terminal:

```
nix-shell --expr "$(curl -sl https://raw.githubusercontent.com/ropensci/rix/main/inst/extdata/default.nix)"
```

start R by typing `R` and then run `source("gen-env.R")`. This will generate the required `default.nix`
file. You can now exit this Nix shell by typing `CTRL-D` on `exit`. Then, start a Nix shell defined
by the `default.nix`:

```
nix-shell
```

start R by typing `R`, you can now run the pipeline by running `source("gen-pipeline")`.
You can take a look at the data by typing `rixpress::rxp_read("mtcars_parts")`.
