let
  default = import ./default.nix;
  defaultPkgs = default.pkgs;
  defaultShell = default.shell;
  defaultBuildInputs = defaultShell.buildInputs;
  defaultConfigurePhase = ''
    cp ${./_rixpress/default_libraries.jl} libraries.jl
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
  # Function to create Julia derivations
  makeJlDerivation = { name, buildInputs, configurePhase, buildPhase, src ? null }:
    defaultPkgs.stdenv.mkDerivation {
      inherit name src;
      dontUnpack = true;
      buildInputs = buildInputs;
      inherit configurePhase buildPhase;
      installPhase = ''
        cp ${name} $out/
      '';
    };

  # Define all derivations
    d_size = makeJlDerivation {
    name = "d_size";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      julia -e "
if isfile(\"libraries.jl\"); include(\"libraries.jl\"); end;
# RIXPRESS_JL_LOAD_DEPENDENCIES_HERE;
d_size = 150; using Serialization; io = open(\"d_size\", \"w\"); serialize(io, d_size); close(io)
"
    '';
  };

  data = makeJlDerivation {
    name = "data";
    src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./functions.jl ];
    };
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp ${./functions.jl} functions.jl
      julia -e "
if isfile(\"libraries.jl\"); include(\"libraries.jl\"); end;
d_size = open(\"${d_size}/d_size\", \"r\") do io; Serialization.deserialize(io); end;
include(\"functions.jl\"); data = 0.1randn(d_size,d_size) + reshape( 
     cholesky(gridlaplacian(d_size,d_size) + 0.003I) \ randn(d_size*d_size), 
     d_size, 
     d_size 
   ); using Serialization; io = open(\"data\", \"w\"); serialize(io, data); close(io)
"
    '';
  };

  laplace_df = makeJlDerivation {
    name = "laplace_df";
    src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./functions.jl ];
    };
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp ${./functions.jl} functions.jl
      julia -e "
if isfile(\"libraries.jl\"); include(\"libraries.jl\"); end;
data = open(\"${data}/data\", \"r\") do io; Serialization.deserialize(io); end;
include(\"functions.jl\"); laplace_df = DataFrame(data, :auto); arrow_write(laplace_df, \"laplace_df\")
"
    '';
  };

  laplace_long_df = makeRDerivation {
    name = "laplace_long_df";
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
        laplace_df <- "read_ipc_file"('${laplace_df}/laplace_df')
        source('functions.R')
        laplace_long_df <- prepare_data(laplace_df)
        saveRDS(laplace_long_df, 'laplace_long_df')"
    '';
  };

  gg = makeRDerivation {
    name = "gg";
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
        laplace_long_df <- readRDS('${laplace_long_df}/laplace_long_df')
        source('functions.R')
        gg <- make_gg(laplace_long_df)
        saveRDS(gg, 'gg')"
    '';
  };

  dag = makeRDerivation {
    name = "dag";
     src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./_rixpress ];
    };
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp -r ${./_rixpress} _rixpress
      Rscript -e "
        source('libraries.R')
        # RIXPRESS_LOAD_DEPENDENCIES_HERE
        dag <- rxp_visnetwork()
        saveRDS(dag, 'dag')"
    '';
  };

  julia_doc = defaultPkgs.stdenv.mkDerivation {
    name = "julia_doc";
    src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./document.qmd ];
    };
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      mkdir home
      export HOME=$PWD/home
      export RETICULATE_PYTHON=${defaultPkgs.python3}/bin/python

      substituteInPlace document.qmd --replace-fail 'rixpress::rxp_read("dag")' 'rixpress::rxp_read("${dag}")'
      substituteInPlace document.qmd --replace-fail 'rixpress::rxp_read("gg")' 'rixpress::rxp_read("${gg}")'
      quarto render document.qmd  --output-dir $out
    '';
  };

  # Generic default target that builds all derivations
  allDerivations = defaultPkgs.symlinkJoin {
    name = "all-derivations";
    paths = with builtins; attrValues { inherit d_size data laplace_df laplace_long_df gg dag julia_doc; };
  };

in
{
  inherit d_size data laplace_df laplace_long_df gg dag julia_doc;
  default = allDerivations;
}
