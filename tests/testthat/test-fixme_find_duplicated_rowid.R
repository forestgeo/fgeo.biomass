context("fixme_find_duplicated_rowid")

test_that("errs with informative message", {
  renamed_eqn <- dplyr::rename(.default_eqn, spp = sp)
  expect_error(fixme_find_duplicated_rowid(renamed_eqn), "Ensure your data")
})

test_that("fixme_drop_duplicated_rowid has no rowis found by fixme_find_*", {
  best <- fgeo.biomass::scbi_tree1 %>%
    add_species(fgeo.biomass::scbi_species, "scbi") %>%
    allo_find() %>%
    allo_order()

  pruned <- expect_warning(
    fixme_drop_duplicated_rowid(best),
    "Dropping.*duplicated `rowid`"
  )
  expect_equal(nrow(fixme_find_duplicated_rowid(pruned)), 0L)
})
