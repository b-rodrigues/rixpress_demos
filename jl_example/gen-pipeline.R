library(rixpress)
library(igraph)

list(
  rxp_jl(d_size, '150'),

  rxp_jl(
    data,
    "0.1randn(d_size,d_size) + reshape( \
     cholesky(gridlaplacian(d_size,d_size) + 0.003I) \\ randn(d_size*d_size), \
     d_size, \
     d_size \
   )",
    user_functions = "functions.jl"
  ),

  rxp_jl(
    laplace_df,
    'DataFrame(data, :auto)',
    serialize_function = 'arrow_write',
    user_functions = "functions.jl"
  ),

  rxp_r(
    laplace_long_df,
    prepare_data(laplace_df),
    unserialize_function = 'read_ipc_file',
    user_functions = "functions.R"
  ),

  rxp_r(
    gg,
    make_gg(laplace_long_df),
    user_functions = "functions.R"
  ),

  rxp_r(
    dag,
    rxp_visnetwork(),
    additional_files = "_rixpress"
  ),

  rxp_qmd(
    name = julia_doc,
    qmd_file = "document.qmd",
  )
) |>
  rxp_populate(build = TRUE)

rxp_dag_for_ci()

#rxp_make()
