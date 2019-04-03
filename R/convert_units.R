#' A safe version of `measurements::conv_unit()`.
#'
#' Unlike `measurements::conv_unit()` this function doesn't fail if it can't
#' convert a unit -- instead it outputs NA.
#'
#' @inheritParams measurements::conv_unit
#'
#' @return As in `measurements::conv_unit()` if possible, or NA.
#' @export
#' @family helpers
#'
#' @examples
#' convert_units(c(1, NA), from = "cm", to = "m")
#' # Same
#' measurements::conv_unit(c(1, NA), from = "cm", to = "m")
#'
#' # Passes
#' convert_units(c(1, 10), from = "cm", to = c("m", "bad"))
#' convert_units(c(1, 10), from = "cm", to = c("m", "bad"), quietly = TRUE)
#' # Errs
#' try(measurements::conv_unit(c(1, 10), from = "cm", to = c("m", "bad")))
convert_units <- function(x, from, to, quietly = FALSE) {
  data_ <- tibble::tibble(x, from, to)
  safe_convert <- purrr::safely(measurements::conv_unit, otherwise = NA_real_)

  .result <- purrr::pmap(data_, safe_convert)

  if (!quietly) {
    warn_if_errors(.result, "Can't convert all units")
  }

  .result %>%
    purrr::transpose() %>%
    purrr::simplify_all() %>%
    purrr::pluck("result")
}
