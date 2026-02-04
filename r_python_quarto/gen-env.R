library(rix)

rix(
  date = "2026-02-02",
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
      commit = "78d389207fe2a293b6a0553d74917d485c56c306"
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
  # Export LD_LIBRARY_PATH for python packages that dynamically load libraries, such as numpy
  export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath (with pkgs; [ zlib gcc.cc glibc stdenv.cc.cc ])}":$LD_LIBRARY_PATH;
  
  # Prevent reticulate from auto-configuring and modifying PYTHONPATH
  # Nix has already set PYTHONPATH correctly
  export RETICULATE_AUTOCONFIGURE=0
  ',
  overwrite = TRUE
)
