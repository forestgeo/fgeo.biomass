#' Evaluate equations, giving a biomass result per row.
#'
#' @param .data A dataframe as those created with [pick_best_equations()].
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
#'   pick_best_equations()
#'
#' evaluate_equations(best)
evaluate_equations <- function(.data) {
  .biomass <- purrr::map2_dbl(
    .data$eqn, .data$dbh,
    ~eval(parse(text = .x), envir = list(dbh = .y))
  )
  dplyr::mutate(.data, biomass = .biomass)
}
