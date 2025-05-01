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
    train_data = makeRDerivation {
    name = "train_data";
    src = ./data/train.csv;
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp $src input_file
      Rscript -e "
        source('libraries.R')
        data <- do.call(load_dataset, list('input_file'))
        saveRDS(data, 'train_data')"
    '';
  };

  test_data = makeRDerivation {
    name = "test_data";
    src = ./data/test.csv;
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      cp $src input_file
      Rscript -e "
        source('libraries.R')
        data <- do.call(load_dataset, list('input_file'))
        saveRDS(data, 'test_data')"
    '';
  };

  processed_train = makeRDerivation {
    name = "processed_train";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        train_data <- readRDS('${train_data}/train_data')
        processed_train <- pre_process(train_data)
        saveRDS(processed_train, 'processed_train')"
    '';
  };

  processed_test = makeRDerivation {
    name = "processed_test";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        test_data <- readRDS('${test_data}/test_data')
        processed_test <- pre_process(test_data)
        saveRDS(processed_test, 'processed_test')"
    '';
  };

  plot_train_sex = makeRDerivation {
    name = "plot_train_sex";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        processed_train <- readRDS('${processed_train}/processed_train')
        plot_train_sex <- bar_plot(df = processed_train, col = 'Sex', insight = 'Train Data Sex Distribution', flip = FALSE)
        saveRDS(plot_train_sex, 'plot_train_sex')"
    '';
  };

  plot_test_pclass = makeRDerivation {
    name = "plot_test_pclass";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        processed_test <- readRDS('${processed_test}/processed_test')
        plot_test_pclass <- bar_plot(df = processed_test, col = 'Pclass', insight = 'Test Data Pclass Distribution', flip = FALSE)
        saveRDS(plot_test_pclass, 'plot_test_pclass')"
    '';
  };

  train_data_csv = makeRDerivation {
    name = "train_data_csv";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        train_data <- readRDS('${train_data}/train_data')
        train_data_csv <- train_data
        data.table::fwrite(train_data_csv, 'train_data_csv')"
    '';
  };

  test_data_csv = makeRDerivation {
    name = "test_data_csv";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      Rscript -e "
        source('libraries.R')
        test_data <- readRDS('${test_data}/test_data')
        test_data_csv <- test_data
        data.table::fwrite(test_data_csv, 'test_data_csv')"
    '';
  };

  preprocess_train_step = makePyDerivation {
    name = "preprocess_train_step";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${train_data_csv}/train_data_csv', 'rb') as f: train_data_csv = pickle.load(f)
exec('preprocess_train_step = df = pd.read_csv(f\'{train_data_csv}/train_data_csv\'); preprocess_dataframe(df, is_train=True)')
with open('preprocess_train_step', 'wb') as f: pickle.dump(globals()['preprocess_train_step'], f)
"
    '';
  };

  py_processed_train = makePyDerivation {
    name = "py_processed_train";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${preprocess_train_step}/preprocess_train_step', 'rb') as f: preprocess_train_step = pickle.load(f)
exec('py_processed_train = preprocess_train_step[0]')
with open('py_processed_train', 'wb') as f: pickle.dump(globals()['py_processed_train'], f)
"
    '';
  };

  train_stats = makePyDerivation {
    name = "train_stats";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${preprocess_train_step}/preprocess_train_step', 'rb') as f: preprocess_train_step = pickle.load(f)
exec('train_stats = preprocess_train_step[1]')
with open('train_stats', 'wb') as f: pickle.dump(globals()['train_stats'], f)
"
    '';
  };

  py_processed_test = makePyDerivation {
    name = "py_processed_test";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${test_data_csv}/test_data_csv', 'rb') as f: test_data_csv = pickle.load(f)
with open('${train_stats}/train_stats', 'rb') as f: train_stats = pickle.load(f)
exec('py_processed_test = df = pd.read_csv(f\'{test_data_csv}/test_data_csv\'); preprocess_dataframe(df, is_train=False, train_stats=train_stats)')
with open('py_processed_test', 'wb') as f: pickle.dump(globals()['py_processed_test'], f)
"
    '';
  };

  split_train_data = makePyDerivation {
    name = "split_train_data";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${py_processed_train}/py_processed_train', 'rb') as f: py_processed_train = pickle.load(f)
exec('split_train_data = split_predictors_target(py_processed_train)')
with open('split_train_data', 'wb') as f: pickle.dump(globals()['split_train_data'], f)
"
    '';
  };

  predictors_train_py = makePyDerivation {
    name = "predictors_train_py";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${split_train_data}/split_train_data', 'rb') as f: split_train_data = pickle.load(f)
exec('predictors_train_py = split_train_data[0]')
with open('predictors_train_py', 'wb') as f: pickle.dump(globals()['predictors_train_py'], f)
"
    '';
  };

  target_train_py = makePyDerivation {
    name = "target_train_py";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${split_train_data}/split_train_data', 'rb') as f: split_train_data = pickle.load(f)
exec('target_train_py = split_train_data[1]')
with open('target_train_py', 'wb') as f: pickle.dump(globals()['target_train_py'], f)
"
    '';
  };

  predictors_train_final = makePyDerivation {
    name = "predictors_train_final";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${predictors_train_py}/predictors_train_py', 'rb') as f: predictors_train_py = pickle.load(f)
exec('predictors_train_final = predictors_train_py.drop(\'PassengerId\', axis=1, errors=\'ignore\')')
with open('predictors_train_final', 'wb') as f: pickle.dump(globals()['predictors_train_final'], f)
"
    '';
  };

  train_val_split_data = makePyDerivation {
    name = "train_val_split_data";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${target_train_py}/target_train_py', 'rb') as f: target_train_py = pickle.load(f)
with open('${predictors_train_final}/predictors_train_final', 'rb') as f: predictors_train_final = pickle.load(f)
exec('train_val_split_data = train_test_split(predictors_train_final, target_train_py, test_size=0.2, random_state=0)')
with open('train_val_split_data', 'wb') as f: pickle.dump(globals()['train_val_split_data'], f)
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
with open('${train_val_split_data}/train_val_split_data', 'rb') as f: train_val_split_data = pickle.load(f)
exec('X_train = train_val_split_data[0]')
with open('X_train', 'wb') as f: pickle.dump(globals()['X_train'], f)
"
    '';
  };

  X_val = makePyDerivation {
    name = "X_val";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${train_val_split_data}/train_val_split_data', 'rb') as f: train_val_split_data = pickle.load(f)
exec('X_val = train_val_split_data[1]')
with open('X_val', 'wb') as f: pickle.dump(globals()['X_val'], f)
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
with open('${train_val_split_data}/train_val_split_data', 'rb') as f: train_val_split_data = pickle.load(f)
exec('y_train = train_val_split_data[2]')
with open('y_train', 'wb') as f: pickle.dump(globals()['y_train'], f)
"
    '';
  };

  y_val = makePyDerivation {
    name = "y_val";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${train_val_split_data}/train_val_split_data', 'rb') as f: train_val_split_data = pickle.load(f)
exec('y_val = train_val_split_data[3]')
with open('y_val', 'wb') as f: pickle.dump(globals()['y_val'], f)
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
exec('model = RandomForestClassifier(random_state=42).fit(X_train, y_train)')
with open('model', 'wb') as f: pickle.dump(globals()['model'], f)
"
    '';
  };

  y_pred_val = makePyDerivation {
    name = "y_pred_val";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${X_val}/X_val', 'rb') as f: X_val = pickle.load(f)
with open('${model}/model', 'rb') as f: model = pickle.load(f)
exec('y_pred_val = model.predict(X_val)')
with open('y_pred_val', 'wb') as f: pickle.dump(globals()['y_pred_val'], f)
"
    '';
  };

  validation_accuracy = makePyDerivation {
    name = "validation_accuracy";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${y_val}/y_val', 'rb') as f: y_val = pickle.load(f)
with open('${y_pred_val}/y_pred_val', 'rb') as f: y_pred_val = pickle.load(f)
exec('validation_accuracy = accuracy_score(y_val, y_pred_val)')
with open('validation_accuracy', 'wb') as f: pickle.dump(globals()['validation_accuracy'], f)
"
    '';
  };

  test_ids_py = makePyDerivation {
    name = "test_ids_py";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${py_processed_test}/py_processed_test', 'rb') as f: py_processed_test = pickle.load(f)
exec('test_ids_py = py_processed_test[\'PassengerId\']')
with open('test_ids_py', 'wb') as f: pickle.dump(globals()['test_ids_py'], f)
"
    '';
  };

  py_test_features = makePyDerivation {
    name = "py_test_features";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${py_processed_test}/py_processed_test', 'rb') as f: py_processed_test = pickle.load(f)
exec('py_test_features = py_processed_test.drop(\'PassengerId\', axis=1, errors=\'ignore\')')
with open('py_test_features', 'wb') as f: pickle.dump(globals()['py_test_features'], f)
"
    '';
  };

  test_predictions = makePyDerivation {
    name = "test_predictions";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${model}/model', 'rb') as f: model = pickle.load(f)
with open('${py_test_features}/py_test_features', 'rb') as f: py_test_features = pickle.load(f)
exec('test_predictions = model.predict(py_test_features)')
with open('test_predictions', 'wb') as f: pickle.dump(globals()['test_predictions'], f)
"
    '';
  };

  output_df = makePyDerivation {
    name = "output_df";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${test_ids_py}/test_ids_py', 'rb') as f: test_ids_py = pickle.load(f)
with open('${test_predictions}/test_predictions', 'rb') as f: test_predictions = pickle.load(f)
exec('output_df = pd.DataFrame({\'PassengerId\': test_ids_py, \'Survived\': test_predictions})')
with open('output_df', 'wb') as f: pickle.dump(globals()['output_df'], f)
"
    '';
  };

  result_csv = makePyDerivation {
    name = "result_csv";
    buildInputs = defaultBuildInputs;
    configurePhase = defaultConfigurePhase;
    buildPhase = ''
      python -c "
exec(open('libraries.py').read())
with open('${output_df}/output_df', 'rb') as f: output_df = pickle.load(f)
exec('result_csv = output_df')
write_dataframe_to_csv(globals()['result_csv'], 'result_csv')
"
    '';
  };

  # Generic default target that builds all derivations
  allDerivations = defaultPkgs.symlinkJoin {
    name = "all-derivations";
    paths = with builtins; attrValues { inherit train_data test_data processed_train processed_test plot_train_sex plot_test_pclass train_data_csv test_data_csv preprocess_train_step py_processed_train train_stats py_processed_test split_train_data predictors_train_py target_train_py predictors_train_final train_val_split_data X_train X_val y_train y_val model y_pred_val validation_accuracy test_ids_py py_test_features test_predictions output_df result_csv; };
  };

in
{
  inherit train_data test_data processed_train processed_test plot_train_sex plot_test_pclass train_data_csv test_data_csv preprocess_train_step py_processed_train train_stats py_processed_test split_train_data predictors_train_py target_train_py predictors_train_final train_val_split_data X_train X_val y_train y_val model y_pred_val validation_accuracy test_ids_py py_test_features test_predictions output_df result_csv;
  default = allDerivations;
}
