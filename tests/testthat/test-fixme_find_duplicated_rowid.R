context("fixme_find_duplicated_rowid")

test_that("errs with informative message", {
  renamed_eqn <- dplyr::rename(.default_eqn, spp = sp)
  expect_error(fixme_find_duplicated_rowid(renamed_eqn), "Ensure your data")
})
