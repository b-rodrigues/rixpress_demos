# Decorated (recorded) functions using chronicler
# These functions capture errors and warnings instead of failing

library(chronicler)

# Record standard functions for use in the pipeline
r_filter <- record(dplyr::filter)
r_pull <- record(dplyr::pull)
r_sqrt <- record(sqrt)
r_mean <- record(mean)

