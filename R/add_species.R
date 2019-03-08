#' Add `species` to a ForestGEO-like dataframe of census data.
#'
#' @param census A ForestGEO-like census-dataframe.
#' @param species A ForestGEO-like species-dataframe.
#' @param site The name of the site. One of `allodb::sites_info$site`.
#'
#' @family constructors
#'
#' @return A dataframe with as many rows as the census dataset.
#' @export
#'
#' @examples
#' census <- fgeo.biomass::scbi_tree1
#' species <- fgeo.biomass::scbi_species
#' add_species(census, species, site = "scbi")
add_species <- function(census, species, site) {
  .census <- rlang::set_names(census, tolower)
  .species <- rlang::set_names(species, tolower)
  .site <- tolower(site)
  check_bms_cns(.census, .species, .site)

  all <- dplyr::left_join(.census, .species, by = "sp")
  inform("`sp` now stores Latin species names")
  all$sp <- tolower(all$latin)
  all$site <- .site

  if (!rlang::has_name(all, "rowid")) {
    all <- tibble::rowid_to_column(all)
  }

  out <- all[c("rowid", "site", "sp", "dbh")]
  warn_sp_missmatch(census, species)
  warn_missing_sp(out$sp)
  new_add_species(dplyr::as_tibble(out))
}

warn_sp_missmatch <- function(census, species) {
  missing_codes <- sort(setdiff(unique(census$sp), unique(species$sp)))
  if (length(missing_codes) > 0) {
    warn(
      glue(
        "Can't find matching species names for these codes:
        {paste0(missing_codes, collapse = ', ')}"
      )
    )
  }

  invisible(census)
}

warn_missing_sp <- function(x) {
  n_na <- is.na(x)
  if (any(n_na)) {
    warn(glue("`sp` has {sum(n_na)} missing values"))
  }

  invisible(x)
}

new_add_species <- function(x) {
  stopifnot(tibble::is.tibble(x))
  if (inherits(x, "add_species")) {
    return(x)
  }

  structure(x, class = c("add_species", class(x)))
}

check_bms_cns <- function(census, species, site) {
  stopifnot(
    is.data.frame(census),
    is.data.frame(species),
    is.character(site),
    length(site) == 1
  )
  check_crucial_names(census, c("sp", "dbh"))
  check_crucial_names(species, "sp")
}



#' Crucial columns form __allodb__ equations-table.
#'
#' @return A string.
#' @export
#' @keywords internal
#'
#' @examples
#' allodb_eqn_crucial()
allodb_eqn_crucial <- function() {
  c(
    "equation_id",
    "site",
    "species",
    "equation_allometry",
    "allometry_specificity",
    "dependent_variable_biomass_component",
    "dbh_units_original",
    "biomass_units_original"
  )
}
