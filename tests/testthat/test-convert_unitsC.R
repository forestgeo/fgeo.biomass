context("test-convert_unitsC")

test_that("multiplication works", {
  # Distance
  expect_equal(
    convert_unitsC(1:3,          from = "cm", to = "mm"),
    measurements::conv_unit(1:3, from = "cm", to = "mm")
  )
  expect_equal(
    convert_unitsC(1:3,          from = "cm", to = "m"),
    measurements::conv_unit(1:3, from = "cm", to = "m")
  )
  expect_equal(
    convert_unitsC(1:3,          from = "cm", to = "cm"),
    measurements::conv_unit(1:3, from = "cm", to = "cm")
  )
})
