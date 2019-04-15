inform_if_guessed_dbh_unit <- function(dbh_unit) {
  if (inherits(dbh_unit, "guessed")) {
    ui_done("Guessing {ui_field('dbh')} in [{dbh_unit}].")
    ui_info(
      "You may provide the {ui_field('dbh')} unit manually via the argument\\
      {ui_code('dbh_unit')}."
    )
  }
  invisible(dbh_unit)
}

pull_region <- function(region, regions) {
  stopifnot(length(region) == 1)
  grep(region, regions, value = TRUE, ignore.case = TRUE)
}

pull_chr <- function(x, pattern) {
  grep(pattern, x, value = TRUE, ignore.case = TRUE)
}

inform_new_columns <- function(new, old) {
  cols <- ui_field(setdiff(names(new), names(old)))
  ui_done(
  "Adding new columns:
    {cols}"
  )
}

collapse_single_quote <- function(x) {
  glue::glue_collapse(glue::single_quote(x), ", ")
}

matches_string <- function(x, string) {
  grepl(surround_not_alnum(string), x)
}

# surround_not_alnum("dbh")
surround_not_alnum <- function(x) {
  paste0("[^[:alnum:]]+", x, "[^[:alnum:]]+")
}

# is_shrub(c("Tree", "Shrub", "Shrub, small tree", "Tree or Shrub", NA))
is_shrub <- function(x) {
  grepl("shrub", x, ignore.case = TRUE)
}

has_multiple_stems <- function(data) {
  check_crucial_names(low(data), c("treeid", "stemid"))

  by_treeid <- group_by(low(data), .data$treeid)
  n_stemid_per_treeid <- mutate(
    by_treeid, n = dplyr::n_distinct(.data$stemid)
  )$n
  any(n_stemid_per_treeid > 1)
}

low <- function(x) {
  rlang::set_names(x, tolower)
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
