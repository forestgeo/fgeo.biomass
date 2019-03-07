context("default_equations")

test_that("default_eqn warns that drops failing equations", {
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
  expect_named(default_equations, nms)
})

test_that("default_eqn has no unknown unit", {
  has_fixme <- default_equations %>%
    dplyr::select(dplyr::matches("unit")) %>%
    purrr::map_lgl(~ "FIXME" %in% .x) %>%
    any()

  expect_false(has_fixme)
})
