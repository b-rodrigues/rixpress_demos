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
     src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./data/ ];
    };
   buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
exec('gdf = geopandas.read_file(\'data/oceans.shp\', driver=\'ESRI Shapefile\')')
with open('gdf.pickle', 'wb') as f: pickle.dump(globals()['gdf'], f)"
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
    src = ./data/matches.csv;
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp $src input_file
Rscript -e "
source('libraries.R')
data <- do.call('read.csv', list('input_file'))
saveRDS(data, 'matches.rds')"
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
