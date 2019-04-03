context("basal_diameter")

test_that("basal_diameter with one stem, basal_diameter equals dbh", {
  expect_equal(basal_diameter(10), 10)
  expect_equal(basal_diameter(0), 0)
})

test_that("basal_diameter with NA results in 0", {
  expect_equal(basal_diameter(NA_real_), 0)
  expect_equal(basal_diameter(c(10, NA_real_)), 10)
})

test_that("basal_diameter retuns equal to sum of basal area", {
  # https://github.com/forestgeo/allodb/issues/41#issuecomment-392113712

  # Long alternative to basal_diameter
  basal_diameter2 <- function(dbh) {
    sqrt(sum(basal_area(dbh), na.rm = TRUE) / pi) * 2
  }

  expect_equal(basal_diameter2(10),    basal_diameter(10))
  expect_equal(basal_diameter2(10:11), basal_diameter(10:11))
  expect_equal(basal_diameter2(10:15), basal_diameter(10:15))

  random_dbh <- runif(10) * 100
  expect_equal(basal_diameter2(random_dbh), basal_diameter(random_dbh))
})

context("contribution_to_basal_area")

test_that("contribution_to_basal_area adds up to 1", {
  expect_equal(sum(contribution_to_basal_area(9)), 1)
  expect_equal(sum(contribution_to_basal_area(c(1, NA_real_)), na.rm = TRUE), 1)
  expect_equal(sum(contribution_to_basal_area(c(1, 2, 3))), 1)
})

context("basal_area")

test_that("basal_area outputs as expected", {
  expect_is(basal_area(1), "numeric")
  expect_equal(basal_area(NA), NA_real_)
  expect_equal(basal_area(c(1, NA)), c(basal_area(1), NA_real_))
})

