allo_evaluate_impl <- function(data) {
  warn(glue("
    `biomass` values may be invalid.
    This is work in progress and we still don't handle units correctly.
  "))
  .biomass <- purrr::map2_dbl(
    data$eqn, data$dbh,
    ~eval(parse(text = .x), envir = list(dbh = .y))
  )
  dplyr::mutate(data, biomass = .biomass)
}
#' Evaluate equations, giving a biomass result per row.
#'
#' @param data A dataframe as those created with [allo_find()].
#'
#' @family functions to manipulate equations
#'
#' @return A dataframe with a single row by each value of `rowid`.
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' best <- fgeo.biomass::scbi_tree1 %>%
#'   add_species(fgeo.biomass::scbi_species, "scbi") %>%
#'   allo_find()
#'
#' allo_evaluate(best)
allo_evaluate <- memoise::memoise(allo_evaluate_impl)
