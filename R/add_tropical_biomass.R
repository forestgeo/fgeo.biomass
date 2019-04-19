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
#' library(dplyr)
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
  check_add_tropical_biomass(
    data = data,
    species = species,
    latitude = latitude,
    longitude = longitude,
    region = region,
    dbh_unit = dbh_unit
  )

  inform_if_guessed_dbh_unit(dbh_unit)

  if (!identical(unclass(dbh_unit), "cm")) {
    data$dbh <- convert_units(data$dbh, from = dbh_unit, to = "cm")
  }

  out <- add_wood_density(data, species)

  if (!has_coordinates(latitude, longitude)) {
    ui_done("Using {ui_value(region)} {ui_code('region')}.")

    out$biomass <- BIOMASS::computeAGB(
      out$dbh,
      WD = out$wd_mean,
      H = get_height_list(out, region = region)$H
    )
  } else {
    ui_done(
      "Using {ui_code('latitude')} and {ui_code('longitude')} \\
      (ignoring {ui_code('region')})."
    )
    out$latitude <- latitude
    out$longitude <- longitude

    if (!all(is_tropical(out$latitude))) {
      ui_warn("All {ui_code('latitude')} values should be tropical.")
    }

    if (!can_find_bioclimatic_params(out$latitude, out$longitude)) {
      ui_stop(
        "Invalid values of {ui_field('latitude')} and/or \\
        {ui_field('longitude')}."
      )
      ui_todo(
        "Ensure your coordinates work with \\
        {ui_code('BIOMASS::getBioclimParam()')}."
      )
    }

    out$biomass <- BIOMASS::computeAGB(
      out$dbh,
      WD = out$wd_mean,
      coord = out[c("longitude", "latitude")]
    )
  }

  inform("Biomass is given in [kg].")
  out$biomass <- convert_units(out$biomass, from = "Mg", to = "kg")

  inform_new_columns(out, data)
  tibble::as_tibble(out)
}

check_add_tropical_biomass <- function(data,
                                       species,
                                       latitude,
                                       longitude,
                                       region,
                                       dbh_unit) {
  force(data)
  force(species)

  check_crucial_names(data, c("dbh"))

  # Check region and coordinates
  if (!has_coordinates(latitude, longitude) && is.null(region)) {
    usethis::ui_stop(
      "`region` or both `latitude` and `longitude` must be non-NULL"
    )
  }

  if (!is.null(region)) {
    if (!length(region) == 1L) {
      usethis::ui_stop("`region` must be a single character string.")
    }

    if (!any(grepl(region, height_regions(), ignore.case = TRUE))) {
      usethis::ui_stop(
        "`region` ({usethis::ui_value(region)}) must be one of these:
          {usethis::ui_field(height_regions())}"
      )
    }
  }

  if (!length(dbh_unit) == 1L) {
    usethis::ui_stop("`dbh_unit` must be a single character string.")
  }
}

has_coordinates <- function(latitude, longitude) {
  !is.null(latitude) && !is.null(longitude)
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

