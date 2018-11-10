context("default_eqn")

test_that("outputs the expected data structure", {
  out <- default_eqn(allodb::master())
  nms <- c("equation_id", "site", "sp", "eqn", "eqn_source", "eqn_type")
  expect_named(out, nms)
})
