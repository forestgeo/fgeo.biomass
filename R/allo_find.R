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
#'   sp = c("tilia americana"),
#'   # Watning: Fake!
#'   eqn = c("exp(-2.48 + 2.4835 * log(dbh))"),
#'   eqn_type = c("mixed_hardwood"),
#'   anatomic_relevance = c("total aboveground biomass"),
#'  dbh_unit = "cm",
#'  bms_unit = "g"
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
  eqn <- custom_eqn %||% default_equations
  abort_if_not_eqn(eqn)
  result <- join_dbh_species_with_eqn(dbh_species, eqn)
  warn_if_dropped_rows_not_matched_with_equations(dbh_species, result)

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

#' Split equations by eqn_type and inner-join each group with user's data,
#' matching by site and species and dropping NA's, i.e. missmatched.
#'
#' FIXME: eqn_type should only have three values, e.g.:
#' 1. specific
#' 2. generic
#' 3. custom
#' See allodb issue 42
#'
#' This approach seem too complicates. This entire logic may be dramatically
#' simplified once allodb incorporates the generic equations.
#' @noRd
join_dbh_species_with_eqn <- function(dbh_species, eqn) {
  n_eqn_type <- sum(is.na(eqn$eqn_type))
  if (!identical(n_eqn_type, 0L)) {
    warn(
      glue("Dropping {n_eqn_type} rows with missing values of `eqn_type`.")
    )
  }
  eqn_ <- dplyr::filter(eqn, !is.na(.data$eqn_type))

  join_vars <- c("sp", "site")
  inform(glue("Joining, by = {rlang::expr_text(join_vars)}"))
  eqn_ %>%
    dplyr::group_by(.data$eqn_type) %>%
    tidyr::nest() %>%
    dplyr::mutate(
      data = purrr::map(.data$data, ~ get_this_eqn(.x, dbh_species, join_vars))
    ) %>%
    tidyr::unnest()
}

get_this_eqn <- function(.type, dbh_species, join_vars) {
  dplyr::inner_join(dbh_species, .type, by = join_vars) %>%
    dplyr::filter(!is.na(.data$dbh), !is.na(.data$eqn))
}

warn_if_dropped_rows_not_matched_with_equations <- function(input, output) {
  n_in <- nrow(input)
  n_out <- nrow(output)
  if (!identical(n_in, n_out)) {
    warn(glue("
      The input and output datasets have different number of rows:
      * Input: {n_in}.
      * Output: {n_out}.
      "))
  }

  invisible(input)
}
