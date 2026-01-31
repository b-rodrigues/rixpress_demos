# Decorated (recorded) functions using chronicler
# These functions capture errors and warnings instead of failing

library(chronicler)

# Record standard functions for use in the pipeline
r_filter <- record(dplyr::filter)
r_select <- record(dplyr::select)
r_sqrt <- record(sqrt)
r_mean <- record(mean)

# A helper to extract mean from a data frame column
get_mean_mpg <- function(df) {
 r_mean(df$mpg)
}
