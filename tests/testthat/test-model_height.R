context("model_height")

library(dplyr)

test_that("model_height errs eloquently", {
  data <- fgeo.biomass::scbi_tree1 %>%
    slice(1:100)

  expect_error(
    model_height(dplyr::rename(data, bad = dbh)),
    "Ensure.*dbh"
  )
})

test_that("model_height outputs a list", {
  data <- fgeo.biomass::scbi_tree1 %>%
    slice(1:100)

  expect_is(model_height(data, method = "log1"), "list")
})

test_that("model_height is sensitive to `method`", {
  data <- fgeo.biomass::scbi_tree1 %>%
    slice(1:100)

  expect_error(model_height(data), NA)

  expect_false(identical(
    model_height(data, method = "log1"),
    model_height(data, method = "log2")
  ))
})
