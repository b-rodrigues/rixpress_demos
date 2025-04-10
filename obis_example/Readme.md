## OBIS database exploration

If you use shapefiles or data from APIs, we recommend working through this
example.

This example is adapted from the
[following notebook](https://ioos.github.io/ioos_code_lab/content/code_gallery/data_access_notebooks/2018-02-20-obis.html).

Unfortunately, the OBIS api seemed to have changed since this notebook was first
put together, so we cannot replicate the entirety of the results:

```
> robis::occurrence(species, atlantic)
Error: The OBIS API was not able to process your request. If the problem persists, please contact helpdesk@obis.org.
```

However, we can still learn a lot by reproducing what we can.

Adapting this notebook to a `rixpress` pipeline requires consideration on two
levels. First, the notebook uses the `obistools` package to create a `matches`
object via `match_taxa()`, which queries the `marinespecies.org` API. This call
must be made outside the `rixpress` pipeline, as builds run in isolated
sandboxes without internet access. While this may seem inconvenient, it aligns
with good reproducibility practices; API-derived data should be saved rather than
fetched dynamically, since future availability of the API isn’t guaranteed
(nor the stability of results).

So we save `matches` using the following line:

```
matches <- obistools::match_taxa(species, ask = FALSE)
```

and then write `matches`, which is a data frame object, in the `data/` folder.
Once this is done, the `matches.csv` data can be read into the pipeline using:

```
d4 <- rxp_r_file(
  name = matches,
  path = 'data/matches.csv',
  read_function = "read.csv"
)
```

The second consideration involves how the Python `geopandas` package reads
Shapefiles. A Shapefile isn't a single file—`oceans.shp` must be accompanied by
other files like `.shx` and `.prj` in the same directory. For
`geopandas.read_file("path/to/oceans.shp")` to work, all of these files need to
be accessible. To ensure this, the `copy_data_folder` argument in
`rxp_py_file()` must be set to `TRUE`:

```
d0 <- rxp_py_file(
  name = gdf,
  path = 'data/oceans.shp',
  read_function = "lambda x: geopandas.read_file(x, driver='ESRI Shapefile')",
  copy_data_folder = TRUE
)

```

This copies all the contents of the `data/` folder into the Nix sandbox, making
it thus possible to read in `oceans.shp` using `geopandas.read_file()`.

Otherwise, this is a classic example of Python and R working together to generate
an analysis as an HTML file using Quarto.

- **`gen-env.R`**: An R script that uses the `{rix}` package to generate a Nix
  expression. This expression defines an environment with both R and Python,
  along with the necessary packages, including Quarto.
- **`gen-pipeline.R`**: An R script that sets up a multi-language pipeline by
  defining derivations.

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
   - To read the output of the derivation that generates `atlantic`, use:
     ```r
     rxp_read("atlantic")
     ```
   - To view the compiled report, run:
     ```r
     rxp_read("page")
     ```
     Since this derivation produces several files (including the HTML output and
     a folder containing images), pass the path of the HTML file to
     `browseURL()` to open it in your web browser. You can also use
     `rxp_copy("page")` to copy the contents of the folder to your working
     directory, to make it more easily accessible.

Take a look at the `.github/workflows/run_obis.yaml` file to see how this
pipeline is build and executed on Github Actions.
