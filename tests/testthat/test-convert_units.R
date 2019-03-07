context("convert_units")

test_that("convert_units converts `dbh`", {
  data <- tibble::tribble(
    ~dbh, ~dbh_unit,
       1,       "bad",
       1,       "m"
  )
  out <- convert_units(data$dbh, from = "cm", to = data$dbh_unit)
  expect_equal(out, c(NA, 0.01))
})

test_that("convert_units converts `biomass`", {
  data <- tibble::tribble(
    ~biomass, ~bmss_unit,
           1,      "kg",
           1,     "bad"
  )
  out <- convert_units(data$biomass, from = data$bmss_unit, to = "g")
  expect_equal(out, c(1000, NA))
})

