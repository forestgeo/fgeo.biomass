context("add_equations")

test_that("handles census with existing `rowid`", {
  census <- tibble::rowid_to_column(allodb::scbi_tree1)
  species <- allodb::scbi_species

  single_best <- census %>%
    census_species(species, site = "scbi") %>%
    get_equations() %>%
    pick_best_equations() %>%
    pick_one_row_by_rowid()

  expect_error(
    add_equations(census, single_best),
    "`rowid` already exists.*Remove.*and retry"
  )
})
