default_eqn_impl <- function(data) {
  passing <- pick_useful_cols_rows(data)
  out <- modify_default_eqn(passing)
  new_eqn(dplyr::as_tibble(out))
}
default_eqn_memoised <- memoise::memoise(default_eqn_impl)

pick_useful_cols_rows <- function(data) {
  crucial_cols <- data[ , allodb_eqn_crucial(), drop = TRUE]
  fixme_exclude_failing_equations(crucial_cols)
}

modify_default_eqn <- function(passing) {
  passing %>%
    dplyr::mutate(
      eqn_source = "default",
      eqn = format_equations(passing$equation_allometry),
      allometry_specificity = gsub(" ", "_", .data$allometry_specificity),
      equation_allometry = NULL,
      anatomic_relevance = .data$dependent_variable_biomass_component
    ) %>%
    dplyr::rename(
      sp = .data$species,
      eqn_type = .data$allometry_specificity,
      dbh_unit = .data$dbh_units_original,
      bms_unit = .data$biomass_units_original
    ) %>%
    # Recover missing values represented as the literal "NA"
    purrr::modify_if(is.character, readr::parse_character) %>%
    # Make it easier to find values (all lowercase)
    purrr::modify_if(is.character, tolower) %>%
    # Order
    dplyr::select(bmss_default_vars()) %>%
    dplyr::filter(stats::complete.cases(.)) %>%
    unique()
}

#' Restructure equations from __allodb__.
#'
#' This function restructures an equations-table from __allodb__ with columns as
#' in [allodb_eqn_crucial()] (e.g. [allodb::master()]). It transforms its input
#' into a default-equations table. Now this function is very
#' strict and intrusive:
#' * It drops problematic equations that can't be evaluated.
#' * It adds and remove columns.
#' * It renames columns.
#' * It transforms text-values to lowercase to simplify matching.
#' * It re-formats the text-representation of equations.
#' * It drops missing values.
#' * It replaces spaces (" ") with underscore ("_") in values of
#' allometry_specificity for easier manipulation.
#'
#' @param data [allodb::master()] or similar.
#'
#' @family internal objects that will be hidden or removed
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' default_eqn(allodb::master())
default_eqn <- function(data) {
  fgeo.tool::check_crucial_names(data, allodb_eqn_crucial())

  passing <- pick_useful_cols_rows(data)
  warn_dropping_failing_equations(data, passing)

  default_eqn_memoised(passing)
}


#' Exclude equations that can't be evaluated.
#'
#' This function tries to evaluate __allodb__ equations and excludes the ones
#' that err.
#'
#' @param data An equations dataframe, e.g. `allodb::master()`.
#'
#' @return A dataframe with all equations that can be successfully evaluated.
#' @export
#' @family internal functions that flag issues to be fixed
#'
#' @examples
#' fixme_exclude_failing_equations(allodb::master())
fixme_exclude_failing_equations <- function(data) {
  exclude_failing_eqn_id <-
    !data$equation_id %in% fixme_pull_failing_eqn(allodb::master())
  data[exclude_failing_eqn_id, , drop = FALSE]
}

warn_dropping_failing_equations <- function(data, out) {
  fgeo.tool::check_crucial_names(data, allodb_eqn_crucial())

  n_drop <- nrow(data) - nrow(out)
  warn(
    glue(
      "Dropping {n_drop} equations that can't be evaluated.
      Identify failing equations with `fixme_pull_failing_eqn(allodb::master())`"
    )
  )

  invisible(data)
}

new_eqn <- function(x) {
  stopifnot(tibble::is.tibble(x))
  if (inherits(x, "eqn")) {
    return(x)
  }

  structure(x, class = c("eqn", class(x)))
}

bmss_default_vars <- function() {
  c("equation_id",
    "site",
    "sp",
    "eqn",
    "eqn_source",
    "eqn_type",
    "anatomic_relevance",
    "dbh_unit",
    "bms_unit"
  )
}

format_equations <- function(eqn) {
  purrr::quietly(formatR::tidy_source)(text = eqn)$result$text.tidy
}

