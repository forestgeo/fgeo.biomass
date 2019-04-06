#' Add biomass.
#'
#' @inheritParams add_species
#' @param data A dataframe as those created with [add_equations()].
#' @param dbh_unit Character string giving the unit of dbh values, e.g. "mm".
#' @param biomass_unit Character string giving the output unit e.g. "kg".
#'
#' @return A dataframe with a single row by each value of `rowid`.
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' data <- bind_rows(
#'   fgeo.biomass::scbi_stem_tiny_tree,
#'   fgeo.biomass::scbi_stem_tiny_shrub
#' )
#'
#' species <- fgeo.biomass::scbi_species
#'
#' add_biomass(data, species, site = "scbi")
#'
#' data %>%
#'   add_biomass(species, site = "scbi", biomass_unit = "Mg") %>%
#'   select(species, biomass, dbh, everything())
add_biomass <- function(data,
                        species,
                        site,
                        dbh_unit = guess_dbh_unit(data$dbh),
                        biomass_unit = "kg") {
  with_spp <- add_species(data, species = species, site = site)
  with_eqn <- add_equations(with_spp, dbh_unit = dbh_unit)

  with_bms <- add_component_biomass(with_eqn, biomass_unit = biomass_unit)

  with_bms2 <- group_by(with_bms, .data$rowid)
  with_bms3 <- summarize(with_bms2, biomass = sum(.data$biomass))

  out <- left_join(with_spp, with_bms3, by = "rowid")

  inform_new_columns(out, data)
  out
}

add_component_biomass_impl <- function(data, dbh_unit, biomass_unit) {
  check_crucial_names(low(data), "treeid")

  data_ <- low(data) %>%
    mutate(tmp_id = seq_len(nrow(data)), is_shrub = is_shrub(.data$life_form))

  biomass_tree <- data_ %>%
    filter(!is_shrub) %>%
    row_biomass(.name = "dbh", dbh_unit = dbh_unit, biomass_unit = biomass_unit)
  biomass_shrub_dbh <- data_ %>%
    filter(is_shrub & matches_string(.data$eqn, "dbh")) %>%
    row_biomass_from_main_stem(dbh_unit = dbh_unit, biomass_unit = biomass_unit)
  biomass_shrub_dba <- data_ %>%
    filter(is_shrub & matches_string(.data$eqn, "dba")) %>%
    row_biomass_from_dba(dbh_unit = dbh_unit, biomass_unit = biomass_unit)

  biomass <- dplyr::bind_rows(
    biomass_tree,
    biomass_shrub_dbh,
    biomass_shrub_dba
  ) %>%
    arrange(.data$tmp_id) %>%
    select(-.data$tmp_id, -.data$is_shrub)

  biomass
}

eval_memoised <- memoise::memoise(add_component_biomass_impl)

add_component_biomass <- function(data,
                               dbh_unit = guess_dbh_unit(data$dbh),
                               biomass_unit = "kg") {
  warn_if_tree_table(data)

  inform(glue("Guessing `dbh` in [{dbh_unit}]"))
  inform_provide_dbh_units_manually()

  inform(glue("`biomass` values are given in [{biomass_unit}]."))

  eval_memoised(data, dbh_unit = dbh_unit, biomass_unit = biomass_unit)
}

row_biomass <- function(data, .name, dbh_unit, biomass_unit) {
  if (identical(nrow(data), 0L)) {
    result <- tibble::add_column(data, biomass = numeric(0))
    return(result)
  }

  .text <- data$eqn
  .values <- convert_units(
    data[[.name]], from = dbh_unit, to = data$dbh_unit, quietly = TRUE
  )

  .biomass <- purrr::map2(.text, .values, ~ safe_eval(.x, .y, .name = .name))
  result <- dplyr::mutate(data, biomass = purrr::map_dbl(.biomass, "result"))
  result$biomass <- convert_units(
    result$biomass, from = result$bms_unit, to = biomass_unit, quietly = TRUE
  )
  warn_if_errors(.biomass, "Can't evaluate all equations")

  result
}

eva_var <- function(.text, .values, .name) {
  .envir <- rlang::set_names(list(.values), .name)
  eval(parse(text = .text), envir = .envir)
}

safe_eval <- purrr::safely(eva_var, otherwise = NA_real_)

row_biomass_from_main_stem <- function(data, dbh_unit, biomass_unit) {
  total_biomass <- data %>%
    # Avoid clash with rowid inserted by pick_main_stem()
    dplyr::rename(rowid_data = .data$rowid) %>%
    fgeo.tool::pick_main_stem() %>%
    row_biomass(
      .name = "dbh", dbh_unit = dbh_unit, biomass_unit = biomass_unit
    ) %>%
    dplyr::rename(
      rowid = .data$rowid_data,
      total_biomass = .data$biomass
    ) %>%
    select(.data$treeid, .data$total_biomass)

  data %>%
    left_join(total_biomass, by = "treeid") %>%
    group_by(.data$treeid) %>%
    mutate(
      biomass = unique(.data$total_biomass) *
        contribution_to_basal_area(.data$dbh),
      total_biomass = NULL
    ) %>%
    ungroup()
}

row_biomass_from_dba <- function(data, .data, dbh_unit, biomass_unit) {
  data %>%
    group_by(.data$treeid) %>%
    mutate(
      dba = basal_diameter(.data$dbh) * contribution_to_basal_area(.data$dbh)
    ) %>%
    ungroup() %>%
    row_biomass(
      .name = "dba", dbh_unit = dbh_unit, biomass_unit = biomass_unit
    ) %>%
    mutate(dba = NULL)
}

warn_if_tree_table <- function(data) {
  if (!has_multiple_stems(data)) {
    warn("Detected a single stem per tree. Do you need a multi-stem table?")

    if (any(grepl("tree", data$life_form))) {
      warn("* For trees, `biomass` is that of the main stem.")
    }

    if (any(grepl("shrub", data$life_form))) {
      warn("* For shrubs, `biomass` is that of the entire shrub.")
    }
  }

  invisible(data)
}