Original code from https://machinelearningmastery.com/develop-first-xgboost-model-python-scikit-learn/

# Rixpress Pima Diabetes Pipeline: Integrating R and Python

## Overview

This example demonstrates a machine learning pipeline built using the
`{rixpress}` package. It showcases how `{rixpress}` orchestrates tasks involving
both R and Python code to:

1.  Load the Pima Indians Diabetes dataset.
2.  Train an XGBoost classification model using Python's
    xgboost library.
3.  Make predictions on a test set.
4.  Combine predictions and actual values for evaluation.
5.  Calculate accuracy using Python.
6.  Calculate a confusion matrix using R's `{yardstick}` package.

It would have been possible to only use R or only use Python for this, since
`xgboost` is available for both languages. But the goal of this pipeline is to
showcase the seamless integration of Python and R steps within a single,
reproducible pipeline defined entirely in R using `{rixpress}`.

## How it works

Just like for the other examples, there are two main scripts:

- `gen-env.R`, which defines the execution environment of the pipeline, and
- `gen-pipeline.R`, which defines the pipeline itself.

`gen-env.R` uses the `{rix}` package to generate a Nix expression in a file
called `default.nix` which defines the environment. Because it uses Nix,
this environment is 100% reproducible: from R packages all the way down to
`glibc`, all dependencies are declared and managed.

## R and Python Integration with `rixpress`

This pipeline highlights `rixpress`'s core strength: managing workflows that
span R and Python.

*   **Step Definition:** Each step is explicitly declared as either R (`rxp_r`)
    or Python (`rxp_py`, `rxp_py_file`).
*   **Data Flow (Artifacts):** The output of one step (an "artifact", identified
    by `name = ...`) becomes the input for subsequent steps, regardless of the
    language change. `rixpress` handles the passing of these artifacts.
*   **Serialization/Deserialization:** When switching between languages or
    saving intermediate results, `rixpress` manages data serialization (saving
    data to disk, e.g., Python DataFrame to CSV) and deserialization (loading
    data from disk, e.g., CSV to R data frame). This is controlled by parameters
    like `read_function`, `serialize_function`, and `unserialize_function`. By
    default, Python object are serialized using `pickle` and R objects using
    `saveRDS()`.
*   **Python Environment Management:** `rixpress` uses `adjust_import` and
    `add_import` to precisely control the Python import statements needed for
    the pipeline steps, ensuring the correct functions (`loadtxt`, `DataFrame`,
    `train_test_split`, `XGBClassifier`, `accuracy_score`) are available from
    their respective libraries (`numpy`, `pandas`, `sklearn`, `xgboost`). These
    configurations are tied to an underlying Nix environment (in this case,
    `default.nix`, as defined by `gen-env.R`)

## Running the Pipeline

- Start by generating the `default.nix` file. If you have Nix installed on your
  system, but not R, first start by configuring the `rstats-on-nix` cache, which
  will provide compiled binaries of R and R packages so you don't need to build
  them from source. Installing `cachix`:

  ```
  nix-env -iA cachix -f https://cachix.org/api/v1/install
  ```

  then use the cache:

  ```
  cachix use rstats-on-nix
  ```

  You only need to do this once per machine you want to use `{rix}` on. Many
  thanks to Cachix for sponsoring the rstats-on-nix cache! Then run the
  following line in a terminal to be dropped in a temporary Nix shell with R and
  `{rix}` available:

  ```
  nix-shell --expr "$(curl -sl https://raw.githubusercontent.com/ropensci/rix/main/inst/extdata/default.nix)"
  ```
  Start R, then simply `source("gen-env.R")`. This will generate the
  `default.nix` file.

- Quit R using `quit()` and then the temporary Nix shell using `exit`. Now
  build the new shell using `nix-build`.

- Once the build process of the execution environment is done, use `nix-shell`
  to enter the shell, start R, and then `source("gen-pipeline.R")` to build the
  pipeline.

## Output

The pipeline execution will result in several artifacts being computed. The key final outputs available for inspection after `rxp_make()` would typically be:

*   `accuracy`: A numeric value representing the prediction accuracy (calculated
    in Python).
*   `confusion_matrix`: An R object (likely a `conf_mat` object from
    `yardstick`) containing the confusion matrix.
*   `combined_csv`: A file path pointing to the generated CSV containing the
    'truth' and 'estimate' columns.

You can review them by using `rxp_read("accuracy")` or `rxp_read("conf_mat")`.
You can list all the available outputs using `rxp_inspect()`.
