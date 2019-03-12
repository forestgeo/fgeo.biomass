context("allo_evaluate")

set.seed(1)

test_that("allo_evaluate informs returned value is in [kg]", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(30) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  expect_message(
    allo_evaluate(eqn),
    "`biomass`.*kg"
  )

  expect_false(
    identical(
      allo_evaluate_impl(eqn, "g"),
      allo_evaluate_impl(eqn, "kg")
    )
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
