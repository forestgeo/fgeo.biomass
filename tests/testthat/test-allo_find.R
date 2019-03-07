context("allo_find")

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

test_that("allo_find informs joining vars and warns dangers", {
  census <- dplyr::sample_n(fgeo.biomass::scbi_tree1, 30)
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

test_that("allo_find warns if `dbh_units` can't be converted", {
  census <- fgeo.biomass::scbi_tree1[1:30, ]
  species <- fgeo.biomass::scbi_species
  census_species <- add_species(
    census, species,
    site = "scbi"
  )

  your_equations <- tibble::tibble(
    equation_id = c("000001"),
    site = c("scbi"),
    sp = c("lindera benzoin"),
    # Watning: Fake!
    eqn = c("exp(-2.48 + 2.4835 * log(dbh))"),
    eqn_type = c("mixed_hardwood"),
    anatomic_relevance = c("total aboveground biomass"),
    dbh_unit = "BAD",
    bms_unit = "g"
  )

  expect_warning(
    allo_find(census_species, custom_eqn = as_eqn(your_equations)),
    "units can't be converted"
  )
})
