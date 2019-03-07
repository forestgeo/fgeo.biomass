context("allo_evaluate")

test_that("allo_evaluate warns that results are invalid", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(30) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  expect_warning(
    allo_evaluate(eqn),
    "`biomass` values may be invalid."
  )
})

test_that("allo_evaluate informs that the expected dbh units are [cm]", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(30) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  expect_message(
        expect_warning(
          allo_evaluate(eqn),
          "`biomass` values may be invalid"
        ),
    "dbh.*units.*cm"
  )
})
