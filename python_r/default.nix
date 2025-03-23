let
 pkgs = import (fetchTarball "https://github.com/rstats-on-nix/nixpkgs/archive/2025-03-17.tar.gz") {};
 
  rpkgs = builtins.attrValues {
    inherit (pkgs.rPackages) 
      chronicler
      dplyr
      reticulate;
  };

  pypkgs = builtins.attrValues {
    inherit (pkgs.python312Packages) 
      pandas;
  };

  rix = (pkgs.rPackages.buildRPackage {
    name = "rix";
    src = pkgs.fetchgit {
      url = "https://github.com/ropensci/rix/";
      rev = "6a7e8d0bf310006bd14445017ab753e8640ced71";
      sha256 = "sha256-9wXKJd+H05ArIORQwxoSPo7hOo+a5wJSoAnTNy7501A=";
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
      url = "https://github.com/b-rodrigues/rixpress/";
      rev = "3d17a3dfb0d2b4f29af26629ed151d1d796cde41";
      sha256 = "sha256-/0QjiqyVg/utGKLJMRpTTZxKbwRyew4t9RE7l4l1HHM=";
    };
    propagatedBuildInputs = builtins.attrValues {
      inherit (pkgs.rPackages) 
        jsonlite
        igraph
        rlang;
    } ++ [ rix ];
  });
 

  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive) 
      scheme-small
      inconsolata;
  });

  system_packages = builtins.attrValues {
    inherit (pkgs) 
      glibcLocales
      glibcLocalesUtf8
      nix
      pandoc
      python312
      quarto
      which
      R;
  };
  
shell = pkgs.mkShell {
  LOCALE_ARCHIVE = if pkgs.system == "x86_64-linux" then "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
  LANG = "en_US.UTF-8";
   LC_ALL = "en_US.UTF-8";
   LC_TIME = "en_US.UTF-8";
   LC_MONETARY = "en_US.UTF-8";
   LC_PAPER = "en_US.UTF-8";
   LC_MEASUREMENT = "en_US.UTF-8";

  buildInputs = [ rix rixpress rpkgs pypkgs tex system_packages ];
  
};
in
{
  inherit pkgs shell;
}
