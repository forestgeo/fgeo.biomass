#' Add `species` to a ForestGEO-like dataframe of census data.
#'
#' @param data A ForestGEO-like census-dataframe.
#' @param species A ForestGEO-like species-dataframe.
#' @param site The name of the site. One of `allodb::sites_info$site`.
#'
#' @family constructors
#'
#' @return A dataframe with as many rows as the census dataset.
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' census <- fgeo.biomass::scbi_tree1
#' species <- fgeo.biomass::scbi_species
#' census %>%
#'   add_species(species, site = "scbi")
add_species <- function(data, species, site) {
  check_add_species(data, species, site)

  joint <- left_join(data, species, by = "sp")
  out <- data
  out$species <- tolower(joint[[pull_chr(names(joint), "latin")]])
  out$site <- tolower(site)

  if (rlang::has_name(out, "rowid")) {
    abort("`census` must not contain a column named `rowid`. Please remove it.")
  }
  out <- tibble::rowid_to_column(out)

  warn_sp_missmatch(data, species)
  warn_missing_species(out$species)

  tibble::as_tibble(out)
}

warn_sp_missmatch <- function(census, species) {
  missing_codes <- sort(setdiff(unique(census$sp), unique(species$sp)))
  if (length(missing_codes) > 0) {
    ui_warn(
      "Can't find matching species names for these codes:
      {paste0(missing_codes, collapse = ', ')}"
    )
  }

  invisible(census)
}

warn_missing_species <- function(x) {
  n_na <- is.na(x)
  if (any(n_na)) {
    ui_warn("`species` has {sum(n_na)} missing values")
  }

  invisible(x)
}

check_add_species <- function(census, species, site) {
  stopifnot(
    is.data.frame(census),
    is.data.frame(species),
    is.character(site),
    length(site) == 1
  )
  check_crucial_names(low(census), c("sp", "dbh"))
  check_crucial_names(low(species), c("sp", "latin"))
}
