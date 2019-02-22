#' Get default equations of each type.
#'
#' @param dbh_species A dataframe as those created with [add_species()].
#' @param custom_eqn A dataframe of class "eqn".
#'
#' @family functions to manipulate equations
#'
#' @return A nested dataframe with each row containing the data of an equation
#'   type.
#' @export
#'
#' @examples
#' census <- fgeo.biomass::scbi_tree1
#' species <- fgeo.biomass::scbi_species
#' dbh_species <- add_species(
#'   census, species,
#'   site = "scbi"
#' )
#'
#' allo_find(dbh_species)
#' @family constructors
allo_find <- function(dbh_species, custom_eqn = NULL) {
  eqn <- custom_eqn %||% .default_eqn

  eqn %>%
    abort_if_not_eqn() %>%
    dplyr::filter(!is.na(.data$eqn_type)) %>%
    dplyr::group_by(.data$eqn_type) %>%
    tidyr::nest() %>%
    dplyr::mutate(
      data = purrr::map(.data$data, ~get_this_eqn(.x, dbh_species))
    )
}

abort_if_not_eqn <- function(custom_eqn) {
  if (!inherits(custom_eqn, "eqn")) {
    abort(
      glue::glue(
        "`custom_eqn` must be of class 'eqn'. Did you forget to use `as_eqn()`?"
      )
    )
  }

  invisible(custom_eqn)
}

get_this_eqn <- function(.type, dbh_species) {
  dplyr::inner_join(dbh_species, .type, by = c("sp", "site")) %>%
    dplyr::filter(!is.na(.data$dbh), !is.na(.data$eqn))
}

add_eqn_type <- function(type_data) {
  types <- type_data$eqn_type
  dplyr::mutate(
    type_data,
    data = purrr::map2(
      .data$data, types,
      ~tibble::add_column(.x, eqn_type = .y)
    )
  )
}

