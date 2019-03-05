context("allo_find")

test_that("allo_find no longer returns a nested dataframe", {
  census <- fgeo.biomass::scbi_tree1
  species <- fgeo.biomass::scbi_species
  census_species <- add_species(
    census, species,
    site = "scbi"
  )

  out <- allo_find(census_species)
  expect_equal(out, tidyr::unnest(out))
})
