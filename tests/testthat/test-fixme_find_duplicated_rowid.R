context("fixme_find_duplicated_rowid")

test_that("errs with informative message", {
  renamed_eqn <- dplyr::rename(default_eqn(allodb::master()), spp = sp)
  expect_error(fixme_find_duplicated_rowid(renamed_eqn), "Ensure your data")
})

test_that("fixme_drop_duplicated_rowid has no rows found by fixme_find_*", {
  census <- dplyr::sample_n(fgeo.biomass::scbi_tree1, 30) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(census))

  pruned <- expect_warning(
    fixme_drop_duplicated_rowid(eqn),
    "Dropping.*duplicated `rowid`"
  )

  expect_equal(nrow(fixme_find_duplicated_rowid(pruned)), 0L)
})
