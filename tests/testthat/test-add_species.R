context("add_species")

test_that("add_species preserves census-rows and warns missing `sp` codes", {
  spp <- c("acne", "acpl", "acru")
  census <- fgeo.biomass::scbi_tree1 %>%
    dplyr::filter(sp %in% spp)
  species <- fgeo.biomass::scbi_species
  expect_true(
    identical(
      nrow(add_species(census, species, "scbi")),
      nrow(census))
  )

  # Still preserves rows
  species_na <- species
  species_na[species_na$sp == spp[[1]], "sp"] <- NA

  expect_warning(
    add_species(census, species_na, "scbi"),
    "Can't find.*codes"
  )
  out <- expect_warning(
    add_species(census, species_na, "scbi"),
    "*has.*missing values"
  )
  expect_true(any(is.na(out$species)))

  expect_true(identical(nrow(out), nrow(census)))
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

  expect_true(length(fgeo.biomass::scbi_tree1) < length(out))
  expect_true(all(c("rowid", "site", "sp", "dbh", "species") %in% names(out)))
})
