context("allo_find")

library(dplyr)

set.seed(1)

test_that("allo_find warns non matching species", {
  census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(1000)
  species <- fgeo.biomass::scbi_species
  census_species <- census %>% add_species(species, site = "scbi")

  expect_warning(
    allo_find(census_species),
    "Can't find equations matching these species"
  )
})

test_that("allo_find outputs equations that can' be evaluated (#24)", {
  census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(1000)
  species <- fgeo.biomass::scbi_species
  census_species <- census %>% add_species(species, site = "scbi")

  out <- expect_warning(allo_find(census_species), "Can't convert all units")
  expect_true(any(grepl("dba", out$eqn)))
})

test_that("allo_find informs value passed to `dbh_unit`", {
  census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(30)
  species <- fgeo.biomass::scbi_species
  census_species <- census %>% add_species(species, site = "scbi")

  expect_message(
    suppressWarnings(allo_find(census_species)),
    "dbh.*in.*mm"
  )
})

test_that("allo_find drops no row", {
  census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(30)
  species <- fgeo.biomass::scbi_species
  census_species <- census %>% add_species(species, site = "scbi")

  out <- suppressWarnings(allo_find(census_species))
  expect_true(nrow(census_species) <= nrow(out))
})

test_that("allo_find informs that it converts `dbh` as in `dbh_unit`", {
  census <- dplyr::sample_n(fgeo.biomass::scbi_tree1, 30)
  species <- fgeo.biomass::scbi_species
  census_species <- add_species(
    census, species,
    site = "scbi"
  )

  expect_message(
    suppressWarnings(allo_find(census_species)),
    "Converting `dbh` based on `dbh_unit`"
  )
})

test_that("allo_find errs if custom_eqn is not created with as_eqn", {
  census <- dplyr::sample_n(fgeo.biomass::scbi_tree1, 30)
  species <- fgeo.biomass::scbi_species
  census_species <- add_species(
    census, species,
    site = "scbi"
  )
  your_equations <- tibble::tibble(
    equation_id = c("000001"),
    site = c("scbi"),
    sp = c("paulownia tomentosa"),
    eqn = c("exp(-2.48 + 2.4835 * log(dbh))"),
    eqn_type = c("mixed_hardwood"),
    anatomic_relevance = c("total aboveground biomass")
  )

  expect_error(
    allo_find(custom_eqn = your_equations),
    "must be of class 'eqn'"
  )
})
