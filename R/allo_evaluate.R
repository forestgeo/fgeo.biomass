allo_evaluate_impl <- function(data, to) {
  .biomass <- purrr::map2(data$eqn, data$dbh, ~safe_eval_dbh(.x, .y))
  result <- dplyr::mutate(data, biomass = purrr::map_dbl(.biomass, "result"))
  result$biomass <- convert_units(
    result$biomass, from = result$bms_unit, to = to
  )
  warn_if_errors(.biomass, "Can't evaluate all equations")
  result
}

eval_dbh <- function(text, dbh) {
  eval(parse(text = text), envir = list(dbh = dbh))
}
safe_eval_dbh <- purrr::safely(eval_dbh, otherwise = NA_real_)

allo_evaluate_memoised <- memoise::memoise(allo_evaluate_impl)

#' Evaluate equations, giving a biomass result per row.
#'
#' @param data A dataframe as those created with [allo_find()].
#' @param output_units Character string giving the output unit e.g. "kg".
#' @family functions to manipulate equations
#'
#' @return A dataframe with a single row by each value of `rowid`.
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' best <- fgeo.biomass::scbi_tree1 %>%
#'   # Pick few rows for a quick example
#'   sample_n(1000) %>%
#'   add_species(fgeo.biomass::scbi_species, "scbi") %>%
#'   allo_find()
#'
#' allo_evaluate(best)
allo_evaluate <- function(data, output_units = "kg") {
  inform_expected_units()

  inform(glue("`biomass` values are given in [{output_units}]."))
   out <- allo_evaluate_memoised(data, output_units)

  warn("
    `biomass` may be invalid.
    We still don't suppor the ability to select dbh-specific equations
    (see https://github.com/forestgeo/fgeo.biomass/issues/9).
  ")

  by_rowid <- group_by(out, .data$rowid)
  summarize(by_rowid, biomass = sum(.data$biomass))
}

inform_expected_units <- function() {
  inform(
    glue(
      "Assuming `dbh` units in [cm] \\
      (to convert units see `?measurements::conv_unit()`)."
    )
  )
}
