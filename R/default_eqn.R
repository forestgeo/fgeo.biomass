default_eqn_impl <- function(data) {
  out <- data %>%
    select_useful_cols() %>%
    purrr::modify_at(c("dbh_unit", "bms_unit"), fix_units) %>%
    modify_default_eqn() %>%
    dplyr::select(output_cols())

  new_eqn(dplyr::as_tibble(out))
}

#' Restructure equations from __allodb__.
#'
#' This function restructures an equations-table from __allodb__ with columns as
#' in [allodb_cols()] (e.g. [allodb::master_tidy()]). It transforms its
#' input into a default-equations table. Now this function is very strict and
#' intrusive:
#' * It drops problematic equations that can't be evaluated.
#' * It adds and remove columns.
#' * It renames columns.
#' * It transforms text-values to lowercase to simplify matching.
#' * It re-formats the text-representation of equations.
#' * It drops missing values.
#' * It replaces spaces (" ") with underscore ("_") in values of
#' allometry_specificity for easier manipulation.
#'
#' @param data [allodb::master_tidy()] or similar.
#'
#' @family internal objects that will be hidden or removed
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' default_eqn(allodb::master_tidy())
default_eqn <- function(data) {
  fgeo.tool::check_crucial_names(data, allodb_cols())
  default_eqn_impl(data)
}

select_useful_cols <- function(data) {
  crucial_cols <- data[ , allodb_cols(), drop = TRUE]
  crucial_cols
}

modify_default_eqn <- function(out) {
  out %>%
    dplyr::mutate(
      eqn_id = .data$equation_id,
      eqn_source = "default",
      eqn = format_equations(out$equation_allometry),
      allometry_specificity = gsub(" ", "_", .data$allometry_specificity),
      equation_allometry = NULL,
      anatomic_relevance = .data$dependent_variable_biomass_component,
      dbh_min_mm = measurements::conv_unit(.data$dbh_min_cm, "cm", to = "mm"),
      dbh_max_mm = measurements::conv_unit(.data$dbh_max_cm, "cm", to = "mm"),
      is_generic = dplyr::if_else(
        tolower(.data$equation_group) == "generic", TRUE, FALSE
      )
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
    purrr::modify_if(is.character, tolower)
}

new_eqn <- function(x) {
  stopifnot(tibble::is.tibble(x))
  if (inherits(x, "eqn")) {
    return(x)
  }

  structure(x, class = c("eqn", class(x)))
}

format_equations <- function(eqn) {
  purrr::quietly(formatR::tidy_source)(text = eqn)$result$text.tidy
}

#' Crucial columns from __allodb__ equations-table.
#'
#' @return A string.
#' @export
#' @keywords internal
#'
#' @examples
#' allodb_cols()
allodb_cols <- function() {
  c(
    "equation_id",
    "site",
    "species",
    "equation_allometry",
    "allometry_specificity",
    "dependent_variable_biomass_component",
    "dbh_units_original",
    "biomass_units_original",
    "dbh_min_cm",
    "dbh_max_cm",
    "equation_group",
    "life_form"
  )
}

output_cols <- function() {
  c(
    "eqn_id",
    "site",
    "sp",
    "eqn",
    "eqn_source",
    "eqn_type",
    "anatomic_relevance",
    "dbh_unit",
    "bms_unit",
    "dbh_min_mm",
    "dbh_max_mm",
    "is_generic",
    "life_form"
  )
}
