context("propagate_errors")

library(dplyr)

test_that("propagate_errors is sensitive to `Dpropag` or similar", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  biomass <- add_tropical_biomass(
    data = data,
    species = species,
    latitude = 4,
    longitude = -52
  )

  expect_is(
    out <- propagete_errors(biomass, n = 50),
    "list"
  )
  expect_false(is.null(out))
  expect_false(all(is.na(out$AGB_simu)))
})

test_that("propagate_errors with lat, long returns a valid list", {
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

test_that("propagate_errors with lat, long and bci data returns a valid list", {
  skip_if_not_installed("bciex")

  data <- bciex::bci12t7mini %>%
    as_tibble() %>%
    filter(!is.na(dbh)) %>%
    filter(status == "A") %>%
    slice(1:30)

  species <- bciex::bci_species

  # Tropical coords
  tropical_lat <- 9
  tropical_lon <- -79
  biomass <- add_tropical_biomass(
    data = data,
    species = species,
    latitude = tropical_lat,
    longitude = tropical_lon
  )

  expect_is(
    out <- propagete_errors(biomass, n = 200),
    "list"
  )
  expect_false(is.null(out))
  expect_false(all(is.na(out$AGB_simu)))
})
