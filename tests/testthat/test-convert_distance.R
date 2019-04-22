context("test-convert_distance")

test_that("multiplication works", {
  # TODO:
  # stopifnot(is.numeric(x))
  # from/to = NA; warning
  # from/to = "bad"; warning

  expect_equal(
    convert_distance(1, from = "bad", to = "mm"),
    NA_real_
  )
  expect_equal(
    convert_distance(c(1, NA), from = "cm", to = "mm"),
    measurements::conv_unit(c(1, NA), from = "cm", to = "mm")
  )

  expect_equal(
    convert_distance(1:3, from = "mm", to = "cm"),
    measurements::conv_unit(1:3, from = "mm", to = "cm")
  )

  expect_equal(
    convert_distance(1:3, from = "cm", to = "mm"),
    measurements::conv_unit(1:3, from = "cm", to = "mm")
  )

  expect_equal(
    convert_distance(1:3, from = "cm", to = "inch"),
    measurements::conv_unit(1:3, from = "cm", to = "inch")
  )

  expect_equal(
    convert_distance(1:3, from = "inch", to = "cm"),
    measurements::conv_unit(1:3, from = "inch", to = "cm")
  )

  expect_equal(
    convert_distance(1:3, from = "inch", to = "mm"),
    measurements::conv_unit(1:3, from = "inch", to = "mm")
  )

  expect_equal(
    convert_distance(1:3, from = "mm", to = "inch"),
    measurements::conv_unit(1:3, from = "mm", to = "inch")
  )
})
