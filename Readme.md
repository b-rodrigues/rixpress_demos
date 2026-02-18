# rixpress_demos

This repository contains pipelines that serve as integration tests for the
[`rixpress`](https://github.com/b-rodrigues/rixpress) project.

Every time a new commit is pushed to
[`b-rodrigues/rixpress`](https://github.com/b-rodrigues/rixpress), these
pipelines are triggered to run and validate the code in that repository.

Because `rixpress` makes extensive use of functions with side effects,
traditional unit testing is cumbersome. Instead, these pipelines execute
full workflows to ensure everything behaves as expected. This approach provides
a practical way to catch regressions or breaking changes.

The outputs of the pipelines that build a Quarto or RMD document are published
and can be viewed [here](https://b-rodrigues.github.io/rixpress_demos/).

## Examples list

- `basic_r`: simplest example;
- `r_qs`: simplest example, using `{qs}` for serialisation instead of
  `saveRDS/readRDS`;
- `many_inputs_example`: shows how to read many data files under a single folder
  in one go;
- `jl_example`: shows how to use Julia;
- `obis_example`: Python-R pipeline that illustrates how to analyze a shapefile,
  and data from an API;
- `r_python_quarto`: simple Python-R pipeline that compiles a Quarto html doc;
- `r_python_rmd`: simple Python-R pipeline that compiles a RMD html doc;
- `python_r_typst`: simple Python-R pipeline that compiles to a Typst document;
- `r_py_json`: Python-R pipeline with direct transfer of data from Python to R
  using json;
- `r_multi_envs`: Python-R pipeline that illustrates how different environments can be
  used for different derivations
- `yanai_lercher_2020`: Python-R pipeline, an adaptation of the code of the
  paper 'Selective attention in hypothesis-driven data analysis'
- `r_py_xgboost`: Python-R pipeline that uses the Python `xgboost` library to
  train an extreme gradient boosting model. Predictions are then passed to R to
  compute the confusion matrix using `{yardstick}`.

Each example contains a readme with more details.
