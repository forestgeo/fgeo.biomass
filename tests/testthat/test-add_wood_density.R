context("add_wood_density")

library(dplyr)

test_that("add_wood_density can take region insensity to case", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  suppressWarnings({
    expect_equal(
      add_wood_density(data, species, region = tolower("CentralAmericaTrop")),
      add_wood_density(data, species, region = "CentralAmericaTrop")
    )
    expect_equal(
      add_wood_density(data, species, region = tolower("SouthAmericaTrop")),
      add_wood_density(data, species, region = "SouthAmericaTrop")
    )
  })
})

test_that("add_wood_density informs wood density in [g/cm^3]", {
  tree <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species
  expect_message(
    add_wood_density(tree, species),
    "density.*g.cm.3"
  )
})

test_that("add_wood_density is sensitive to region", {
  tree <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species
  expect_false(
    identical(
      add_wood_density(tree, species),
      suppressWarnings(
        add_wood_density(tree, species, region = "NorthAmerica")
      )
    )
  )
})

test_that("add_wood_density outputs a dataframe", {
  tree <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species
  expect_is(add_wood_density(tree, species), "data.frame")
  expect_is(add_wood_density(tree, species), "data.frame")
})

test_that("add_wood_density errs with informative message", {
  tree <- fgeo.biomass::scbi_stem_tiny_tree
  expect_error(add_wood_density(), "argument.*data.*is missing")
  expect_error(add_wood_density(tree), "argument.*species.*is missing")

  species <- fgeo.biomass::scbi_species
  expect_error(
    add_wood_density(select(tree, -.data$sp), species),
    "Ensure.*sp"
  )
  expect_error(
    add_wood_density(tree, select(low(species), -.data$genus)),
    "Ensure.*genus"
  )
  expect_error(
    add_wood_density(tree, select(low(species), -.data$species)),
    "Ensure.*species"
  )

  expect_error(
    suppressWarnings(
      add_wood_density(
        tree, species, family = FALSE, region = "AfricaExtraTrop"
      )
    ),
    "no.*match"
  )
})

