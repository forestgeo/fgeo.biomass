context("add_species")

test_that("outputs the expected data structure", {
  expect_output({
    out <- add_species(allodb::scbi_tree1, allodb::scbi_species, "scbi")
  },
    NA
  )
  expect_named(out, c("rowid", "site", "sp", "dbh"))
})
