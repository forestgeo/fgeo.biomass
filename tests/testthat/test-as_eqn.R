context("as_eqn")

test_that("as_eqn errs if missing crucial columns", {
  expect_error(
    as_eqn(data.frame(1)),
   "dbh_min_cm"
  )

  expect_error(
    as_eqn(
      dplyr::mutate(default_eqn(allodb::master_tidy()), dbh_max_cm = NULL)
    ),
   "dbh_max_cm"
  )
})
