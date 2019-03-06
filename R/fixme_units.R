#' Try to convert units to conform with `measurements::conv_unit_options`.
#' * `valid_units()` is an evocative alias of `measurements::conv_unit_options`.
#' * `fixme_units()` leaves valid units untouched, fix invalid known units, and
#'   flags invalid unknown units.
#' @param x A character vector of units.
#'
#' @return A character vector.
#' @export
#' @family functions to manipulate equations
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
#' # All valid unites
#' valid_units()
fixme_units <- function(x) {
  purrr::map_chr(x, ~ fixme_units_one(.x))
}

#' @rdname fixme_units
#' @export
valid_units <- function() {
  measurements::conv_unit_options
}

fixme_units_one <- function(x) {
  dplyr::case_when(
    is_valid_unit(x) ~ identity(x),
    identical(x, "in")   ~ "inch",
    identical(x, "in^2") ~ "inch2",
    identical(x, "cm^2") ~ "cm2",
    TRUE ~ "FIXME: Unknown unit"
  )
}

is_valid_unit <- function(x) {
  x %in% unname(unlist(valid_units()))
}
