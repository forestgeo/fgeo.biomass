context("fixme_units")

test_that("fixme_test returns expected value", {
  allodb_units <- sort(unique(allodb::equations$dbh_units_original))
  expect_equal(
    fixme_units(allodb_units),
    c("cm", "cm2", "inch", "inch2", "m", "mm")
  )
})
