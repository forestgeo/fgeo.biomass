#' Find equations that can't be evaluated.
#'
#' @param .data An __allodb__ equations-table (e.g. allodb::master()).
#' @family internal objects that will be hidden or removed
#'
#' @return A character vector.
#' @export
#'
#' @examples
#' bad_eqn_id(allodb::master())
bad_eqn_id <- function(.data) {
  funs <- c(eval_eqn, format_eqn)
  funs %>%
    purrr::map(~bad_eqn(.data, .x)) %>%
    unlist() %>%
    unique()
}

bad_eqn <- function(.data, .f) {
  ok <- purrr::quietly(purrr::map_lgl)(some_error(.data, .f), is.null)$result
  unique(.data[!ok, ][["equation_id"]])
}

some_error <- function(.data, .f) {
  suppressWarnings({
    .data %>%
      dplyr::pull("equation_allometry") %>%
      purrr::map(purrr::safely(.f)) %>%
      purrr::transpose() %>%
      purrr::pluck("error")
  })
}

eval_eqn <- function(txt) {
  out <- eval(parse(text = txt), envir = list(dbh = 10))
  if (is.nan(out)) stop("Bad equation", call. = FALSE)
}

format_eqn <- function(text) {
  formatR::tidy_source(text = text)$text.tidy
}
