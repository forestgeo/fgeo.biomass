#' Add allometric equations to a census dataset.
#'
#' This function adds columns to uniquely identify each row of a census dataset,
#' and each equation from __allodb__ -- so you can look it up on the database.
#'
#' @param census A ForestGEO-like census dataframe.
#' @param equations An equations dataframe with unique `rowid`s.
#'
#' @family functions to manipulate equations
#'
#' @return A dataframe with all columns from `census` plus additional columns
#'   `rowid`, `eqn` `equation_id`.
#' @export
#'
#' @examples
#' census <- fgeo.biomass::scbi_tree1
#' species <- fgeo.biomass::scbi_species
#'
#' single_best <- census %>%
#'   add_species(species, site = "scbi") %>%
#'   allo_find() %>%
#'   allo_order() %>%
#'   fixme_drop_duplicated_rowid()
#'
#' add_equations(census, single_best)
add_equations <- function(census, equations) {
  duplicated_rowid <- nrow(fixme_find_duplicated_rowid(equations)) > 0
  if (duplicated_rowid) {
    abort("Can't deal duplicated rowid. See ?fixme_find_duplicated_rowid()")
  }

  if (rlang::has_name(census, "rowid")) {
    abort("`rowid` already exists.\n  Remove `rowid` from `census` and retry.")
  }

  .census <- tibble::rowid_to_column(census)
  dplyr::left_join(.census, equations[c("rowid", "eqn", "equation_id")])
}
