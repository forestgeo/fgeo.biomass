context("add_equations")

census <- allodb::scbi_tree1
species <- allodb::scbi_species

single_best <- census %>%
  census_species(species, site = "scbi") %>%
  get_equations() %>%
  pick_best_equations() %>%
  pick_one_row_by_rowid()

test_that("handles census with existing `rowid`", {
  expect_error(
    add_equations(tibble::rowid_to_column(census), single_best),
    "`rowid` already exists.*Remove.*and retry"
  )
})

test_that("results in a non-0-length dataframe", {
  cns_eqn <- add_equations(census, single_best)
  out <- dplyr::filter(cns_eqn, !is.na(eqn))
  expect_true(nrow(out) > 0)
})

test_that("outputs the expected data structure", {
  cns_eqn <- add_equations(census, single_best)
  expect_length(cns_eqn, length(census) + 3)

  new_names <- c("rowid", "eqn", "equation_id")
  expect_length(cns_eqn, length(census) + length(new_names))
  expect_named(cns_eqn, c(names(census), new_names), ignore.order = TRUE)
})
