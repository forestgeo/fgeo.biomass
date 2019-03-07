context("default_eqn")

test_that("default_eqn warns that drops failing equations", {
  out <- expect_warning(
    default_eqn(allodb::master()),
    "Dropping.*equations"
  )

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
  expect_named(out, nms)
})

test_that("default_eqn has no unknown unit", {
  has_fixme <- suppressWarnings(default_eqn(allodb::master())) %>%
    dplyr::select(dplyr::matches("unit")) %>%
    purrr::map_lgl(~ "FIXME" %in% .x) %>%
    any()

  expect_false(has_fixme)
})
