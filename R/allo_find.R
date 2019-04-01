allo_find_impl <- function(data, dbh_unit) {
  data$dbh <- convert_units(data$dbh, dbh_unit, "mm")

  eqn <- suppressMessages(fgeo.biomass::default_eqn(allodb::master_tidy()))

  inform("* Matching equations by site and species.")
  .by <- c("sp", "site")

  eqn_from_here <- replace_site(
    eqn, from = "any temperate na", to = unique(data$site)
  )
  matched <- dplyr::left_join(data, eqn_from_here, by = .by)

  inform("* Refining equations according to dbh.")
  matched$dbh_in_range <- is_in_range(
    matched$dbh, min = matched$dbh_min_mm, max = matched$dbh_max_mm
  )
  in_range <- filter(matched, .data$dbh_in_range)
  refined <- suppressMessages(dplyr::left_join(data, in_range))
  refined$dbh_in_range <- NULL

  inform("* Using generic equations where expert equations can't be found.")
  out <- prefer_expert_equaitons(refined)

  warn_if_species_missmatch(out, eqn_from_here)
  warn_if_missing_equations(out)

  out
}
allo_find_memoised <- memoise::memoise(allo_find_impl)

#' Find allometric equations in allodb or in a custom equations-table.
#'
#' @param data A dataframe as those created with [add_species()].
#' @param dbh_unit Character string giving the unit of dbh values, e.g. "mm".
#'
#' @family functions to manipulate equations
#'
#' @return A nested dataframe with each row containing the data of an equation
#'   type.
#' @export
#'
#' @examples
#' census <- dplyr::sample_n(fgeo.biomass::scbi_tree1, 30)
#' species <- fgeo.biomass::scbi_species
#' census_species <- add_species(
#'   census, species,
#'   site = "scbi"
#' )
#'
#' allo_find(census_species, dbh_unit = "mm")
#' @family constructors
allo_find <- function(data, dbh_unit = NULL) {
  if (is.null(dbh_unit)) {
    dbh_unit <- guess_dbh_unit(data$dbh)
    inform(glue("
      Guessing `dbh` in [{dbh_unit}] (required to find dbh-specific equations).
    "))
    inform_provide_dbh_units_manually()
  }

  allo_find_memoised(data, dbh_unit = dbh_unit)
}

warn_if_species_missmatch <- function(data, eqn) {
  to_match <- data[["sp"]]
  available <- unique(eqn[eqn$site %in% unique(data$site), , drop = FALSE]$sp)
  .matching <- to_match %in% available

  if (sum(!.matching) > 0) {
    missmatching <- paste0(sort(unique(to_match[!.matching])), collapse = ", ")
    warn(glue("
      Can't find equations matching these species:
      {missmatching}
    "))
  }

  invisible(data)
}

warn_if_missing_equations <- function(data) {
  missing_equations <- sum(is.na(data$eqn_id))
  if (missing_equations > 0) {
    warn(glue("
      Can't find equations for {missing_equations} rows (inserting `NA`).
    "))
  }

  invisible(data)
}

prefer_expert_equaitons <- function(data) {
  data %>%
    group_by(.data$rowid) %>%
    filter(replace_na(prefer_false(.data$is_generic), TRUE)) %>%
    ungroup()
}

replace_site <- function(eqn, from, to) {
  eqn_from_here <- mutate(eqn,
    site = dplyr::case_when(
      tolower(.data$site) == from ~ to,
      TRUE ~ .data$site
    )
  )
}
