context("default_eqn")

test_that("default_eqn has expected columns", {
  nms <- c("equation_id",
      "site",
      "sp",
      "eqn",
      "eqn_source",
      "eqn_type",
      "anatomic_relevance",
       "dbh_unit",
       "bms_unit"
    )
  expect_named(default_eqn(allodb::master()), nms)
})
