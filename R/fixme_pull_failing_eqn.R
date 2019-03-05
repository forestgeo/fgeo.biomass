#' Failing equations, that can't be evaluated.
#'
#' @param data An __allodb__ equations-table (e.g. allodb::master()).
#' @family internal functions that flag issues to be fixed
#'
#' @return A character vector.
#'
#' @examples
#' fixme_pull_failing_eqn(allodb::master())
#'
#' # We store the result for speed
#' failing_eqn_id
#'
#' @name failing_eqn_id
NULL

#' @rdname failing_eqn_id
#' @export
fixme_pull_failing_eqn <- function(data) {
  funs <- c(eval_eqn, format_eqn)
  funs %>%
    purrr::map(~failing_eqn(data, .x)) %>%
    unlist() %>%
    unique()
}

failing_eqn <- function(data, .f) {
  ok <- purrr::quietly(purrr::map_lgl)(some_error(data, .f), is.null)$result
  unique(data[!ok, ][["equation_id"]])
}

some_error <- function(data, .f) {
  suppressWarnings({
    data %>%
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
