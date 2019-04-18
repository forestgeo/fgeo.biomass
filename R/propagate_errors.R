#' Propagate errors in above-ground biomass (AGB).
#'
#' This functions is warps [BIOMASS::AGBmonteCarlo()], which you may use
#' directly for more options.
#'
#' @inherit BIOMASS::AGBmonteCarlo
#'
#' @param data The output of [add_tropical_biomass()].
#' @inheritParams BIOMASS::AGBmonteCarlo
#' @param dbh_sd This variable can take three kind of values, indicating how to
#'   propagate the errors on diameter measurements: a single numerical value or
#'   a vector of the same size as D, both representing the standard deviation
#'   associated with the diameter measurements or "chave2004" (an important
#'   error on 5 percent of the measures, a smaller error on 95 percent of the
#'   trees).
#' @param height_model Model used to estimate tree height from tree diameter
#'   (output from [model_height()], see example).
#' @return A list with the following elements:
#'  * `meanAGB`: Mean stand AGB value following the error propagation.
#'  * `medAGB`: Median stand AGB value following the error propagation.
#'  * `sdAGB`: Standard deviation of the stand AGB value following the error
#'  propagation.
#'  * `credibilityAGB`: Credibility interval at 95% of the stand AGB value
#'  following the error propagation.
#'  * `AGB_simu`: Matrix with the AGB of the trees (rows) times the n iterations
#'  (columns).
#'
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' data <- fgeo.biomass::scbi_tree1 %>%
#'   slice(1:100)
#' species <- fgeo.biomass::scbi_species
#'
#' # Using `region` (default)
#' biomass <- add_tropical_biomass(data, species)
#' model <- model_height(biomass)
#' str(
#'   propagate_errors(biomass, n = 50, height_model = model)
#' )
#'
#' # Using `latitude` and `longitude`
#' biomass <- add_tropical_biomass(
#'   data = data,
#'   species = species,
#'   latitude = 4,
#'   longitude = -52
#' )
#'
#' model <- model_height(biomass)
#'
#' str(out)
#' # Asks to confirm using the model instead of coordinates
#' if (interactive()) {
#'   str(
#'     propagate_errors(biomass, n = 50, height_model = model)
#'   )
#' }
propagate_errors <- function(data,
                             n = 1000,
                             dbh_sd = NULL,
                             height_model = NULL) {
  check_crucial_names(data, c("dbh", "wd_mean", "wd_sd"))

  if (is.null(height_model) &&
      suppressWarnings(!has_coordinates(data$latitude, data$longitude))) {
    ui_stop(
      "Must provide a {ui_code('height_model')} or {ui_code('data')} \\
      must include {ui_field('latitude')} and {ui_field('longitude')}."
    )
  }

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

  inform_propagating_errors("wood density")

  if (!is.null(dbh_sd)) {
    inform_propagating_errors("diameter")
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

    inform_propagating_errors("height")
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

inform_propagating_errors <- function(x) {
  ui_done("Propagating errors on measurements of {x}.")
}

