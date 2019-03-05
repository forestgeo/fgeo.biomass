context("add_species")

test_that("outputs the expected data structure", {
  expect_output({
    out <- add_species(
      fgeo.biomass::scbi_tree1,
      fgeo.biomass::scbi_species, "scbi"
    )
  },
    NA
  )
  expect_named(out, c("rowid", "site", "sp", "dbh"))
})

test_that("add_species informs when addint latin species names into `sp`", {
  expect_message(
    add_species(
      fgeo.biomass::scbi_tree1,
      fgeo.biomass::scbi_species,
      site = "scbi"
    ),
    "`sp` now stores Latin species names"
  )

})
