allo_find_impl <- function(data, custom_eqn = NULL) {
  eqn <- custom_eqn %||%
    suppressMessages(fgeo.biomass::default_eqn(allodb::master_tidy()))
  abort_if_not_eqn(eqn)

  warn_if_species_missmatch(data, eqn)
  .by <- c("sp", "site")
  message("Joining, by = ", paste0(.by, collapse = ', '), ".")
  dplyr::left_join(data, eqn, by = .by)
}

warn_if_species_missmatch <- function(data, eqn) {
  to_match <- data[["sp"]]
  available <- unique(eqn[eqn$site %in% unique(data$site), , drop = FALSE]$sp)
  .matching <- to_match %in% available

  if (sum(!.matching) > 0) {
    missmatching <- paste0(sort(unique(to_match[!.matching])), collapse = ", ")
    warn(glue("
      Can't find equations matching these species \\
      (inserting {sum(!.matching)} missing values):
      {missmatching}
      "))
  }

  invisible(data)
}

#' Find allometric equations in allodb or in a custom equations-table.
#'
#' @param data A dataframe as those created with [add_species()].
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
