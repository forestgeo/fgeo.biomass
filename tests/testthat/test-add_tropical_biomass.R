context("add_tropical_biomass")

library(dplyr)

test_that("add_tropical_biomass fails elegantly", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  # ok
  expect_error(
    add_tropical_biomass(
      data, species, region = NULL, latitude = -38, longitude = -58
    ),
    NA
  )

  expect_error(
    add_tropical_biomass(dplyr::rename(data, bad = dbh), species),
    "Ensure.*dbh"
  )
  expect_error(
    add_tropical_biomass(dplyr::rename(data, bad = sp), species),
    "Ensure.*sp"
  )

  expect_error(
    add_tropical_biomass(data, dplyr::rename(species, bad = Species)),
    "Ensure.*species"
  )
  expect_error(
    add_tropical_biomass(data, dplyr::rename(species, bad = Genus)),
    "Ensure.*genus"
  )

  expect_error(add_tropical_biomass(), "data.*missing")
  expect_error(add_tropical_biomass(data), "species.*missing")
  expect_error(
    add_tropical_biomass(
      data, species, region = NULL, latitude = -38, longitude = NULL
    ),
    "must be non-NULL"
  )

  expect_error(
    add_tropical_biomass(data, species, region = "bad"),
    "region.*must be"
  )

  expect_error(
    add_tropical_biomass(data, species, region = c("bad", "nope")),
    "must be.*single character string"
  )

  expect_error(
    add_tropical_biomass(data, species, dbh_unit = c("cm", "mm")),
    "must be.*single character string"
  )
})

test_that("add_tropical_biomass returns `longitude`, `latitude`", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  out <- add_tropical_biomass(data, species, latitude = -34, longitude = -58)
  has_names_lat_long <- c("latitude", "longitude") %>%
    purrr::map_lgl(~ hasName(out, .x)) %>%
    all()

  expect_true(has_names_lat_long)
})

test_that("add_tropical_biomass errs with bad `longitude`, `latitude`", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  expect_error(
    add_tropical_biomass(data, species, latitude = -999, longitude = -58),
    "must be valid"
  )
})

test_that("add_tropical_biomass works with `longitude`, `latitude`", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  expect_error(
    add_tropical_biomass(data, species, latitude = -34, longitude = -58),
    NA
  )
})

test_that("add_tropical_biomass informs new columns", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  expect_output(
    add_tropical_biomass(data, species),
    "new column.*biomass"
  )
})

test_that("add_tropical_biomass can take region insensitive to case", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  expect_equal(
    add_tropical_biomass(data, species, region = "Pantropical")$biomass,
    add_tropical_biomass(data, species, region = "pantropical")$biomass
  )
})

test_that("add_tropical_biomass is sensitive to `region`", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  expect_false(
    identical(
      add_tropical_biomass(data, species, region =    "SAmerica")$biomass,
      add_tropical_biomass(data, species, region = "Pantropical")$biomass
    )
  )
})

test_that("add_tropical_biomass is sensitive to `dbh_unit`", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  in_cm <- mutate(data, dbh = .data$dbh / 10)
  in_mm <- data
  expect_equal(
    add_tropical_biomass(in_cm, species, dbh_unit = "cm")$biomass,
    add_tropical_biomass(in_mm, species, dbh_unit = "mm")$biomass
  )

  expect_false(
    identical(
      add_tropical_biomass(data, species, dbh_unit = "cm")$biomass,
      add_tropical_biomass(data, species, dbh_unit = "mm")$biomass
    )
  )
})

test_that("add_tropical_biomass informs if guessing dbh unit", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  # Don't expect `message`
  message <- "Guessing dbh in "
  msg <- purrr::quietly(add_tropical_biomass)(
    as.data.frame(data), species, dbh_unit = "mm"
  )$messages
  expect_false(grepl(message, glue_collapse(msg)))

  # Do expect `message`
  expect_output(
    add_tropical_biomass(as.data.frame(data), species),
    message
  )
})

test_that("add_tropical_biomass outputs some non-missing biomass value", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  expect_false(
    all(is.na(add_tropical_biomass(as.data.frame(data), species)$biomass))
  )
})

test_that("add_tropical_biomass outputs a tibble", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  expect_is(
    add_tropical_biomass(as.data.frame(data), species),
    "tbl"
  )
})

test_that("add_tropical_biomass outputs the expected names", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  expect_true(
    "biomass" %in% names(add_tropical_biomass(data, species))
  )
})
