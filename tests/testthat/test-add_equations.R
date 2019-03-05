context("add_equations")

census <- fgeo.biomass::scbi_tree1

single_best <- census %>%
  add_species(fgeo.biomass::scbi_species, site = "scbi") %>%
  allo_find()
single_best <- suppressWarnings(fixme_drop_duplicated_rowid(single_best))

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
