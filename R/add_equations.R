#' Add equations to a census dataset.
#'
#' @param census A ForestGEO-like census dataframe.
#' @param equations An equations dataframe with unique `rowid`s.
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' census <- allodb::scbi_tree1
#' species <- allodb::scbi_species
#'
#' single_best <- census %>%
#'   census_species(species, site = "scbi") %>%
#'   get_equations() %>%
#'   pick_best_equations() %>%
#'   pick_one_row_by_rowid()
#' add_equations(census, single_best)
add_equations <- function(census, equations) {
  duplicated_rowid <- nrow(find_duplicated_rowid(equations)) > 0
  if (duplicated_rowid) {
    abort("Can't deal duplicated rowid. See ?find_duplicated_rowid")
  }

  if (rlang::has_name(census, "rowid")) {
    abort(glue("
      `rowid` already exists.
        Remove `rowid` from `census` and retry"
    ))
  }

  .census <- tibble::rowid_to_column(census)
  dplyr::left_join(.census, equations)
}
