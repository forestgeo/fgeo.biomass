default_eqn_impl <- function(data) {
  out <- data %>%
    pick_useful_cols() %>%
    purrr::modify_at(c("dbh_unit", "bms_unit"), fixme_units) %>%
    modify_default_eqn()

  new_eqn(dplyr::as_tibble(out))
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

  out <- pick_useful_cols(data)
  default_eqn_impl(out)
}

pick_useful_cols <- function(data) {
  crucial_cols <- data[ , allodb_eqn_crucial(), drop = TRUE]
}

modify_default_eqn <- function(out) {
  out %>%
    dplyr::mutate(
      eqn_source = "default",
      eqn = format_equations(out$equation_allometry),
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

