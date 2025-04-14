#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

#' @return
#' @author njtierney
#' @export
get_example_rast <- function() {
  # Create a SpatRaster from scratch
  x <- rast(nrows = 108, ncols = 21, xmin = 0, xmax = 10)

  # Create a SpatRaster from a file
  f <- system.file("ex/elev.tif", package = "terra")
  r <- rast(f)
  r
}

#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

#' @return
#' @author njtierney
#' @export
get_example_shapefile <- function() {
  f <- system.file("ex/lux.shp", package = "terra")
  v <- vect(f)
  v
}

#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param country
#' @return
#' @author njtierney
#' @export
get_gadm_country <- function(country = "Australia") {
  dir.create("data/shapefiles", recursive = TRUE, showWarnings = FALSE)
  gadm(
    country = country,
    level = 0,
    path = "data/shapefiles",
    version = "4.1",
    # low res
    resolution = 2
  )
}

cgaz_country <- function(country_name) {
  cgaz_source <- sds::CGAZ()
  cgaz_query <- sds::CGAZ_sql(country_name)

  v <- vect(
    x = cgaz_source,
    query = cgaz_query
  )

  v
}
