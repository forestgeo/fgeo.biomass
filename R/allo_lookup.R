#' Look up in __allodb__ information about each `equation_id`.
#'
#' @param .data A dataframe with columns `rowid` and `equation_id`
#' @param allodb A table from allodb.
#'
#' @family functions to manipulate equations
#'
#' @return A dataframe.
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
#'   fixme_pick_one_row_by_rowid()
#'
#' ids <- add_equations(census, single_best)
#' allo_lookup(ids)
allo_lookup <- function(.data, allodb = allodb::equations) {
  check_crucial_names(.data, c("rowid", "equation_id"))

  ids <- dplyr::select(.data, .data$rowid, .data$equation_id)
  out <- dplyr::left_join(ids, allodb)

  dplyr::select(out, .data$rowid, .data$equation_id, dplyr::everything())
}
