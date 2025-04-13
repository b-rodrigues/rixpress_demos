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

The outputs of the pipelines are published and can be viewed
[here](https://b-rodrigues.github.io/rixpress_demos/).

## Examples list

- `basic_r`: simplest example;
- `many_inputs_example`: shows how to read many data files under a single folder in one go;
- `obis_example`: Python-R pipeline that illustrates how to analyze a shapefile, and data from an API;
- `python_r`: simple Python-R pipeline;
- `python_r_typst`: simple Python-R pipeline that compiles to a Typst document;
- `r_multi_envs`: R pipeline that illustrates how different environments can be used for different derivations
- `yanai_lercher_2020`: Python-R pipeline, an adaptation of the code of the paper 'Selective attention in hypothesis-driven data analysis'

 Each example contains a readme with more details.
