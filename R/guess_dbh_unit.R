#' Guess `dbh` units based on minimum and maximum values of `dbh`.
#'
#' @param x A numeric vector.
#'
#' @return A length-1 character string.
#' @export
#'
#' @examples
#' # Case when
#' # min(x, na.rm = TRUE) < 1.1 &&
#' # max(x, na.rm = TRUE) < 500
#' guess_dbh_unit(c(1.0, 100))
#'
#' # min is too large
#' try(guess_dbh_unit(c(1.2, 499)))
#' # max is too large
#' try(guess_dbh_unit(c(1.0, 501)))
#' # min is too large and max is too large
#' try(guess_dbh_unit(c(1.2, 501)))
#'
#'
#'
#' # Case when
#' # min(x, na.rm = TRUE) > 9 &&
#' # max(x, na.rm = TRUE) > 500
#' guess_dbh_unit(c(9.1, 500.1))
#'
#' # min is too small
#' try(guess_dbh_unit(c(8.9, 500.1)))
#' # max is too small
#' try(guess_dbh_unit(c(9.1, 500)))
#' # min is too small and max is too small
#' try(guess_dbh_unit(c(8.9, 500)))
guess_dbh_unit <- function(x) {
  if (all(is.na(x))) {
    abort("Can't guess `dbh` units.")
  }

  if (!is.numeric(x)) {
    abort("`x` must be numeric.")
  }

  if (min(x, na.rm = TRUE) < 1.1 && max(x, na.rm = TRUE) < 500) {
    return("cm")
  }

  if (min(x, na.rm = TRUE) > 9 && max(x, na.rm = TRUE) > 500) {
    return("mm")
  }

  abort("Can't guess `dbh` units.")
}
