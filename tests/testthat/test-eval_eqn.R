context("eval_eqn.R")

library(purrr)
library(dplyr)

test_that("FIXME: Problems in equations (#54)", {
  error_msg <- some_error(allodb::master(), eval_eqn) %>%
    discard(is.null) %>%
    map_chr("message") %>%
    unique() %>%
    glue_collapse(sep = "\n")
  warn(glue("Problems to fix:\n {error_msg}"))
})
