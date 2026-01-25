library(rix)

rix(
  date = "2025-04-14",
  r_pkgs = c("chronicler", "dplyr", "igraph", "reticulate", "quarto"),
  git_pkgs = list(
    list(
      package_name = "rix",
      repo_url = "https://github.com/ropensci/rix/",
      commit = "HEAD"
    ),
    list(
      package_name = "rixpress",
      repo_url = "https://github.com/ropensci/rixpress",
      commit = "HEAD"
    )
  ),
  py_conf = list(
    py_version = "3.12",
    py_pkgs = c("pandas", "polars", "pyarrow", "numpy"),
    git_pkgs = list(
      list(
        package_name = "ryxpress",
        repo_url = "https://github.com/b-rodrigues/ryxpress",
        commit = "HEAD"
      )
    )
  ),
  ide = "none",
  project_path = ".",
  shell_hook = '
  # Export LD_LIBRARY is required for python packages that dynamically load libraries, such as numpy
  export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath (with pkgs; [ zlib gcc.cc glibc stdenv.cc.cc ])}":LD_LIBRARY_PATH;
  ',
  overwrite = TRUE
)
