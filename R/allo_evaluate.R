allo_evaluate_impl <- function(data, dbh_unit, biomass_unit) {
  data$dbh <- convert_units(data$dbh, from = dbh_unit, to = data$dbh_unit)

  .biomass <- purrr::map2(data$eqn, data$dbh, ~safe_eval_dbh(.x, .y))
  result <- dplyr::mutate(data, biomass = purrr::map_dbl(.biomass, "result"))
  result$biomass <- convert_units(
    result$biomass, from = result$bms_unit, to = biomass_unit
  )
  warn_if_errors(.biomass, "Can't evaluate all equations")

  result
}

eval_dbh <- function(text, dbh) {
  eval(parse(text = text), envir = list(dbh = dbh))
}
safe_eval_dbh <- purrr::safely(eval_dbh, otherwise = NA_real_)

eval_memoised <- memoise::memoise(allo_evaluate_impl)

#' Evaluate equations, giving a biomass result per row.
#'
#' @param data A dataframe as those created with [allo_find()].
#' @param biomass_unit Character string giving the output unit e.g. "kg".
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
#'   sample_n(500) %>%
#'   add_species(fgeo.biomass::scbi_species, "scbi") %>%
#'   allo_find()
#'
#' allo_evaluate(best)
#'
#' allo_evaluate(best, biomass_unit = "Mg")
allo_evaluate <- function(data, biomass_unit = "kg") {
  dbh_unit = "mm"
  inform(glue("Assuming `dbh` unit in [{dbh_unit}]."))

  inform("Converting `dbh` based on `dbh_unit`.")
  inform(glue("`biomass` values are given in [{biomass_unit}]."))
  out <- eval_memoised(data, dbh_unit = dbh_unit, biomass_unit = biomass_unit)

  warn("`biomass` may be invalid. This is still work in progress.")

  by_rowid <- group_by(out, .data$rowid)
  summarize(by_rowid, biomass = sum(.data$biomass))
}

