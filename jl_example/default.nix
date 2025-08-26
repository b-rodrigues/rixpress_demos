let
 pkgs = import (fetchTarball "https://github.com/codedownio/nixpkgs/archive/julia-withpackages-improvements.tar.gz") {};
 
  rpkgs = builtins.attrValues {
    inherit (pkgs.rPackages) 
      arrow
      dplyr
      ggplot2
      hexbin
      quarto
      tidyr
      visNetwork;
  };
 
    rix = (pkgs.rPackages.buildRPackage {
      name = "rix";
      src = pkgs.fetchgit {
        url = "https://github.com/ropensci/rix/";
        rev = "HEAD";
        sha256 = "sha256-/oinpev8F3I8TcX+lKaF9hZFFryOjzkrQ5UjSnCX6Bk=";
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
        sha256 = "sha256-iYy25iKmO2lWF2+x87932WWDzIMIdNvJRt54468bJuw=";
      };
      propagatedBuildInputs = builtins.attrValues {
        inherit (pkgs.rPackages) 
          igraph
          jsonlite
          processx;
      };
    });
    
  jlconf = pkgs.julia_111.withPackages [ 
      "Arrow"
      "DataFrames"
      "LinearAlgebra"
      "SparseArrays"
      "Tidier"
  ];
  
  system_packages = builtins.attrValues {
    inherit (pkgs) 
      glibcLocales
      nix
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
    
    buildInputs = [ rix rixpress rpkgs jlconf system_packages ];
    
  }; 
in
  {
    inherit pkgs shell;
  }
