# This file was generated by the {rix} R package v0.15.8 on 2025-04-16
# with following call:
# >rix(date = "2025-03-31",
#  > r_pkgs = c("dplyr",
#  > "ggplot2",
#  > "reticulate",
#  > "quarto"),
#  > git_pkgs = list(list(package_name = "rix",
#  > repo_url = "https://github.com/ropensci/rix/",
#  > commit = "HEAD"),
#  > list(package_name = "rixpress",
#  > repo_url = "https://github.com/b-rodrigues/rixpress",
#  > commit = "HEAD")),
#  > py_pkgs = list(py_version = "3.12",
#  > py_pkgs = c("numpy",
#  > "pillow")),
#  > ide = "none",
#  > project_path = ".",
#  > overwrite = TRUE,
#  > r_ver = "4.4.3")
# It uses the `rstats-on-nix` fork of `nixpkgs` which provides improved
# compatibility with older R versions and R packages for Linux/WSL and
# Apple Silicon computers.
# Report any issues to https://github.com/ropensci/rix
let
 pkgs = import (fetchTarball "https://github.com/rstats-on-nix/nixpkgs/archive/2025-03-31.tar.gz") {};
 
  rpkgs = builtins.attrValues {
    inherit (pkgs.rPackages) 
      dplyr
      ggplot2
      quarto
      reticulate;
  };
 
    rix = (pkgs.rPackages.buildRPackage {
      name = "rix";
      src = pkgs.fetchgit {
        url = "https://github.com/ropensci/rix/";
        rev = "HEAD";
        sha256 = "sha256-kleOMDqE2BIxaKmr4YAzM8q6BI2iQJMV46jVPXJajns=";
      };
      propagatedBuildInputs = builtins.attrValues {
        inherit (pkgs.rPackages) 
          codetools
          curl
          jsonlite
          sys;
      };
    });

    rixpress = (pkgs.rPackages.buildRPackage {
      name = "rixpress";
      src = pkgs.fetchgit {
        url = "https://github.com/b-rodrigues/rixpress";
        rev = "HEAD";
        sha256 = "sha256-X8Tqqb3q/yVb7eeAmeqLM0ZdWSIIM9ZIviS5eaKfyK4=";
      };
      propagatedBuildInputs = builtins.attrValues {
        inherit (pkgs.rPackages) 
          igraph
          jsonlite
          processx;
      };
    });
   
  pypkgs = builtins.attrValues {
    inherit (pkgs.python312Packages) 
      pip
      ipykernel
      numpy
      pillow;
  };
  
  system_packages = builtins.attrValues {
    inherit (pkgs) 
      glibcLocales
      nix
      python312
      R
      quarto
      which
      pandoc;
  };
  
  shell = pkgs.mkShell {
    LOCALE_ARCHIVE = if pkgs.system == "x86_64-linux" then "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
    LANG = "en_US.UTF-8";
   LC_ALL = "en_US.UTF-8";
   LC_TIME = "en_US.UTF-8";
   LC_MONETARY = "en_US.UTF-8";
   LC_PAPER = "en_US.UTF-8";
   LC_MEASUREMENT = "en_US.UTF-8";

    buildInputs = [ rix rixpress rpkgs  pypkgs system_packages   ];
    
  }; 
in
  {
    inherit pkgs shell;
  }
