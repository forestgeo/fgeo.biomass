context("propagate_errors")

library(dplyr)

test_that("propagate_errors warns if bad simulated data is all mising", {
  data <- add_tropical_biomass(
    data = fgeo.biomass::scbi_stem_tiny_tree,
    species = fgeo.biomass::scbi_species,
    # Temperate
    latitude = 38,
    longitude = -77
  )

  expect_warning(
    propagete_errors(data, n = 50),
    "Invalid simulations"
  )
})

test_that("propagate_errors returns a valid list", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  # Tropical coords
  tropical_lat <- 15
  tropical_lon <- 79
  biomass <- add_tropical_biomass(
    data = data,
    species = species,
    latitude = tropical_lat,
    longitude = tropical_lon
  )

  expect_is(
    out <- propagete_errors(biomass, n = 50),
    "list"
  )

  expect_false(is.null(out))

  expect_false(all(is.na(out$AGB_simu)))


})
