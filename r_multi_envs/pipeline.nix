let
  py_env = import ./py-env.nix;
  py_envPkgs = py_env.pkgs;
  py_envShell = py_env.shell;
  py_envBuildInputs = py_envShell.buildInputs;
  py_envConfigurePhase = ''
    cp ${./_rixpress/py_env_libraries.py} libraries.py
    cp ${./_rixpress/py_env_libraries.R} libraries.R
    mkdir -p $out  
    mkdir -p .julia_depot  
    export JULIA_DEPOT_PATH=$PWD/.julia_depot  
    export HOME_PATH=$PWD
  '';
  

  default = import ./default.nix;
  defaultPkgs = default.pkgs;
  defaultShell = default.shell;
  defaultBuildInputs = defaultShell.buildInputs;
  defaultConfigurePhase = ''
    cp ${./_rixpress/default_libraries.R} libraries.R
    cp ${./_rixpress/default2_libraries.R} default2_libraries.R
    mkdir -p $out  
    mkdir -p .julia_depot  
    export JULIA_DEPOT_PATH=$PWD/.julia_depot  
    export HOME_PATH=$PWD
  '';
  

  default2 = import ./default2.nix;
  default2Pkgs = default2.pkgs;
  default2Shell = default2.shell;
  default2BuildInputs = default2Shell.buildInputs;
  default2ConfigurePhase = ''
    cp ${./_rixpress/default2_libraries.R} libraries.R
    mkdir -p $out  
    mkdir -p .julia_depot  
    export JULIA_DEPOT_PATH=$PWD/.julia_depot  
    export HOME_PATH=$PWD
  '';
  

  quarto_env = import ./quarto-env.nix;
  quarto_envPkgs = quarto_env.pkgs;
  quarto_envShell = quarto_env.shell;
  quarto_envBuildInputs = quarto_envShell.buildInputs;
  quarto_envConfigurePhase = ''
    cp ${./_rixpress/quarto_env_libraries.R} libraries.R
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
    mtcars_pl = makePyDerivation {
    name = "mtcars_pl";
    src = ./mtcars.csv;
    buildInputs = py_envBuildInputs;
    configurePhase = py_envConfigurePhase;
    buildPhase = ''
      cp $src input_file
python -c "
exec(open('libraries.py').read())
file_path = 'input_file'
data = eval('lambda x: polars.read_csv(x, separator=\'|\')')(file_path)
with open('mtcars_pl', 'wb') as f:
    pickle.dump(data, f)
"
    '';
  };

  mtcars_pl_am = makePyDerivation {
    name = "mtcars_pl_am";
    buildInputs = py_envBuildInputs;
    configurePhase = py_envConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${mtcars_pl}/mtcars_pl', 'rb') as f: mtcars_pl = pickle.load(f)
exec('mtcars_pl_am = mtcars_pl.filter(polars.col(\'am\') == 1).to_pandas()')
with open('mtcars_pl_am', 'wb') as f: pickle.dump(globals()['mtcars_pl_am'], f)
"
    '';
  };

  mtcars_am = makeRDerivation {
    name = "mtcars_am";
    buildInputs = py_envBuildInputs;
    configurePhase = py_envConfigurePhase;
    buildPhase = ''
      export RETICULATE_PYTHON=${defaultPkgs.python3}/bin/python
       Rscript -e "
         source('libraries.R')
         mtcars_am <- reticulate::py_load_object('${mtcars_pl_am}/mtcars_pl_am', pickle = 'pickle', convert = TRUE)
         saveRDS(mtcars_am, 'mtcars_am')"
    '';
  };

  mtcars_head = makeRDerivation {
    name = "mtcars_head";
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
        mtcars_am <- readRDS('${mtcars_am}/mtcars_am')
        source('functions.R')
        mtcars_head <- my_head(mtcars_am)
        saveRDS(mtcars_head, 'mtcars_head')"
    '';
  };

  mtcars_tail = makeRDerivation {
    name = "mtcars_tail";
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
        mtcars_head <- readRDS('${mtcars_head}/mtcars_head')
        source('functions.R')
        mtcars_tail <- my_tail(mtcars_head)
        saveRDS(mtcars_tail, 'mtcars_tail')"
    '';
  };

  mtcars_mpg = makeRDerivation {
    name = "mtcars_mpg";
    buildInputs = default2BuildInputs;
    configurePhase = default2ConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        mtcars_tail <- readRDS('${mtcars_tail}/mtcars_tail')
        mtcars_mpg <- select(mtcars_tail, mpg)
        saveRDS(mtcars_mpg, 'mtcars_mpg')"
    '';
  };

  page = defaultPkgs.stdenv.mkDerivation {
    name = "page";
    src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./page.qmd ./content.qmd ./images ];
    };
    buildInputs = quarto_envBuildInputs;
    configurePhase = quarto_envConfigurePhase;
    buildPhase = ''
      mkdir home
      export HOME=$PWD/home
      export RETICULATE_PYTHON=${defaultPkgs.python3}/bin/python

      substituteInPlace page.qmd --replace-fail 'rixpress::rxp_read("mtcars_head")' 'rixpress::rxp_read("${mtcars_head}")'
      substituteInPlace page.qmd --replace-fail 'rixpress::rxp_read("mtcars_tail")' 'rixpress::rxp_read("${mtcars_tail}")'
      substituteInPlace page.qmd --replace-fail 'rixpress::rxp_read("mtcars_mpg")' 'rixpress::rxp_read("${mtcars_mpg}")'
      quarto render page.qmd  --output-dir $out
    '';
  };

  # Generic default target that builds all derivations
  allDerivations = defaultPkgs.symlinkJoin {
    name = "all-derivations";
    paths = with builtins; attrValues { inherit mtcars_pl mtcars_pl_am mtcars_am mtcars_head mtcars_tail mtcars_mpg page; };
  };

in
{
  inherit mtcars_pl mtcars_pl_am mtcars_am mtcars_head mtcars_tail mtcars_mpg page;
  default = allDerivations;
}
