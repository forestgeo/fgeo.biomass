allo_evaluate_impl <- function(data, dbh_unit, biomass_unit) {
  data_ <- mutate(
    data,
    presplit_rowid = seq_len(nrow(data)),
    is_shrub = is_shrub(.data$life_form)
  )

  biomass_tree <- filter(data_, !is_shrub) %>%
    row_biomass(dbh_unit = dbh_unit, biomass_unit = biomass_unit)
  biomass_shrub <- filter(data_, is_shrub) %>%
    main_stem_biomass_or_na(dbh_unit = dbh_unit, biomass_unit = biomass_unit)

  out <- dplyr::bind_rows(biomass_shrub, biomass_tree) %>%
    dplyr::arrange(.data$presplit_rowid) %>%
    select(
      -.data$presplit_rowid,
      -.data$is_shrub
    )

  out
}

main_stem_biomass_or_na <- function(data, dbh_unit, biomass_unit) {
  # Main stem biomass
  main_stem_biomass <- data %>%
    # Avoid clash with rowid inserted by pick_main_stem()
    dplyr::rename(rowid_data = .data$rowid) %>%
    fgeo.tool::pick_main_stem() %>%
    row_biomass(dbh_unit = dbh_unit, biomass_unit = biomass_unit) %>%
    dplyr::rename(rowid = .data$rowid_data)

  # Expand `biomass` filling with `NA` at non-main-stems
  joint <- suppressMessages(dplyr::full_join(main_stem_biomass, data))
  result <- joint %>%
    dplyr::arrange(.data$rowid) %>%
    dplyr::group_by(.data$rowid) %>%
    dplyr::arrange(.data$rowid, .data$biomass) %>%
    dplyr::filter(dplyr::row_number() == 1L) %>%
    dplyr::ungroup()

  result
}

row_biomass <- function(data, dbh_unit, biomass_unit) {
  data$dbh <- convert_units(
    data$dbh, from = dbh_unit, to = data$dbh_unit, quietly = TRUE)

  .biomass <- purrr::map2(data$eqn, data$dbh, ~safe_eval_dbh(.x, .y))
  result <- dplyr::mutate(data, biomass = purrr::map_dbl(.biomass, "result"))
  result$biomass <- convert_units(
    result$biomass, from = result$bms_unit, to = biomass_unit, quietly = TRUE
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
#' @param dbh_unit Character string giving the unit of dbh values, e.g. "mm".
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
allo_evaluate <- function(data,
                          dbh_unit = guess_dbh_unit(data$dbh),
                          biomass_unit = "kg") {
  warn_if_tree_table(data)
  warn_if_stem_table_with_shrubs(data)

  inform(glue("Guessing `dbh` in [{dbh_unit}]"))
  inform_provide_dbh_units_manually()

  inform("Converting `dbh` based on `dbh_unit`.")
  inform(glue("`biomass` values are given in [{biomass_unit}]."))
  row_biomass <- eval_memoised(
    data, dbh_unit = dbh_unit, biomass_unit = biomass_unit
  )

  by_rowid <- group_by(row_biomass, .data$rowid)
  summarize(by_rowid, biomass = sum(.data$biomass))
}

warn_if_tree_table <- function(data) {
  if (! has_multiple_stems(data)) {
    warn(glue("
      Detected a single stem per tree. Consider these properties of the result:
      * For trees, `biomass` is that of the main stem.
      * For shrubs, `biomass` is that of the entire shrub.
      Do you need a multi-stem table?
    "))
  }

  invisible(data)
}

warn_if_stem_table_with_shrubs <- function(data) {
  if (has_multiple_stems(data) &&
      any(grepl("shrub", tolower(data$life_form)))) {
    inform(
      "Shrub `biomass` given for main stems only but applies to the whole shrub."
    )
  }

  invisible(data)
}
