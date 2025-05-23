library(rixpress)

list(
  rxp_r_file(
    name = train_data,
    path = "data/train.csv",
    read_function = "load_dataset",
  ),

  rxp_r_file(
    name = test_data,
    path = "data/test.csv",
    read_function = "load_dataset",
  ),

  rxp_r(
    name = processed_train,
    expr = pre_process(train_data),
    additional_files = "functions.R"
  ),

  rxp_r(
    name = processed_test,
    expr = pre_process(test_data),
    additional_files = "functions.R"
  ),

  rxp_r(
    name = plot_train_sex,
    expr = bar_plot(
      df = processed_train,
      col = 'Sex',
      insight = 'Train Data Sex Distribution',
      flip = FALSE
    ),
    additional_files = "functions.R"
  ),

  rxp_r(
    name = plot_test_pclass,
    expr = bar_plot(
      df = processed_test,
      col = 'Pclass',
      insight = 'Test Data Pclass Distribution',
      flip = FALSE
    ),
    additional_files = "functions.R"
  )
) |>
  rixpress(build = TRUE)

# dag_for_ci() # Generate DAG image
# rxp_make()   # Manually trigger the build
