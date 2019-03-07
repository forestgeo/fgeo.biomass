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
#' census <- dplyr::sample_n(fgeo.biomass::scbi_tree1, 30)
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

  abort_if_not_eqn(eqn)

  eqn_ <- eqn %>%
    purrr::modify_at(c("dbh_unit", "bms_unit"), fixme_units) %>%

    warn_if_dropping_invalid_units() %>%
    dplyr::filter(!"FIXME" %in% .data$dbh_unit) %>%
    dplyr::filter(!"FIXME" %in% .data$bms_unit) %>%

    # FIXME: Warn that these rows are being dropped
    # FIXME: Should instead be replaced with more general equations
    # (https://github.com/forestgeo/allodb/issues/72)
    dplyr::filter(!is.na(.data$eqn_type)) %>%
    # FIXME: Do we need to group at all?
    dplyr::group_by(.data$eqn_type) %>%
    tidyr::nest()

  join_vars <- c("sp", "site")
  inform(glue("Joining, by = {rlang::expr_text(join_vars)}"))
  result <- eqn_ %>%
    dplyr::mutate(
      data = purrr::map(.data$data, ~ get_this_eqn(.x, dbh_species, join_vars))
    ) %>%
    tidyr::unnest()

  n_in <- nrow(dbh_species)
  n_out <- nrow(result)
  if (!identical(n_in, n_out)) {
    warn(glue("
      The input and output datasets have different number of rows:
      * Input: {n_in}.
      * Output: {n_out}.
    "))
  }

  safe_convert_units <- purrr::safely(
    measurements::conv_unit, otherwise = NA_real_
  )
  dbh_converted <- result %>%
    dplyr::transmute(x = .data$dbh, from = "cm", to = .data$dbh_unit) %>%
    purrr::pmap(safe_convert_units) %>%
    purrr::transpose() %>%
    purrr::simplify_all() %>%
    purrr::pluck("result")

  result$dbh <- dbh_converted

  if (sum(dbh_converted) > 0) {
    warn(
      glue(
        "Dropping {sum(is.na(dbh_converted))} rows where units can't be converted"
      )
    )
  }

  dplyr::filter(result, !is.na(.data$dbh))
}

warn_if_dropping_invalid_units <- function(x) {
  invalid_dbh <- sum(x$dbh_unit %in% "FIXME")
  invalid_bms <- sum(x$bms_unit %in% "FIXME")
  if (invalid_dbh) warn("Dropping {invalid_dbh} rows with invalid dbh units")
  if (invalid_bms) warn("Dropping {invalid_bms} rows with invalid dbh units")

  invisible(x)
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
