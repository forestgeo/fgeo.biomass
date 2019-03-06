context("fixme_find_duplicated_rowid")

test_that("errs with informative message", {
  renamed_eqn <- dplyr::rename(
    suppressWarnings(default_eqn(allodb::master())),
    spp = sp
  )
  expect_error(fixme_find_duplicated_rowid(renamed_eqn), "Ensure your data")
})

test_that("fixme_drop_duplicated_rowid has no rowis found by fixme_find_*", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  best <- suppressWarnings(allo_find(cns_sp))

  pruned <- expect_warning(
    fixme_drop_duplicated_rowid(best),
    "Dropping.*duplicated `rowid`"
  )
  expect_equal(nrow(fixme_find_duplicated_rowid(pruned)), 0L)
})
