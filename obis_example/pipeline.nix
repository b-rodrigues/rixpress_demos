let
  default = import ./default.nix;
defaultPkgs = default.pkgs;
defaultShell = default.shell;
defaultBuildInputs = defaultShell.buildInputs;
defaultConfigurePhase = ''
    cp ${./_rixpress/default_libraries.py} libraries.py
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
  # Function to create Python derivations
  makePyDerivation = { name, buildInputs, configurePhase, buildPhase, src ? null }:
    let
      pickleFile = "${name}.pickle";
    in
      defaultPkgs.stdenv.mkDerivation {
        inherit name src;
        dontUnpack = true;
        buildInputs = buildInputs;
        inherit configurePhase buildPhase;
        installPhase = ''
          cp ${pickleFile} $out
        '';
      };

  # Define all derivations
    gdf = makePyDerivation {
    name = "gdf";
    src = ./data/oceans.shp;
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp $src input_file
python -c "
exec(open('libraries.py').read())
file_path = 'input_file'
data = eval('lambda x: geopandas.read_file(x)')(file_path)
with open('gdf.pickle', 'wb') as f:
    pickle.dump(data, f)
"

    '';
  };

  sa = makePyDerivation {
    name = "sa";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${gdf}/gdf.pickle', 'rb') as f: gdf = pickle.load(f)
exec('sa = gdf.loc[gdf[\'Oceans\'] == \'South Atlantic Ocean\'][\'geometry\'].loc[0]')
with open('sa.pickle', 'wb') as f: pickle.dump(globals()['sa'], f)"
    '';
  };

  atlantic = makePyDerivation {
    name = "atlantic";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${sa}/sa.pickle', 'rb') as f: sa = pickle.load(f)
exec('atlantic = sa.wkt')
with open('atlantic.pickle', 'wb') as f: pickle.dump(globals()['atlantic'], f)"
    '';
  };

  species = makeRDerivation {
    name = "species";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        species <- set_species()
        saveRDS(species, 'species.rds')"
    '';
  };

  matches = makeRDerivation {
    name = "matches";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        species <- readRDS('${species}/species.rds')
        matches <- obistools::match_taxa(species, ask = FALSE)
        saveRDS(matches, 'matches.rds')"
    '';
  };

  # Generic default target that builds all derivations
  allDerivations = defaultPkgs.symlinkJoin {
    name = "all-derivations";
    paths = with builtins; attrValues { inherit gdf sa atlantic species matches; };
  };

in
{
  inherit gdf sa atlantic species matches;
  default = allDerivations;
}
