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
#' @param .data [allodb::master()] or similar.
#'
#' @family internal objects that will be hidden or removed
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' default_eqn(allodb::master())
default_eqn <- function(.data) {
  fgeo.tool::check_crucial_names(.data, allodb_eqn_crucial())

  good <- .data[!.data$equation_id %in% .bad_eqn_id , allodb_eqn_crucial()]
  out <- good %>%
    dplyr::mutate(
      eqn_source = "default",
      eqn = format_equations(good$equation_allometry),
      allometry_specificity = gsub(" ", "_", .data$allometry_specificity),
      equation_allometry = NULL
    ) %>%
    dplyr::rename(
      sp = .data$species,
      eqn_type = .data$allometry_specificity
    ) %>%
    # Recover missing values represented as the literal "NA"
    purrr::modify_if(is.character, readr::parse_character) %>%
    # Make it easier to find values (all lowercase)
    purrr::modify_if(is.character, tolower) %>%
    # Order
    dplyr::select(bmss_default_vars()) %>%
    dplyr::filter(stats::complete.cases(.)) %>%
    unique()

  new_default_eqn(dplyr::as_tibble(out))
}

new_default_eqn <- function(x) {
  stopifnot(tibble::is.tibble(x))
  structure(x, class = c("default_eqn", class(x)))
}

bmss_default_vars <- function() {
  c("equation_id", "site", "sp", "eqn", "eqn_source", "eqn_type")
}

format_equations <- function(eqn) {
  purrr::quietly(formatR::tidy_source)(text = eqn)$result$text.tidy
}

