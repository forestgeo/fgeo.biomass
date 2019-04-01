inform_provide_dbh_units_manually <- function() {
  inform("You may provide the `dbh` unit manually via the argument `dbh_unit`.")
}

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

format_eqn <- function(text) {
  formatR::tidy_source(text = text)$text.tidy
}
