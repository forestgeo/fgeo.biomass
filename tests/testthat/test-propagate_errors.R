context("propagate_errors")

library(dplyr)

test_that("propagate_errors works with temperate coordinates", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  biomass <- add_tropical_biomass(
    data = data,
    species = species,
    # Temperate
    latitude = -34,
    longitude = -58
  )

  out <- propagete_errors(biomass, n = 50)
  expect_false(all(is.na(out$AGB_simu)))
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
