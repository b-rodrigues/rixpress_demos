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
    dataset_np = makePyDerivation {
    name = "dataset_np";
    src = ./data/pima-indians-diabetes.csv;
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp $src input_file
python -c "
exec(open('libraries.py').read())
file_path = 'input_file'
data = eval('lambda x: loadtxt(x, delimiter=\',\')')(file_path)
with open('dataset_np', 'wb') as f:
    pickle.dump(data, f)
"

    '';
  };

  X = makePyDerivation {
    name = "X";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${dataset_np}/dataset_np', 'rb') as f: dataset_np = pickle.load(f)
exec('X = dataset_np[:,0:8]')
with open('X', 'wb') as f: pickle.dump(globals()['X'], f)
"
    '';
  };

  Y = makePyDerivation {
    name = "Y";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${dataset_np}/dataset_np', 'rb') as f: dataset_np = pickle.load(f)
exec('Y = dataset_np[:,8]')
with open('Y', 'wb') as f: pickle.dump(globals()['Y'], f)
"
    '';
  };

  splits = makePyDerivation {
    name = "splits";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${X}/X', 'rb') as f: X = pickle.load(f)
with open('${Y}/Y', 'rb') as f: Y = pickle.load(f)
exec('splits = train_test_split(X, Y, test_size=0.33, random_state=7)')
with open('splits', 'wb') as f: pickle.dump(globals()['splits'], f)
"
    '';
  };

  X_train = makePyDerivation {
    name = "X_train";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${splits}/splits', 'rb') as f: splits = pickle.load(f)
exec('X_train = splits[0]')
with open('X_train', 'wb') as f: pickle.dump(globals()['X_train'], f)
"
    '';
  };

  X_test = makePyDerivation {
    name = "X_test";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${splits}/splits', 'rb') as f: splits = pickle.load(f)
exec('X_test = splits[1]')
with open('X_test', 'wb') as f: pickle.dump(globals()['X_test'], f)
"
    '';
  };

  y_train = makePyDerivation {
    name = "y_train";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${splits}/splits', 'rb') as f: splits = pickle.load(f)
exec('y_train = splits[2]')
with open('y_train', 'wb') as f: pickle.dump(globals()['y_train'], f)
"
    '';
  };

  y_test = makePyDerivation {
    name = "y_test";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${splits}/splits', 'rb') as f: splits = pickle.load(f)
exec('y_test = splits[3]')
with open('y_test', 'wb') as f: pickle.dump(globals()['y_test'], f)
"
    '';
  };

  model = makePyDerivation {
    name = "model";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${X_train}/X_train', 'rb') as f: X_train = pickle.load(f)
with open('${y_train}/y_train', 'rb') as f: y_train = pickle.load(f)
exec('model = XGBClassifier(use_label_encoder=False, eval_metric=\'logloss\').fit(X_train, y_train)')
with open('model', 'wb') as f: pickle.dump(globals()['model'], f)
"
    '';
  };

  y_pred = makePyDerivation {
    name = "y_pred";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${X_test}/X_test', 'rb') as f: X_test = pickle.load(f)
with open('${model}/model', 'rb') as f: model = pickle.load(f)
exec('y_pred = model.predict(X_test)')
with open('y_pred', 'wb') as f: pickle.dump(globals()['y_pred'], f)
"
    '';
  };

  combined_df = makePyDerivation {
    name = "combined_df";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${y_test}/y_test', 'rb') as f: y_test = pickle.load(f)
with open('${y_pred}/y_pred', 'rb') as f: y_pred = pickle.load(f)
exec('combined_df = DataFrame({\'truth\': y_test, \'estimate\': y_pred})')
with open('combined_df', 'wb') as f: pickle.dump(globals()['combined_df'], f)
"
    '';
  };

  combined_csv = makePyDerivation {
    name = "combined_csv";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${combined_df}/combined_df', 'rb') as f: combined_df = pickle.load(f)
exec('combined_csv = combined_df')
write_to_csv(globals()['combined_csv'], 'combined_csv')
"
    '';
  };

  combined_factor = makeRDerivation {
    name = "combined_factor";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        combined_csv <- "read.csv"('${combined_csv}/combined_csv')
        combined_factor <- mutate(combined_csv, across(.cols = everything(), .fns = factor))
        saveRDS(combined_factor, 'combined_factor')"
    '';
  };

  confusion_matrix = makeRDerivation {
    name = "confusion_matrix";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        combined_factor <- readRDS('${combined_factor}/combined_factor')
        confusion_matrix <- conf_mat(combined_factor, truth, estimate)
        saveRDS(confusion_matrix, 'confusion_matrix')"
    '';
  };

  accuracy = makePyDerivation {
    name = "accuracy";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${y_test}/y_test', 'rb') as f: y_test = pickle.load(f)
with open('${y_pred}/y_pred', 'rb') as f: y_pred = pickle.load(f)
exec('accuracy = accuracy_score(y_test, y_pred)')
with open('accuracy', 'wb') as f: pickle.dump(globals()['accuracy'], f)
"
    '';
  };

  # Generic default target that builds all derivations
  allDerivations = defaultPkgs.symlinkJoin {
    name = "all-derivations";
    paths = with builtins; attrValues { inherit dataset_np X Y splits X_train X_test y_train y_test model y_pred combined_df combined_csv combined_factor confusion_matrix accuracy; };
  };

in
{
  inherit dataset_np X Y splits X_train X_test y_train y_test model y_pred combined_df combined_csv combined_factor confusion_matrix accuracy;
  default = allDerivations;
}
