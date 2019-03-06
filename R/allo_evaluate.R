allo_evaluate_impl <- function(data) {
  .biomass <- purrr::map2_dbl(
    data$eqn, data$dbh,
    ~eval(parse(text = .x), envir = list(dbh = .y))
  )
  dplyr::mutate(data, biomass = .biomass)
}
allo_evaluate_memoised <- memoise::memoise(allo_evaluate_impl)

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
allo_evaluate <- function(data) {
  inform_expected_units()
  warn_invalid_biomass()
  allo_evaluate_memoised(data)
}

inform_expected_units <- function() {
  inform(
    glue(
      "Assuming `dbh` units in [cm] \\
      (to convert units see `?measurements::conv_unit()`)."
    )
  )
}

warn_invalid_biomass <- function() {
  warn(
    glue(
      "`biomass` values may be invalid.
      This is work in progress and we still don't handle units correctly."
    )
  )
}
