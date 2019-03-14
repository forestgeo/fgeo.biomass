context("convert_units")

library(dplyr)

test_that("convert_units warns problems", {
  expect_warning(
    convert_units(c(1, 10), from = "cm", to = c("m", "bad")),
    "Can't convert all units"
  )
})

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

test_that("convert_unit can convert all units in allodb::equations", {
  dfm <- allodb::equations %>%
    select(matches("unit")) %>%
    unique() %>%
    mutate(dbh = 1, biomass = 1)

  expect_false(
    any(is.na(convert_units(dfm$dbh, "cm", to = dfm$dbh_units_original)))
  )

  expect_false(
    any(is.na(convert_units(dfm$dbh, dfm$biomass_units_original, to = "kg")))
  )
})
