#' Add `species` to a ForestGEO-like dataframe of census data.
#'
#' @param census A ForestGEO-like census-dataframe.
#' @param species A ForestGEO-like species-dataframe.
#' @param site The name of the site. One of `allodb::sites_info$site`.
#'
#' @family constructors
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' census_species(allodb::scbi_tree1, allodb::scbi_species, site = "scbi")
census_species <- function(census, species, site) {
  .census <- rlang::set_names(census, tolower)
  .species <- rlang::set_names(species, tolower)
  .site <- tolower(site)
  check_bms_cns(.census, .species, .site)

  all <- dplyr::left_join(.census, .species, by = "sp")
  all$sp <- tolower(all$latin)
  all$site <- .site
  out <- all[c("site", "sp", "dbh")]
  out <- tibble::rowid_to_column(out)
  new_census_species(dplyr::as_tibble(out))
}

new_census_species <- function(x) {
  stopifnot(tibble::is.tibble(x))
  structure(x, class = c("census_species", class(x)))
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
    "allometry_specificity"
  )
}
