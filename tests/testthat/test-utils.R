context("can_find_bioclimatic_params")

test_that("can_find_bioclimatic_params works as epected", {
  expect_false(
    can_find_bioclimatic_params(NA_real_, -52)
  )
  # expect_false(can_find_bioclimatic_params(4, NA))
  # expect_false(can_find_bioclimatic_params(999, -999))
  #
  # expect_true(can_find_bioclimatic_params(38.899947, -77.034333))
  expect_true(can_find_bioclimatic_params(4, -52))
})

context("has_multiple_stems")

test_that("has_multiple_stems returns true if dealing with stem table", {
  skip_if_not_installed("fgeo.data")

  expect_true(has_multiple_stems(fgeo.data::luquillo_stem6_1ha))
  expect_false(has_multiple_stems(fgeo.biomass::scbi_tree1))
})

context("replace_na")

test_that("replace_na can replace NA with TRUE", {
  expect_equal(
    replace_na(
      prefer_false(c(F, NA, T)),
      TRUE
    ),
    c(T, T, F)
  )
})

context("prefer_false")

test_that("prefer_false handles simplest TRUE/FALSE cases", {
  expect_equal(prefer_false(c(T)), c(T))
  expect_equal(prefer_false(c(F)), c(T))
  expect_equal(prefer_false(c(F, T)), c(T, F))
  expect_equal(prefer_false(c(T, T)), c(T, T))
  expect_equal(prefer_false(c(T, F, F)), c(F, T, T))
})

test_that("prefer_false returns missing values", {
  expect_equal(prefer_false(c(T, NA)), c(T, NA))
  expect_equal(prefer_false(c(F, NA)), c(T, NA))
  expect_equal(prefer_false(c(F, NA, T)), c(T, NA, F))
})

test_that("prefer_false handles grouped data", {
  dfm <- tibble::tribble(
    ~id, ~lgl,
    1,   TRUE,
    1,   FALSE,
    2,   FALSE,
    3,   TRUE,
  )

  # Ungrouped
  out <- filter(dfm, prefer_false(lgl))
  expect_equal(out$id, c(1, 2))
  expect_equal(out$lgl, c(FALSE, FALSE))

  # Grouped
  out <- filter(group_by(dfm, id), prefer_false(lgl))
  expect_equal(out$id, c(1, 2, 3))
  expect_equal(out$lgl, c(FALSE, FALSE, TRUE))
})

context("is_in_range")

test_that("is_in_range returns true if in range, else returns false", {
  expect_true(is_in_range(1, min = 1, max = 10))
  expect_true(is_in_range(10, min = 1, max = 10))
  expect_false(is_in_range(11, min = 1, max = 10))
  expect_false(is_in_range(0, min = 1, max = 10))
})
