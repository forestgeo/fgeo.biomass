context("allo_evaluate")

set.seed(1)

test_that("allo_evaluate informs returned value is in [kg]", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  expect_message(
    expect_warning(
      allo_evaluate(eqn),
      "biomass.*may be invalid"
    ),
    "`biomass`.*kg"
  )

  expect_false(
    identical(
      suppressWarnings(allo_evaluate_impl(eqn, "cm", "g")),
      suppressWarnings(allo_evaluate_impl(eqn, "cm", "kg"))
    )
  )
})

test_that("allo_evaluate is sensitive to dbh_units", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(suppressMessages(allo_find(cns_sp)))

  out <- suppressWarnings(allo_evaluate(eqn))
  out_mm <- suppressWarnings(allo_evaluate(eqn, dbh_unit = "mm"))
  expect_identical(out, out_mm)

  out_cm <- suppressWarnings(allo_evaluate(eqn, dbh_unit = "cm"))
  expect_false(identical(out, out_cm))
})

test_that("allo_evaluate informs guessed dbh units and given `biomass` units", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  expect_message(
    suppressWarnings(allo_evaluate(eqn)),
    "Guessing `dbh`.*in.*mm"
  )
  expect_message(
    suppressWarnings(allo_evaluate(eqn)),
    "`biomass`.*in.*kg"
  )
})

test_that("allo_evaluate informs that it converts `dbh` as in `dbh_unit`", {
  census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(100)
  species <- fgeo.biomass::scbi_species
  census_species <- add_species(
    census, species,
    site = "scbi"
  )
  eqn <- suppressMessages(suppressWarnings(allo_find(census_species)))

  expect_message(
    suppressWarnings(allo_evaluate(eqn)),
    "Converting `dbh` based on `dbh_unit`"
  )
})

test_that("allo_evaluate warns if can't convert units", {
  census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(1000)
  species <- fgeo.biomass::scbi_species
  census_species <- census %>% add_species(species, site = "scbi")

  out <- expect_warning(
    allo_evaluate(suppressWarnings(allo_find(census_species))),
  "Can't convert all units"
  )
})

test_that("allo_evaluate retuns no duplicated rowid", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(500) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  out <- expect_warning(
    allo_evaluate(eqn),
    "biomass.*may be invalid"
  )
  expect_false(any(duplicated(out$rowid)))
})

test_that("allo_evaluate returns expected columns", {
  census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(100)
  cns_sp <- census %>% add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  expect_named(
    suppressWarnings(allo_evaluate(eqn)),
    c("rowid", "biomass")
  )
})
