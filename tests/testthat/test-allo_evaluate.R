context("allo_evaluate")

test_that("allo_evaluate informs returned value is in [g]", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(30) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  expect_message(
    allo_evaluate(eqn),
    "`biomass`.*[g]"
  )
})

test_that("allo_evaluate informs that the expected dbh units are [cm]", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(30) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  expect_message(
    allo_evaluate(eqn),
    "dbh.*units.*cm"
  )
})
