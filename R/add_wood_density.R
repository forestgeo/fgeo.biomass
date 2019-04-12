#' Add wood density.
#'
#' This function wraps some features of [BIOMASS::getWoodDensity()], which you
#' may see for more details and options. It estimates the wood density of the
#' trees from their taxonomy or from their congeners using the global wood
#' density database (Chave et al. 2009, Zanne et al. 2009) or any additional
#' dataset. The resulting values of wood density can either be attributed to an
#' individual at the level of a species, genus, or family.
#'
#' This function assigns to each taxon a species- or genus- level average if at
#' least one wood density value at the genus level is available for that taxon
#' in the reference database. If not, the mean wood density of the family (if
#' `family = TRUE`).
#'
#' As an estimate of the error associated with the wood density estimate, this
#' function also provides the mean standard deviation value at the appropriate
#' taxonomic level.
#'
#' @inheritParams add_species
#' @inheritParams BIOMASS::getWoodDensity
#'
#' @seealso BIOMASS::getWoodDensity
#'
#' @return
#' A dataframe as that passed to `data`, but with additional columns giving
#' taxonomic information, and the following wood density information (oven dry
#' mass/fresh volume in g/cm^3):
#' * wd_mean: Mean wood density.
#' * wd_sd: Standard deviation of the wood density that can be used in error
#' propagation (see sd_10 and AGBmonteCarlo()).
#' * wd_level: Level at which wood density has been calculated. Can be
#' species, genus, family, dataset (mean of the entire dataset) or, if stand
#' is set, the name of the stand (mean of the current stand).
#'
#' @export
#'
#' @references
#' Rejou-Mechain M, Tanguy A, Piponiot C, Chave J, Herault B (2017). “BIOMASS :
#' an R package for estimating above-ground biomass and its uncertainty in
#' tropical forests.” _Methods in Ecology and Evolution_, *8*(9). ISSN 2041210X,
#' doi: 10.1111/2041-210X.12753 (URL: http://doi.org/10.1111/2041-210X.12753),
#' <URL: http://doi.wiley.com/10.1111/2041-210X.12753>.
#'
#' @examples
#' tree <- fgeo.biomass::scbi_stem_tiny_tree
#' species <- fgeo.biomass::scbi_species
#' add_wood_density(tree, species)
add_wood_density <- function(data, species, family = TRUE, region = "World") {
  check_add_wood_density(data, species)

  species_ <- low(species)[c("sp", "family", "genus", "species")]
  data_ <- left_join(data, species_, by = "sp")

  inform("Wood density given in [g/cm^3].")
  wd <- suppressMessages(
    BIOMASS::getWoodDensity(
      genus = data_$genus,
      species = data_$species,
      family = if (family) data_$family else NULL,
      region = pull_region(region, wd_regions())
    )
  )
  wd_ <- select(
    wd,
    wd_level = .data$levelWD,
    wd_mean = .data$meanWD,
    wd_sd = .data$sdWD
  )

  dplyr::bind_cols(data_, wd_)
}

check_add_wood_density <- function(data, species) {
  force(data)
  force(species)
  check_crucial_names(data, "sp")
  check_crucial_names(low(species), c("genus", "species"))
}

wd_regions <- function() {
  c(
    "AfricaExtraTrop",
    "AfricaTrop",
    "Australia",
    "AustraliaTrop",
    "CentralAmericaTrop",
    "China",
    "Europe",
    "India",
    "Madagascar",
    "Mexico",
    "NorthAmerica",
    "Oceania",
    "SouthEastAsia",
    "SouthEastAsiaTrop",
    "SouthAmericaExtraTrop",
    "SouthAmericaTrop",
    "World"
  )
}
