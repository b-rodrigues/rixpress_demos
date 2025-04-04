## Multi-language pipeline example

This example demonstrates how Python and R can work together to build a Quarto
document that compiles to an HTML file.

- **`gen-env.R`**: An R script that uses the `{rix}` package to generate a Nix
  expression. This expression defines an environment with both R and Python,
  along with the necessary packages, including Quarto.
- **`gen-pipeline.R`**: An R script that sets up a multi-language pipeline by
  defining derivations. For example:

```r
d1 <- rxp_py(
  # reticulate doesn't support polars DataFrames yet, so we first convert
  # to a pandas DataFrame
  name = mtcars_pl_am,
  py_expr = "mtcars_pl.filter(polars.col('am') == 1).to_pandas()"
)
```

Here, `d1` is a derivation that runs Python code to generate the `mtcars_pl_am`
object.

### How to Run the Pipeline

1. **Start an R Session with `{rix}`:**
   - Open an R session that includes the `{rix}` package.
   - If you have Nix installed, run the following command to drop into a
     temporary shell that includes R and `{rix}`:
     ```bash
     nix-shell --expr "$(curl -sl https://raw.githubusercontent.com/ropensci/rix/main/inst/extdata/default.nix)"
     ```
   - Inside this shell, start R and execute: ```r source("gen-env.R") ``` This
     command generates the `default.nix` file.

2. **Enter the Generated Environment:**
   - Exit the temporary shell (using CTRL-D or by typing `exit`)
   - In your terminal, drop into the environment defined by the generated
     `default.nix` file by running:
     ```bash
     nix-shell
     ```

3. **Generate and Inspect the Pipeline:**
   - Once inside the environment, generate the pipeline with:
     ```r
     source("gen-pipeline.R")
     ```
   - Visualize the Directed Acyclic Graph (DAG) of the pipeline by using:
     ```r
     plot_dag()
     ```

4. **Build and Inspect the Pipeline:**
   - Build the pipeline by running:
     ```r
     rxp_make()
     ```
   - After the build process completes, inspect the intermediate derivations
     with:
     ```r
     rxp_inspect()
     ```
   - To read the output of the derivation that generates `mtcars_pl_am`, use:
     ```r
     rxp_read("mtcars_pl_am")
     ```
   - To view the compiled report, run:
     ```r
     rxp_read("page")
     ```
     Since this derivation produces several files (including the HTML output and
     a folder containing images), pass the path of the HTML file to
     `browseURL()` to open it in your web browser. (A feature to streamline this
     process is planned for future updates.)
