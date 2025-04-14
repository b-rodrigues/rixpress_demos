let
  default = import ./default.nix;
defaultPkgs = default.pkgs;
defaultShell = default.shell;
defaultBuildInputs = defaultShell.buildInputs;
defaultConfigurePhase = ''
    cp ${./_rixpress/default_libraries.R} libraries.R
    mkdir -p $out
  '';
  
  
  # Function to create R derivations
  makeRDerivation = { name, buildInputs, configurePhase, buildPhase, src ? null }:
    defaultPkgs.stdenv.mkDerivation {
      inherit name src;
      dontUnpack = true;
      inherit buildInputs configurePhase buildPhase;
      installPhase = ''
        # This install phase will copy either an rds, or a
        # pickle to $out/. This is needed because reticulate::py_save_object
        # runs as an R derivation, but outputs a python output.
        cp ${name}.rds $out/ 2>/dev/null || cp ${name}.pickle $out/
      '';
    };

  # Define all derivations
    mtcars = makeRDerivation {
    name = "mtcars";
    src = ./data/mtcars.csv;
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp $src input_file
Rscript -e "
source('libraries.R')
data <- do.call(function(x) (read.csv(file = x, sep = '|')), list('input_file'))
saveRDS(data, 'mtcars.rds')"
    '';
  };

  filtered_mtcars = makeRDerivation {
    name = "filtered_mtcars";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        mtcars <- readRDS('${mtcars}/mtcars.rds')
        filtered_mtcars <- dplyr::filter(mtcars, am == 1)
        saveRDS(filtered_mtcars, 'filtered_mtcars.rds')"
    '';
  };

  mtcars_mpg = makeRDerivation {
    name = "mtcars_mpg";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        filtered_mtcars <- readRDS('${filtered_mtcars}/filtered_mtcars.rds')
        mtcars_mpg <- dplyr::select(filtered_mtcars, mpg)
        saveRDS(mtcars_mpg, 'mtcars_mpg.rds')"
    '';
  };

  # Generic default target that builds all derivations
  allDerivations = defaultPkgs.symlinkJoin {
    name = "all-derivations";
    paths = with builtins; attrValues { inherit mtcars filtered_mtcars mtcars_mpg; };
  };

in
{
  inherit mtcars filtered_mtcars mtcars_mpg;
  default = allDerivations;
}
