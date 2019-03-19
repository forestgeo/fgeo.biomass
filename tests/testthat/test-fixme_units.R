context("fixme_units")

test_that("fixme_units has nothing to fix", {
  library(dplyr)
  units <- unique(select(allodb::master_tidy(), matches("unit")))
  expect_equal(
    purrr::map(units, identity),
    purrr::map(units, fixme_units)
  )
})

test_that("fixme_units returns expected value", {
  expect_equal(
    fixme_units(c("g", "kg", "lb", "Mg", "t")),
    c("g", "kg", "lbs", "Mg", "metric_ton")
  )
})
