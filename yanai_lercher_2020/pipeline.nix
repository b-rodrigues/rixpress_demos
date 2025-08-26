let
  default = import ./default.nix;
  defaultPkgs = default.pkgs;
  defaultShell = default.shell;
  defaultBuildInputs = defaultShell.buildInputs;
  defaultConfigurePhase = ''
    cp ${./_rixpress/default_libraries.py} libraries.py
    cp ${./_rixpress/default_libraries.R} libraries.R
    mkdir -p $out  
    mkdir -p .julia_depot  
    export JULIA_DEPOT_PATH=$PWD/.julia_depot  
    export HOME_PATH=$PWD
  '';
  
  # Function to create R derivations
  makeRDerivation = { name, buildInputs, configurePhase, buildPhase, src ? null }:
    defaultPkgs.stdenv.mkDerivation {
      inherit name src;
      dontUnpack = true;
      inherit buildInputs configurePhase buildPhase;
      installPhase = ''
        cp ${name} $out/
      '';
    };
  # Function to create Python derivations
  makePyDerivation = { name, buildInputs, configurePhase, buildPhase, src ? null }:
    let
      pickleFile = "${name}";
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
    gorilla_pixels = makePyDerivation {
    name = "gorilla_pixels";
    src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./md_source/gorilla/gorilla-waving-cartoon-black-white-outline-clipart-914.jpg ./functions.py ];
    };
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp "$src/md_source/gorilla/gorilla-waving-cartoon-black-white-outline-clipart-914.jpg" input_file
cp ${./functions.py} functions.py
      
python -c "
exec(open('libraries.py').read())
exec(open('functions.py').read())
file_path = 'input_file'
data = eval('read_image')(file_path)
with open('gorilla_pixels', 'wb') as f:
    pickle.dump(data, f)
"
    '';
  };

  threshold_level = makePyDerivation {
    name = "threshold_level";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
# RIXPRESS_PY_LOAD_DEPENDENCIES_HERE
exec('threshold_level = 50')
with open('threshold_level', 'wb') as f: pickle.dump(globals()['threshold_level'], f)
"
    '';
  };

  py_coords = makePyDerivation {
    name = "py_coords";
     src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./functions.py ];
    };
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp ${./functions.py} functions.py
      python -c "
exec(open('libraries.py').read())
with open('${gorilla_pixels}/gorilla_pixels', 'rb') as f: gorilla_pixels = pickle.load(f)
with open('${threshold_level}/threshold_level', 'rb') as f: threshold_level = pickle.load(f)
exec(open('functions.py').read())
exec('py_coords = numpy.column_stack(numpy.where(gorilla_pixels < threshold_level))')
with open('py_coords', 'wb') as f: pickle.dump(globals()['py_coords'], f)
"
    '';
  };

  raw_coords = makeRDerivation {
    name = "raw_coords";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      export RETICULATE_PYTHON=${defaultPkgs.python3}/bin/python
       Rscript -e "
         source('libraries.R')
         raw_coords <- reticulate::py_load_object('${py_coords}/py_coords', pickle = 'pickle', convert = TRUE)
         saveRDS(raw_coords, 'raw_coords')"
    '';
  };

  coords = makeRDerivation {
    name = "coords";
     src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./functions.R ];
    };
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp ${./functions.R} functions.R
      Rscript -e "
        source('libraries.R')
        raw_coords <- readRDS('${raw_coords}/raw_coords')
        source('functions.R')
        coords <- clean_coords(raw_coords)
        saveRDS(coords, 'coords')"
    '';
  };

  gender_dist = makeRDerivation {
    name = "gender_dist";
     src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./functions.R ];
    };
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp ${./functions.R} functions.R
      Rscript -e "
        source('libraries.R')
        coords <- readRDS('${coords}/coords')
        source('functions.R')
        gender_dist <- gender_distribution(coords)
        saveRDS(gender_dist, 'gender_dist')"
    '';
  };

  plot1 = makeRDerivation {
    name = "plot1";
     src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./functions.R ];
    };
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp ${./functions.R} functions.R
      Rscript -e "
        source('libraries.R')
        coords <- readRDS('${coords}/coords')
        source('functions.R')
        plot1 <- make_plot1(coords)
        saveRDS(plot1, 'plot1')"
    '';
  };

  plot2 = makeRDerivation {
    name = "plot2";
     src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./functions.R ];
    };
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp ${./functions.R} functions.R
      Rscript -e "
        source('libraries.R')
        coords <- readRDS('${coords}/coords')
        source('functions.R')
        plot2 <- make_plot2(coords)
        saveRDS(plot2, 'plot2')"
    '';
  };

  doc = defaultPkgs.stdenv.mkDerivation {
    name = "doc";
    src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./md_source/source.qmd ./md_source/gorilla ];
    };
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      mkdir home
      export HOME=$PWD/home
      export RETICULATE_PYTHON=${defaultPkgs.python3}/bin/python

      substituteInPlace md_source/source.qmd --replace-fail 'rixpress::rxp_read("gender_dist")' 'rixpress::rxp_read("${gender_dist}")'
      substituteInPlace md_source/source.qmd --replace-fail 'rxp_read("plot1")' 'rxp_read("${plot1}")'
      substituteInPlace md_source/source.qmd --replace-fail 'rixpress::rxp_read("plot2")' 'rixpress::rxp_read("${plot2}")'
      quarto render md_source/source.qmd  --output-dir $out
    '';
  };

  # Generic default target that builds all derivations
  allDerivations = defaultPkgs.symlinkJoin {
    name = "all-derivations";
    paths = with builtins; attrValues { inherit gorilla_pixels threshold_level py_coords raw_coords coords gender_dist plot1 plot2 doc; };
  };

in
{
  inherit gorilla_pixels threshold_level py_coords raw_coords coords gender_dist plot1 plot2 doc;
  default = allDerivations;
}
