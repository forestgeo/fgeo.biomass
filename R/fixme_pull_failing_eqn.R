fixme_pull_failing_eqn_impl <- function(data) {
  funs <- c(eval_eqn, format_eqn)
  funs %>%
    purrr::map(~failing_eqn(data, .x)) %>%
    unlist() %>%
    unique()
}

#' Failing equations, that can't be evaluated.
#'
#' @param data An __allodb__ equations-table (e.g. allodb::master_tidy()).
#' @family internal functions that flag issues to be fixed
#'
#' @return A character vector.
#' @export
#'
#' @examples
#' fixme_pull_failing_eqn(allodb::master_tidy())
fixme_pull_failing_eqn <- memoise::memoise(fixme_pull_failing_eqn_impl)

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
