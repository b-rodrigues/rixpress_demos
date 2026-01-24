# Sub-Pipelines Demo

This demo illustrates how to organize large projects using `rxp_pipeline()` to
create named sub-pipelines with custom colors for DAG visualization.

## Project Structure

```
subpipelines/
├── gen-env.R                   # Generates the Nix environment
├── gen-pipeline.R              # Master script that combines sub-pipelines
├── readme.md                   # This file
└── pipelines/
    ├── 01_data_prep.R          # Data preparation sub-pipeline
    └── 02_analysis.R           # Analysis sub-pipeline
```

## Key Concepts

### 1. Modular Pipeline Definition

Each sub-pipeline is defined in a separate R script that returns a list of
derivations:

```r
# pipelines/01_data_prep.R
list(
  rxp_r(name = raw_data, expr = mtcars),
  rxp_r(name = clean_data, expr = dplyr::filter(raw_data, am == 1))
)
```

### 2. Master Script Pattern

The master script (`gen-pipeline.R`) sources the sub-pipelines and wraps them
with `rxp_pipeline()` to add names and colors:

```r
# Source sub-pipelines
data_prep <- source("pipelines/01_data_prep.R")$value
analysis <- source("pipelines/02_analysis.R")$value

# Create named pipelines with colors
pipe_data <- rxp_pipeline("Data Prep", data_prep, color = "darkorange")
pipe_analysis <- rxp_pipeline("Analysis", analysis, color = "dodgerblue")

# Build combined pipeline
rxp_populate(list(pipe_data, pipe_analysis))
```

### 3. Visual Distinction in DAG

When you visualize the pipeline with `rxp_visnetwork()` or `rxp_ggdag()`:
- Data Prep nodes appear in **orange**
- Analysis nodes appear in **blue**
- The legend shows pipeline group names

## Running the Demo

1. Generate the Nix environment:
   ```bash
   nix-shell -p R --run "Rscript gen-env.R"
   ```

2. Enter the Nix shell and run the master script:
   ```bash
   nix-shell default.nix --run "Rscript gen-pipeline.R"
   ```

3. Build the pipeline:
   ```bash
   nix-shell default.nix --run "Rscript -e 'rixpress::rxp_make()'"
   ```

4. Visualize the DAG (shows colored nodes by pipeline):
   ```r
   rixpress::rxp_visnetwork()  # Interactive visualization
   rixpress::rxp_ggdag()       # Static ggplot visualization
   ```

## Benefits of Sub-Pipelines

1. **Organisation**: Break large pipelines into logical, manageable pieces
2. **Reusability**: Sub-pipelines can be shared across projects
3. **Clarity**: Visual distinction helps understand data flow
4. **Team Collaboration**: Different team members can work on different sub-pipelines
