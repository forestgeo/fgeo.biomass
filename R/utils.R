prefer_false <- function(x) {
  stopifnot(is.logical(x))
  if (all(x[!is.na(x)])) {
    x
  } else {
    !x
  }
}

replace_na <- function(x, replacement) {
  x[is.na(x)] <- replacement
  x
}

is_in_range <- function(x, min, max) {
  x >= min & x <= max
}

warn_odd_dbh <- function(x) {
  min_dbh <- min(x, na.rm = TRUE)
  out_of_range <- !min_dbh >= 10 || !min_dbh < 100
  if (out_of_range) {
    warn(glue("
      `dbh` should be in [mm] (suspicious minimum `dbh`: {min_dbh}).
      Do you need to convert `dbh` units with `measurements::conv_unit()`?
    "))
  }

  invisible(x)
}

warn_if_errors <- function(x, problem) {
  non_null <- x %>%
    purrr::transpose() %>%
    purrr::pluck("error") %>%
    purrr::discard(is.null)

  if (any(purrr::map_lgl(non_null, ~ rlang::has_name(.x, "message")))) {
    error_msg <- non_null %>%
      purrr::map_chr("message") %>%
      unique() %>%
      glue::glue_collapse(sep = "\n")

    warn(
      glue(
        "{problem} \\
        (inserting {length(non_null)} missing values):
        {error_msg}"
      )
      )
  }

  invisible(x)
}

eval_eqn <- function(txt) {
  out <- eval(parse(text = txt), envir = list(dbh = 10))
  if (is.nan(out)) stop("Bad equation", call. = FALSE)
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

format_eqn <- function(text) {
  formatR::tidy_source(text = text)$text.tidy
}

fixme_pull_failing_eqn_impl <- function(data) {
  funs <- c(eval_eqn, format_eqn)
  funs %>%
    purrr::map(~failing_eqn(data, .x)) %>%
    unlist() %>%
    unique()
}



#' Failing equations, that can't be evaluated.
#'
#' This is a temporary helper to quickly see what equations are still failing.
#'
#' @param data An __allodb__ equations-table (e.g. allodb::master_tidy()).
#'
#' @return A character vector.
#'
#' @examples
#' fixme_pull_failing_eqn(allodb::master_tidy())
#' @noRd
fixme_pull_failing_eqn <- memoise::memoise(fixme_pull_failing_eqn_impl)

failing_eqn <- function(data, .f) {
  ok <- purrr::quietly(purrr::map_lgl)(some_error(data, .f), is.null)$result
  unique(data[!ok, ][["equation_id"]])
}

