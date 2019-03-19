context("utils")

test_that("is_in_range returns true if in range, else returns false", {
  expect_true(is_in_range(1, min = 1, max = 10))
  expect_true(is_in_range(10, min = 1, max = 10))
  expect_false(is_in_range(11, min = 1, max = 10))
  expect_false(is_in_range(0, min = 1, max = 10))
})

test_that("warn_odd_dbh warns dbh outside [10-100) range", {
  msg <- "should be"
  expect_warning(warn_odd_dbh(1), msg)
  expect_warning(warn_odd_dbh(0), msg)
  expect_warning(warn_odd_dbh(1000), msg)
  expect_warning(warn_odd_dbh(100), msg)

  expect_silent(warn_odd_dbh(10))
  expect_silent(warn_odd_dbh(15))
})

