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
    gorilla_pixels = makePyDerivation {
    name = "gorilla_pixels";
    src = ./md_source/gorilla/gorilla-waving-cartoon-black-white-outline-clipart-914.jpg;
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp $src input_file
python -c "
exec(open('libraries.py').read())
file_path = 'input_file'
data = eval('read_image')(file_path)
with open('gorilla_pixels.pickle', 'wb') as f:
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
exec('threshold_level = 50')
with open('threshold_level.pickle', 'wb') as f: pickle.dump(globals()['threshold_level'], f)"
    '';
  };

  py_coords = makePyDerivation {
    name = "py_coords";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${gorilla_pixels}/gorilla_pixels.pickle', 'rb') as f: gorilla_pixels = pickle.load(f)
with open('${threshold_level}/threshold_level.pickle', 'rb') as f: threshold_level = pickle.load(f)
exec('py_coords = numpy.column_stack(numpy.where(gorilla_pixels < threshold_level))')
with open('py_coords.pickle', 'wb') as f: pickle.dump(globals()['py_coords'], f)"
    '';
  };

  raw_coords = makeRDerivation {
    name = "raw_coords";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      export RETICULATE_PYTHON='${defaultPkgs.python3}/bin/python'
       Rscript -e "
         source('libraries.R')
         raw_coords <- reticulate::py_load_object('${py_coords}/py_coords.pickle', pickle = 'pickle', convert = TRUE)
         saveRDS(raw_coords, 'raw_coords.rds')"
    '';
  };

  coords = makeRDerivation {
    name = "coords";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        raw_coords <- readRDS('${raw_coords}/raw_coords.rds')
        coords <- clean_coords(raw_coords)
        saveRDS(coords, 'coords.rds')"
    '';
  };

  gender_dist = makeRDerivation {
    name = "gender_dist";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        raw_coords <- readRDS('${raw_coords}/raw_coords.rds')
        gender_dist <- gender_distribution(raw_coords)
        saveRDS(gender_dist, 'gender_dist.rds')"
    '';
  };

  plot1 = makeRDerivation {
    name = "plot1";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        raw_coords <- readRDS('${raw_coords}/raw_coords.rds')
        plot1 <- make_plot1(raw_coords)
        saveRDS(plot1, 'plot1.rds')"
    '';
  };

  plot2 = makeRDerivation {
    name = "plot2";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        raw_coords <- readRDS('${raw_coords}/raw_coords.rds')
        plot2 <- make_plot2(raw_coords)
        saveRDS(plot2, 'plot2.rds')"
    '';
  };

  page = defaultPkgs.stdenv.mkDerivation {
    name = "page";
    src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./md_source/source.qmd ./md_source/gorilla ];
    };
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
  mkdir home
  export HOME=$PWD/home
  export RETICULATE_PYTHON='${defaultPkgs.python3}/bin/python'

  substituteInPlace md_source/source.qmd --replace-fail 'rxp_read("gender_dist")' 'rxp_read("${gender_dist}")'
  substituteInPlace md_source/source.qmd --replace-fail 'rxp_read("plot1")' 'rxp_read("${plot1}")'
  substituteInPlace md_source/source.qmd --replace-fail 'rxp_read("plot2")' 'rxp_read("${plot2}")'
  quarto render md_source/source.qmd  --output-dir $out
    '';
  };

  # Generic default target that builds all derivations
  allDerivations = defaultPkgs.symlinkJoin {
    name = "all-derivations";
    paths = with builtins; attrValues { inherit gorilla_pixels threshold_level py_coords raw_coords coords gender_dist plot1 plot2 page; };
  };

in
{
  inherit gorilla_pixels threshold_level py_coords raw_coords coords gender_dist plot1 plot2 page;
  default = allDerivations;
}
