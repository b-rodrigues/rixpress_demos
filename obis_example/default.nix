# This file was generated by the {rix} R package v0.15.8 on 2025-04-09
# with following call:
# >rix(date = "2025-03-31",
#  > r_pkgs = c("robis",
#  > "ggplot2",
#  > "dplyr",
#  > "igraph",
#  > "reticulate",
#  > "quarto"),
#  > git_pkgs = list(list(package_name = "obistools",
#  > repo_url = "https://github.com/iobis/obistools/",
#  > commit = "9df1c36fbae597d0b129649f7dcab17770a866be"),
#  > list(package_name = "rix",
#  > repo_url = "https://github.com/ropensci/rix/",
#  > commit = "HEAD"),
#  > list(package_name = "rixpress",
#  > repo_url = "https://github.com/b-rodrigues/rixpress",
#  > commit = "HEAD")),
#  > py_pkgs = list(py_version = "3.12",
#  > py_pkgs = c("geopandas",
#  >      "fiona",
#  > "pandas",
#  > "folium")),
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
      igraph
      quarto
      reticulate
      robis;
  };
 
    obistools = (pkgs.rPackages.buildRPackage {
      name = "obistools";
      src = pkgs.fetchgit {
        url = "https://github.com/iobis/obistools/";
        rev = "9df1c36fbae597d0b129649f7dcab17770a866be";
        sha256 = "sha256-RTv4tqZ0jkh8hTt7B4wiG4ps5yWf0eikXQvJOD8uav0=";
      };
      propagatedBuildInputs = builtins.attrValues {
        inherit (pkgs.rPackages) 
          cowplot
          data_tree
          digest
          dplyr
          ggplot2
          httr
          jsonlite
          knitr
          leaflet
          maps
          rappdirs
          rmarkdown
          sf
          stringr
          terra
          tidyr
          worrms
          xml2;
      };
    });

    rix = (pkgs.rPackages.buildRPackage {
      name = "rix";
      src = pkgs.fetchgit {
        url = "https://github.com/ropensci/rix/";
        rev = "HEAD";
        sha256 = "sha256-IMAtIzcm4Or36PT2v94z3kjs2sbRyn9DRV8zXuQ9jhg=";
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
        sha256 = "sha256-IlqIW6Bs4kX9RUHQw2ndJDCfdCvX+m8jvk4vdaG82eo=";
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
      fiona
      folium
      geopandas
      pandas;
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

    buildInputs = [ obistools rix rixpress rpkgs  pypkgs system_packages   ];
    
  }; 
in
  {
    inherit pkgs shell;
  }
