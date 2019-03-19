context("fixme_units")

test_that("fixme_units returns expected value", {
  expect_equal(
    fixme_units(c("g", "kg", "lb", "Mg", "t")),
    c("g", "kg", "lbs", "Mg", "metric_ton")
  )
})
