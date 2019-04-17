#' Title
#'
#' @param data The output of [add_tropical_biomass()].
#' @inheritParams BIOMASS::AGBmonteCarlo
#' @param dbh_sd This variable can take three kind of values, indicating how to
#'   propagate the errors on diameter measurements: a single numerical value or
#'   a vector of the same size as D, both representing the standard deviation
#'   associated with the diameter measurements or "chave2004" (an important
#'   error on 5 percent of the measures, a smaller error on 95 percent of the
#'   trees).
#' @param height_model
#'
#' @return A list with the following components:
#'  * `meanAGB`: Mean stand AGB value following the error propagation
#'  * `medAGB`: Median stand AGB value following the error propagation
#'  * `sdAGB`: Standard deviation of the stand AGB value following the error propagation
#'  * `credibilityAGB`: Credibility interval at 95% of the stand AGB value following the error propagation
#'  * `AGB_simu`: Matrix with the AGB of the trees (rows) times the n iterations (columns)
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' data <- fgeo.biomass::scbi_tree1 %>%
#'   slice(1:100)
#' species <- fgeo.biomass::scbi_species
#'
#' biomass <- add_tropical_biomass(
#'   data = data,
#'   species = species,
#'   latitude = 4,
#'   longitude = -52
#' )
#'
#' out <- propagete_errors(biomass, n = 50, height_model = NULL)
#' str(out)
propagete_errors <- function(data,
                             n = 1000,
                             dbh_sd = NULL,
                             height_model = NULL) {
  check_crucial_names(data, c("dbh", "wd_mean", "wd_sd"))

  use_coordinates <- FALSE
  if (is.null(height_model) &&
      suppressWarnings(has_coordinates(data$latitude, data$longitude))) {
    use_coordinates <- TRUE
  }

  use_model <- FALSE
  if (!is.null(height_model) &&
      !suppressWarnings(has_coordinates(data$latitude, data$longitude))) {
    use_model <- TRUE
  }

  if (!is.null(height_model) &&
      suppressWarnings(has_coordinates(data$latitude, data$longitude))) {
    usethis::ui_yeah(
      "Either coordinates or a height-diameter model can be used.
      Okay to ignore coordinates in your data? (If not, use \\
      {ui_code('height_model = NULL')})"
    )
    use_model <- TRUE
  }

  if (use_coordinates) {
    check_crucial_names(data, c("wd_mean", "wd_sd", "latitude", "longitude"))
    out <- BIOMASS::AGBmonteCarlo(
      n = n,
      D = data$dbh,
      WD = data$wd_mean,
      errWD = data$wd_sd,
      coord = data[c("longitude", "latitude")],
      Dpropag = dbh_sd
    )
  }

  if (use_model) {
    if (!identical(length(height_model$method), 1L)) {
      ui_stop(
        "{ui_code('height_model')} must have only 1 method (found: \\
         {glue_collapse(height_model$method, sep = ', ')})."
      )
    }

    out <- BIOMASS::AGBmonteCarlo(
      n = n,
      D = data$dbh,
      WD = data$wd_mean,
      errWD = data$wd_sd,
      HDmodel = height_model,
      Dpropag = dbh_sd
    )
  }

  if (all(is.na(out$AGB_simu))) {
    ui_warn("Invalid simulations")
  }

  out
}

