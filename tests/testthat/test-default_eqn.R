context("default_eqn")

test_that("default_eqn returns `life_form`", {
  expect_true(
    rlang::has_name(
      default_eqn(allodb::master_tidy()),
      "life_form"
    )
  )
})

test_that("defualt_eqn outputs dbh_min and dbh_max in [mm]", {
  data <- default_eqn(allodb::master_tidy())

  mindbh <- data$dbh_min_mm
  minimum_dbh <- mean(mindbh[mindbh != 0], na.rm = TRUE)
  expect_true(minimum_dbh > 10)

  maxdbh <- data$dbh_max_mm
  maximum_dbh <- mean(maxdbh[!is.infinite(maxdbh)], na.rm = TRUE)
  expect_true(maximum_dbh > 100)
})

test_that("default_eqn has expected columns", {
  nms <- c(
    "eqn_id",
    "site",
    "sp",
    "eqn",
    "eqn_source",
    "eqn_type",
    "anatomic_relevance",
    "dbh_unit",
    "bms_unit",
    "dbh_min_mm",
    "dbh_max_mm",
    "is_generic",
    "life_form"
  )
  expect_named(default_eqn(allodb::master_tidy()), nms)
})
