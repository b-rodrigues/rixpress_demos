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
