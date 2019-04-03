context("allo_evaluate")

set.seed(1)

test_that("allo_evaluate with stem table computes biomass of main shrub stem", {
  shrubs <- fgeo.biomass::scbi_stem_shrub_tiny

  eqn <- suppressWarnings({
    shrubs %>%
      add_species(scbi_species, "scbi") %>%
      allo_find(dbh_unit = "mm")
  })
  biomass_asis <- suppressWarnings(
    sum(allo_evaluate(eqn, dbh_unit = "mm")$biomass, na.rm = TRUE)
  )

  eqn2 <- suppressWarnings({
    fgeo.tool::pick_main_stem(shrubs) %>%
    add_species(scbi_species, "scbi") %>%
    allo_find(dbh_unit = "mm")
  })
  biomass_main_stems <- suppressWarnings(
    sum(allo_evaluate(eqn2, dbh_unit = "mm")$biomass, na.rm = TRUE)
  )

  expect_equal(biomass_main_stems, biomass_asis)
})

test_that("allo_evaluate informs how we hanlde biomass of multi-stem shrubs", {
  spp <- suppressWarnings(
    add_species(
      fgeo.biomass::scbi_stem_shrub_tiny, fgeo.biomass::scbi_species, "scbi"
    )
  )
  eqn <- suppressWarnings(allo_find(spp, dbh_unit = "mm"))
  expect_message(
    allo_evaluate(eqn, dbh_unit = "mm"),
    "Shrub `biomass` given for main stems only but applies to the whole shrub."
  )
})

test_that("allo_evaluate warns if the data is a tree table", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))
  expect_warning(
    allo_evaluate(eqn),
    "Detected a single stem per tree"
  )
})

test_that("allo_evaluate informs returned value is in [kg]", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    filter(!is.na(dbh)) %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp, dbh_unit = "mm"))

  expect_message(
    suppressWarnings(allo_evaluate(eqn, dbh_unit = "mm")),
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

# test_that("allo_evaluate warns if can't convert units", {
#   census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(1000)
#   species <- fgeo.biomass::scbi_species
#   census_species <- census %>%
#     add_species(species, site = "scbi")
#
#   out <- expect_warning(
#     allo_evaluate(suppressWarnings(allo_find(census_species))),
#   "Can't convert all units"
#   )
# })

test_that("allo_evaluate retuns no duplicated rowid", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    filter(!is.na(dbh)) %>%
    dplyr::sample_n(500) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  out <- suppressWarnings(allo_evaluate(eqn))
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
