context("add_species")

test_that("add_species preserves rows if if all `sp` are available", {
  spp <- c("acne", "acpl", "acru")
  census <- fgeo.biomass::scbi_tree1 %>%
    dplyr::filter(sp %in% spp)
  species <- fgeo.biomass::scbi_species

  expect_true(
    identical(
      nrow(add_species(census, species, "scbi")), nrow(census))
  )
})

test_that("add_species preserves rows of the census data", {
  spp <- c("acne", "acpl", "acru")
  census <- fgeo.biomass::scbi_tree1 %>%
    dplyr::filter(sp %in% spp)
  species <- fgeo.biomass::scbi_species

  # Still preserves rows
  species_na <- species
  species_na[species_na$sp == spp[[1]], "sp"] <- NA
  expect_true(
    identical(
      nrow(add_species(census, species_na, "scbi")), nrow(census))
  )
})

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
