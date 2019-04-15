#' Add biomass using allometric equations for tropical trees.
#'
#' This function wraps a number of functions from the
#' [BIOMASS][BIOMASS::BIOMASS-package] package, which you may see for more
#' options and details. It uses pantropical models from Chave et al. 2014 to
#' estimate the above-ground biomass of tropical trees.
#'
#' @inheritParams add_species
#' @inheritParams BIOMASS::retrieveH
#' @template dbh_unit
#' @param latitude,longitude A number giving coordinates, e.g. `latitude =
#'   9.004080`, `longitude = -79.525635`. It can also be a vector of such
#'   numbers, with as many elements as the number of rows of `data`.
#'
#' @return
#' A modified version of the `data` dataframe, with additional columns giving
#' taxonomic, wood density (in g/cm^3), and `biomass` (in kg) information.
#'
#' @seealso [BIOMASS::computeAGB()], [BIOMASS::retrieveH()] [add_wood_density()].
#'
#' @export
#'
#' @references
#' Chave et al. (2014) _Improved allometric models to estimate the aboveground
#' biomass of tropical trees_, Global Change Biology, 20 (10), 3177-3190
#'
#' @examples
#' library(fgeo.biomass)
#'
#' data <- fgeo.biomass::scbi_stem_tiny_tree
#' species <- fgeo.biomass::scbi_species
#'
#' add_tropical_biomass(data, species, region = "pantropical")
#'
#' data %>%
#'   add_tropical_biomass(species, latitude = -34, longitude = -58) %>%
#'   select(biomass, everything())
add_tropical_biomass <- function(data,
                                 species,
                                 region = "Pantropical",
                                 latitude = NULL,
                                 longitude = NULL,
                                 dbh_unit = guess_dbh_unit(data$dbh)) {
  inform_if_guessed_dbh_unit(dbh_unit)

  if (!identical(unclass(dbh_unit), "cm")) {
    data$dbh <- convert_units(data$dbh, from = dbh_unit, to = "cm")
  }

  out <- add_wood_density(data, species)

  has_cordinates <- !is.null(latitude) && !is.null(longitude)
  if (!has_cordinates) {
    if (is.null(region)) {
      abort("Must provide `region`; or `latitude` and `longitude`.")
    }

    out$biomass <- BIOMASS::computeAGB(
      out$dbh,
      WD = out$wd_mean,
      H = get_height_list(out, region = region)$H
    )
  } else {
    inform("Ignoring `region` and using `latitude` and `longitude`.")

    out$latitude <- latitude
    out$longitude <- longitude
    out$biomass <- BIOMASS::computeAGB(
      out$dbh,
      WD = out$wd_mean,
      coord = cbind(out$longitude, out$latitude)
    )
  }

  inform("Biomass is given in [kg].")
  out$biomass <- convert_units(out$biomass, from = "Mg", to = "kg")

  inform_new_columns(out, data)
  tibble::as_tibble(out)
}

get_height_list <- function(data, region = "Pantropical") {
  check_crucial_names(data, "dbh")
  BIOMASS::retrieveH(
    D = data$dbh, region = pull_region(region, height_regions())
  )
}

height_regions <- function() {
  c(
    "Africa",
    "CAfrica",
    "EAfrica",
    "WAfrica",
    "SAmerica",
    "BrazilianShield",
    "ECAmazonia",
    "GuianaShield",
    "WAmazonia",
    "SEAsia",
    "NAustralia",
    "Pantropical"
  )
}
