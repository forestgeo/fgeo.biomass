#' Try to convert units to conform with `measurements::conv_unit_options`.
#'
#' `fixme_units()` leaves valid units untouched, fix invalid known units, and
#'   flags invalid unknown units.
#' @param x A character vector of units.
#'
#' @return A character vector.
#' @export
#' @family internal functions that flag issues to be fixed
#' @seealso [valid_units()].
#'
#' @examples
#' x <- c("mm", "cm", "m", "in", "in^2", "cm^2", "BAD")
#' fixme_units(x)
#'
#' unique(
#'   allodb::equations$dbh_units_original
#' )
#'
#' unique(
#'   fixme_units(allodb::equations$dbh_units_original)
#' )
#'
#' unique(
#'   fixme_units(allodb::equations$biomass_units_original)
#' )
fixme_units <- function(x) {
  purrr::map_chr(x, ~ fixme_units_one(.x))
}

#' Valid units as per `measurements::conv_unit_options`.
#'
#' This simply wraps `measurements::conv_unit_options` to provide a more
#' evocative name, closer to the problem domain. You may use this function to
#' know how to name units in a way that ensures that units conversion will be
#' converted correctly.
#'
#' @return A list
#' @export
#' @family helpers
#'
#' @examples
#' valid_units()
valid_units <- function() {
  measurements::conv_unit_options
}

fixme_units_one <- function(x) {
  dplyr::case_when(
    is_valid_unit(x) ~ identity(x),

    identical(x, "in")   ~ "inch",
    identical(x, "in^2") ~ "inch2",
    identical(x, "cm^2") ~ "cm2",
    identical(x, "lb") ~ "lbs",
    identical(x, "t") ~ "metric_ton",

    TRUE ~ "FIXME"
  )
}

is_valid_unit <- function(x) {
  x %in% unname(unlist(valid_units()))
}
