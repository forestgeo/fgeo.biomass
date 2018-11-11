#' Evaluate equations, giving a biomass result per row.
#'
#' @param .data A dataframe as those created with [allo_order()].
#'
#' @family functions to manipulate equations
#'
#' @return A dataframe with a single row by each value of `rowid`.
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' best <- allodb::scbi_tree1 %>%
#'   add_species(allodb::scbi_species, "scbi") %>%
#'   allo_find() %>%
#'   allo_order()
#'
#' allo_evaluate(best)
allo_evaluate <- function(.data) {
  .biomass <- purrr::map2_dbl(
    .data$eqn, .data$dbh,
    ~eval(parse(text = .x), envir = list(dbh = .y))
  )
  dplyr::mutate(.data, biomass = .biomass)
}
