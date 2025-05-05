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
        cp ${name} $out/
      '';
    };

  # Define all derivations
    parameters = makeRDerivation {
    name = "parameters";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        parameters <- list(N = 100, alpha = 2, beta = -0.5, sigma = 0.1)
        saveRDS(parameters, 'parameters')"
    '';
  };

  x = makeRDerivation {
    name = "x";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        parameters <- readRDS('${parameters}/parameters')
        x <- rnorm(parameters\$N, 0, 1)
        saveRDS(x, 'x')"
    '';
  };

  y = makeRDerivation {
    name = "y";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        parameters <- readRDS('${parameters}/parameters')
        x <- readRDS('${x}/x')
        y <- rnorm(n = parameters\$N, mean = parameters\$alpha + parameters\$beta * x, sd = parameters\$sigma)
        saveRDS(y, 'y')"
    '';
  };

  inputs = makeRDerivation {
    name = "inputs";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        parameters <- readRDS('${parameters}/parameters')
        x <- readRDS('${x}/x')
        y <- readRDS('${y}/y')
        inputs <- list(N = parameters\$N, x = x, y = y)
        saveRDS(inputs, 'inputs')"
    '';
  };

  model = makeRDerivation {
    name = "model";
     src = defaultPkgs.lib.fileset.toSource {
      root = ./.;
      fileset = defaultPkgs.lib.fileset.unions [ ./model.stan ];
    };
   buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      export CMDSTAN=${defaultPkgs.cmdstan}/opt/cmdstan
      Rscript -e "
        source('libraries.R')
        model <- cmdstan_model_wrapper(model_stan_path = ${model.stan}, inputs = inputs, seed = 22)
        "save_model"(model, 'model')"
    '';
  };

  # Generic default target that builds all derivations
  allDerivations = defaultPkgs.symlinkJoin {
    name = "all-derivations";
    paths = with builtins; attrValues { inherit parameters x y inputs model; };
  };

in
{
  inherit parameters x y inputs model;
  default = allDerivations;
}
