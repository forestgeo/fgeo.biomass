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
#' census_species <- add_species(
#'   census, species,
#'   site = "scbi"
#' )
#'
#' allo_find(census_species)
#'
#' # PROVIDE CUSTOM EQUAITONS ----------------------------------------------
#' # Checks that the structure of your data isn't terriby wrong
#' # BAD
#' try(as_eqn("really bad data"))
#' try(as_eqn(data.frame(1)))
#'
#' # GOOD
#' your_equations <- tibble::tibble(
#'   equation_id = c("000001"),
#'   site = c("scbi"),
#'   sp = c("paulownia tomentosa"),
#'   eqn = c("exp(-2.48 + 2.4835 * log(dbh))"),
#'   eqn_type = c("mixed_hardwood"),
#'   anatomic_relevance = c("total aboveground biomass")
#' )
#'
#' class(as_eqn(your_equations))
#'
#' allo_find(census_species, custom_eqn = as_eqn(your_equations))
#'
#' census_species %>%
#' allo_find(custom_eqn = as_eqn(your_equations))
#' @family constructors
allo_find <- function(dbh_species, custom_eqn = NULL) {
  eqn <- custom_eqn %||% default_eqn(allodb::master())

  eqn_ <- eqn %>%
    abort_if_not_eqn() %>%
    dplyr::filter(!is.na(.data$eqn_type)) %>%
    # FIXME: Do we need to group at all?
    dplyr::group_by(.data$eqn_type) %>%
    tidyr::nest()

  join_vars <- c("sp", "site")
  inform(glue("Joining, by = {rlang::expr_text(join_vars)}"))
  eqn_ %>%
    dplyr::mutate(
      data = purrr::map(.data$data, ~get_this_eqn(.x, dbh_species, join_vars))
    ) %>%
    tidyr::unnest()
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

get_this_eqn <- function(.type, dbh_species, join_vars) {
  dplyr::inner_join(dbh_species, .type, by = join_vars) %>%
    dplyr::filter(!is.na(.data$dbh), !is.na(.data$eqn))
}

add_eqn_type <- function(type_data) {
  types <- type_data$eqn_type
  dplyr::mutate(
    type_data,
    data = purrr::map2(
      .data$data, types,
      ~ tibble::add_column(.x, eqn_type = .y)
    )
  )
}

