context("prefer_false")

expect_equal(prefer_false(c(T, NA)), c(T, NA))
expect_equal(prefer_false(c(F, NA)), c(T, NA))
expect_equal(prefer_false(c(F, NA, T)), c(T, NA, F))

expect_equal(
  replace_na(
    prefer_false(c(F, NA, T)),
    TRUE
  ),
  c(T, T, F)
)

expect_equal(prefer_false(c(T)), c(T))
expect_equal(prefer_false(c(F)), c(T))
expect_equal(prefer_false(c(F, T)), c(T, F))
expect_equal(prefer_false(c(T, T)), c(T, T))
expect_equal(prefer_false(c(T, F, F)), c(F, T, T))

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



context("is_in_range")

test_that("is_in_range returns true if in range, else returns false", {
  expect_true(is_in_range(1, min = 1, max = 10))
  expect_true(is_in_range(10, min = 1, max = 10))
  expect_false(is_in_range(11, min = 1, max = 10))
  expect_false(is_in_range(0, min = 1, max = 10))
})

context("eval_eqn.R")

test_that("FIXME: Problems in equations (#54)", {
  error_msg <- some_error(allodb::master_tidy(), eval_eqn) %>%
    purrr::discard(is.null) %>%
    purrr::map_chr("message") %>%
    unique() %>%
    glue_collapse(sep = "\n")

  warn(glue("Problems to fix:\n {error_msg}"))
})
