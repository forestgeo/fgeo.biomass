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
