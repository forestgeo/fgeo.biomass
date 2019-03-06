context("fixme_units")

test_that("fixme_test returns expected value", {
  dbh_unit <- sort(unique(allodb::equations$dbh_units_original))
  expect_equal(
    fixme_units(dbh_unit),
    c("cm", "cm2", "inch", "inch2", "m", "mm")
  )

  bms_unit <- sort(unique(allodb::equations$biomass_units_original))
  expect_equal(
    fixme_units(
      c("g", "gm", "kg", "lb", "Mg", "t")
    ),
    c("g", "g", "kg", "lbs", "Mg", "metric_ton")
  )
})
