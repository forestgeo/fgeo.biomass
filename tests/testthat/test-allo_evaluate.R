context("allo_evaluate")

test_that("allo_evaluate warns that results are invalid", {
  eqn <- fgeo.biomass::scbi_tree1 %>%
    add_species(fgeo.biomass::scbi_species, "scbi") %>%
    allo_find()
  expect_warning(
    allo_evaluate(eqn),
    "`biomass` values may be invalid."
  )
})
