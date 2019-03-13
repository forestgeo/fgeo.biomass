allo_find_impl <- function(dbh_species, dbh_unit = "mm", custom_eqn = NULL) {
  inform(glue("Assuming `dbh` data in [{dbh_unit}]."))

  eqn <- custom_eqn %||% fgeo.biomass::default_equations
  abort_if_not_eqn(eqn)
  result <- dplyr::left_join(dbh_species, eqn)

  inform("Converting `dbh` based on `dbh_unit`.")
  result$dbh <- convert_units(
    result$dbh, from = dbh_unit, to = result$dbh_unit
  )

  result
}

#' Find allometric equations in allodb or in a custom equations-table.
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
#' allo_find(census_species, dbh_unit = "cm")
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
allo_find <- memoise::memoise(allo_find_impl)

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
