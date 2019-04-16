context("guess_dbh_unit")

test_that("guess_dbh_unit errs with NA", {
  expect_error(
    guess_dbh_unit(c(NA, NA)),
    "Can't guess.*dbh.*units"
  )
  expect_error(
    guess_dbh_unit("bad type"),
    "x.*must be numeric"
  )
})

test_that("guess_dbh_unit() can guess cm (#20)", {
  # min(x, na.rm = TRUE) < 1.1 &&
  # max(x, na.rm = TRUE) < 500
  expect_equal(guess_dbh_unit(c(1.0, 100)), new_guessed("cm"))
  # min is too large
  expect_error(guess_dbh_unit(c(1.2, 499)), "Can't guess.*dbh.*units")
  # max is too large
  expect_error(guess_dbh_unit(c(1.0, 501)), "Can't guess.*dbh.*units")
  # min is too large and max is too large
  expect_error(guess_dbh_unit(c(1.2, 501)), "Can't guess.*dbh.*units")

  # min(x, na.rm = TRUE) > 9 &&
  # max(x, na.rm = TRUE) > 500
  expect_equal(guess_dbh_unit(c(9.1, 500.1)), new_guessed("mm"))
  # min is too small
  expect_error(guess_dbh_unit(c(8.9, 500.1)), "Can't guess.*dbh.*units")
  # max is too small
  expect_error(guess_dbh_unit(c(9.1, 500)), "Can't guess.*dbh.*units")
  # min is too small and max is too small
  expect_error(guess_dbh_unit(c(8.9, 500)), "Can't guess.*dbh.*units")
})
