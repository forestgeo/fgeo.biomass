context("allo_evaluate")

set.seed(1)

test_that("allo_evaluate informs returned value is in [kg]", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(30) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  expect_message(
    expect_warning(
      allo_evaluate(eqn),
      "biomass.*may be invalid"
    ),
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
    expect_warning(
      allo_evaluate(eqn),
      "biomass.*may be invalid"
    ),
    "dbh.*units.*cm"
  )
})

test_that("allo_evaluate retuns no duplicated rowid", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(500) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  out <- expect_warning(
    allo_evaluate(eqn),
    "biomass.*may be invalid"
  )
  expect_false(any(duplicated(out$rowid)))
})

test_that("allo_evaluate returns expected columns", {
  census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(30)
  cns_sp <- census %>% add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  out <- expect_message(
    expect_warning(
      allo_evaluate(eqn),
      "biomass.*may be invalid"
    ),
    "dbh.*units.*cm"
  )

  expect_named(out, c("rowid", "biomass"))
})
