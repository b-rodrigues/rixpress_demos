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
    python_example = makePyDerivation {
    name = "python_example";
     src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./example.txt ./another.txt ./functions.py ];
    };
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp -r ${./example.txt} example.txt
      cp -r ${./another.txt} another.txt
      cp ${./functions.py} functions.py
      python -c "
exec(open('libraries.py').read())
# RIXPRESS_PY_LOAD_DEPENDENCIES_HERE
exec(open('functions.py').read())
exec('python_example = read_first_n_lines_two_files(\'example.txt\', \'another.txt\', 10)')
with open('python_example', 'wb') as f: pickle.dump(globals()['python_example'], f)
"
    '';
  };

  r_example = makeRDerivation {
    name = "r_example";
     src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./example.txt ./another.txt ./functions.R ];
    };
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp -r ${./example.txt} example.txt
      cp -r ${./another.txt} another.txt
      cp ${./functions.R} functions.R
      Rscript -e "
        source('libraries.R')
        # RIXPRESS_LOAD_DEPENDENCIES_HERE
        source('functions.R')
        r_example <- read_first_n_lines_two_files('example.txt', 'another.txt', 10)
        saveRDS(r_example, 'r_example')"
    '';
  };

  r_head = makeRDerivation {
    name = "r_head";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        r_example <- readRDS('${r_example}/r_example')
        r_head <- head(r_example)
        saveRDS(r_head, 'r_head')"
    '';
  };

  # Generic default target that builds all derivations
  allDerivations = defaultPkgs.symlinkJoin {
    name = "all-derivations";
    paths = with builtins; attrValues { inherit python_example r_example r_head; };
  };

in
{
  inherit python_example r_example r_head;
  default = allDerivations;
}
