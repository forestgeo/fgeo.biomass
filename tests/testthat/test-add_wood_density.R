context("test-add_wood_density")

library(dplyr)

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

test_that("add_wood_density adds and informs new columns", {
  tree <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  out <- expect_message(
    add_wood_density(tree, species),
    "new columns.*wd_"
  )

  cols <- c("wd_level", "wd_mean", "wd_sd", "family", "genus", "species")
  expect_true(all(cols %in% names(out)))
})

test_that("add_wood_density doesn't throw unimportant messages", {
  tree <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  output <- purrr::quietly(add_wood_density)(tree, species)
  expect_false(any(grepl("reference dataset contains", output$messages)))
  expect_false(any(grepl("taxonomic table contains", output$messages)))
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

