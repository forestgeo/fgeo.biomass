context("propagate_errors")

library(dplyr)

test_that("propagate_errors returns a list", {
  # data <- fgeo.biomass::scbi_stem_tiny_tree
  data <- fgeo.biomass::scbi_tree1 %>%
    sample_n(500)
  species <- fgeo.biomass::scbi_species

  biomass <- add_tropical_biomass(
    data = data,
    species = species,
    latitude = -34,
    longitude = -58
  )

  expect_is(
    propagete_errors(biomass, n = 50),
    "list"
  )

  expect_false(is.null(propagete_errors(biomass, n = 50)))
})
