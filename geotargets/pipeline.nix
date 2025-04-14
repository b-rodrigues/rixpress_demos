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
    example_rast = makeRDerivation {
    name = "example_rast";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        example_rast <- get_example_rast()
        saveRDS(example_rast, 'example_rast.rds')"
    '';
  };

  example_shapefile = makeRDerivation {
    name = "example_shapefile";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        example_shapefile <- get_example_shapefile()
        saveRDS(example_shapefile, 'example_shapefile.rds')"
    '';
  };

  country_codes = makeRDerivation {
    name = "country_codes";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        country_codes <- country_codes(query = 'Australia')
        saveRDS(country_codes, 'country_codes.rds')"
    '';
  };

  example_gadm = makeRDerivation {
    name = "example_gadm";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        example_gadm <- get_gadm_country(c('Australia', 'New Zealand'))
        saveRDS(example_gadm, 'example_gadm.rds')"
    '';
  };

  example_cgaz_countries = makeRDerivation {
    name = "example_cgaz_countries";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        example_cgaz_countries <- cgaz_country('Australia')
        saveRDS(example_cgaz_countries, 'example_cgaz_countries.rds')"
    '';
  };

  # Generic default target that builds all derivations
  allDerivations = defaultPkgs.symlinkJoin {
    name = "all-derivations";
    paths = with builtins; attrValues { inherit example_rast example_shapefile country_codes example_gadm example_cgaz_countries; };
  };

in
{
  inherit example_rast example_shapefile country_codes example_gadm example_cgaz_countries;
  default = allDerivations;
}
