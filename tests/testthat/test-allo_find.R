context("allo_find")

test_that("allo_find informs joining vars and warns dangers", {
  census <- fgeo.biomass::scbi_tree1
  species <- fgeo.biomass::scbi_species
  census_species <- add_species(
    census, species,
    site = "scbi"
  )

  out <- expect_warning(
        expect_message(
          allo_find(census_species),
          "Joining.*sp.*site"
        ),
    "input and output.*have different.*rows"
  )
  expect_equal(out, tidyr::unnest(out))
})

