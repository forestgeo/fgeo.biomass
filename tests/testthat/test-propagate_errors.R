context("propagate_errors")

library(dplyr)

test_that("propagate_errors is sensitive to `height_model`", {
  data <- fgeo.biomass::scbi_tree1 %>%
    slice(1:100)
  species <- fgeo.biomass::scbi_species

  biomass <- add_tropical_biomass(
    data = data,
    species = species,
    latitude = 4,
    longitude = -52
  )

  tmp <- tempfile("out.pdf")
  pdf(tmp)
  this_model <- BIOMASS::modelHD(
    D = biomass$dbh,
    H = get_height_list(biomass)$H,
    method = NULL
  )
  dev.off()
  rm(tmp)

  expect_error(
    propagate_errors(
      data = select(biomass, -.data$latitude, -.data$longitude),
      n = 50,
      height_model = this_model
    ),
    "must have only 1 method"
  )
})

test_that("propagate_errors is sensitive to `height_model`", {
  data <- fgeo.biomass::scbi_tree1 %>%
    slice(1:100)
  species <- fgeo.biomass::scbi_species

  biomass <- add_tropical_biomass(
    data = data,
    species = species,
    latitude = 4,
    longitude = -52
  )

  expect_error(
    out <- propagate_errors(biomass, n = 50, height_model = NULL),
    NA
  )

  expect_is(out, "list")
  expect_false(is.null(out))
  expect_false(all(is.na(out$AGB_simu)))

  method <- "log1"
  model <- BIOMASS::modelHD(
    D = biomass$dbh,
    H = get_height_list(biomass)$H,
    method = method
  )
  expect_false(
    identical(
      withr::with_seed(1,
        propagate_errors(biomass, n = 50, height_model = NULL)
      ),
      withr::with_seed(1, propagate_errors(
        select(biomass, -latitude, -longitude),
        n = 50,
        height_model = model
      ))
    )
  )
})

test_that("propagate_errors is sensitive to `dbh_sd` or similar", {
  data <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  biomass <- add_tropical_biomass(
    data = data,
    species = species,
    latitude = 4,
    longitude = -52
  )

  expect_identical(
      withr::with_seed(1, propagate_errors(biomass, n = 50, dbh_sd = NULL)),
      withr::with_seed(1, propagate_errors(biomass, n = 50, dbh_sd = NULL))
  )

  expect_false(
    identical(
        withr::with_seed(1,
          propagate_errors(biomass, n = 50, dbh_sd = NULL)
        ),
        withr::with_seed(1,
          propagate_errors(biomass, n = 50, dbh_sd = "chave2004")
        )
    )
  )

  expect_is(
    out <- propagate_errors(biomass, n = 50, dbh_sd = "chave2004"),
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
    out <- propagate_errors(biomass, n = 50),
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
    out <- propagate_errors(biomass, n = 200),
    "list"
  )
  expect_false(is.null(out))
  expect_false(all(is.na(out$AGB_simu)))
})
