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
    bayesian_linear_regression_model = makeRDerivation {
    name = "bayesian_linear_regression_model";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        x <- readRDS('${x}/x')
        y <- readRDS('${y}/y')
        bayesian_linear_regression_model <- '\ndata {\n  int<lower=1> N;\n  vector[N] x;\n  vector[N] y;\n}\nparameters {\n  real alpha;\n  real beta;\n  real<lower=0> sigma;\n}\nmodel {\n  // Priors\n  alpha ~ normal(0, 5);\n  beta  ~ normal(0, 5);\n  sigma ~ inv_gamma(1, 1);\n\n  // Likelihood\n  y ~ normal(alpha + beta * x, sigma);\n}\n'
        saveRDS(bayesian_linear_regression_model, 'bayesian_linear_regression_model')"
    '';
  };

  model = makeRDerivation {
    name = "model";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      export CMDSTAN=${defaultPkgs.cmdstan}/opt/cmdstan
      Rscript -e "
        source('libraries.R')
        bayesian_linear_regression_model <- readRDS('${bayesian_linear_regression_model}/bayesian_linear_regression_model')
        model <- cmdstan_model_wrapper(bayesian_linear_regression_model, compile = FALSE)
        saveRDS(model, 'model')"
    '';
  };

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

  fit = makeRDerivation {
    name = "fit";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      export CMDSTAN=${defaultPkgs.cmdstan}/opt/cmdstan
      Rscript -e "
        source('libraries.R')
        model <- readRDS('${model}/model')
        inputs <- readRDS('${inputs}/inputs')
        model <- model\$compile
        fit <- model()\$sample(data = inputs, seed = 22)
        saveRDS(fit, 'fit')"
    '';
  };

  # Generic default target that builds all derivations
  allDerivations = defaultPkgs.symlinkJoin {
    name = "all-derivations";
    paths = with builtins; attrValues { inherit bayesian_linear_regression_model model parameters x y inputs fit; };
  };

in
{
  inherit bayesian_linear_regression_model model parameters x y inputs fit;
  default = allDerivations;
}
