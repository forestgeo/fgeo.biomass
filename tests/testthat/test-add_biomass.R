context("add_biomass")

library(dplyr)
set.seed(1)

test_that("add_equations returns NA if all rows per rowid are NA", {
  data <- fgeo.biomass::scbi_tree1 %>% slice(1:100)
  species <- fgeo.biomass::scbi_species
  site <- "scbi"

  out <- suppressWarnings(add_biomass(data, species, site))
  expect_true(any(is.na(out$biomass)))
})

test_that("add_equations output original names' case", {
  data <- fgeo.biomass::scbi_tree1 %>% slice(1:100)
  species <- fgeo.biomass::scbi_species
  site <- "scbi"

  out <- suppressWarnings(add_biomass(data, species, site))
  preserves_names_case <- any(grepl("treeID", names(out)))
  expect_true(preserves_names_case)
})

test_that("add_equations informs new added columns", {
  data <- fgeo.biomass::scbi_tree1 %>% slice(1:100)
  species <- fgeo.biomass::scbi_species
  site <- "scbi"

  out <- suppressWarnings(add_biomass(data, species, site))
  expect_equal(nrow(out), nrow(data))
})

test_that("add_equations informs new added columns", {
  data <- fgeo.biomass::scbi_tree1 %>% slice(1:100)
  species <- fgeo.biomass::scbi_species
  site <- "scbi"

  expect_output(
    suppressWarnings(add_biomass(data, species, site)),
    "rowid, species, site, biomass"
  )
})

test_that("add_biomass with tree table with trees and shrubs, warns both", {
  tree_table_with_shrub_only <- fgeo.biomass::scbi_stem_tiny_tree %>%
    slice(1:20) %>%
    fgeo.tool::pick_main_stem()
  tree_table_with_shrubs_only <- fgeo.biomass::scbi_stem_tiny_shrub %>%
    slice(1:20) %>%
    fgeo.tool::pick_main_stem()

  both <- bind_rows(tree_table_with_shrub_only, tree_table_with_shrubs_only)
  species <- fgeo.biomass::scbi_species

  expect_warning(
    add_biomass(both, species, site = "scbi", dbh_unit = "mm"),
    "Detected a single stem per tree"
  )
  expect_warning(
    add_biomass(both, species, site = "scbi", dbh_unit = "mm"),
    "For shrubs, `biomass` is that of the entire shrub"
  )
  expect_warning(
    add_biomass(both, species, site = "scbi", dbh_unit = "mm"),
    "For trees, `biomass` is that of the main stem."
  )
})

test_that("add_biomass handles independent variable `dba`", {
  shrubs <- fgeo.biomass::scbi_stem_tiny_shrub
  species <- fgeo.biomass::scbi_species

  out <- suppressWarnings(
    add_biomass(shrubs, species, site = "scbi", dbh_unit = "mm")
  )
  can_handle_dba <- all(is.na(out$biomass))
  expect_false(can_handle_dba)
})

test_that("add_biomass with shrub outputs known output", {
  shrubs <- fgeo.biomass::scbi_stem_tiny_shrub
  species <- fgeo.biomass::scbi_species
  out <- suppressWarnings(
    add_biomass(shrubs, species, site = "scbi", dbh_unit = "mm")
  )
  expect_known_output(out, "ref-shrub", update = FALSE)
})

test_that("add_biomass with tree table outputs equal to known reference", {
  trees <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species
  out <- suppressWarnings(add_biomass(trees, species, site = "scbi"))
  expect_known_output(out, "ref-tree", update = FALSE)
})

test_that("add_biomass informs returned value is in [kg]", {
  trees <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  expect_output(
    suppressWarnings(add_biomass(trees, species, site = "scbi")),
    "biomass.*in.*kg"
  )
})

test_that("add_biomass is sensitive to `dbh_unit`", {
  trees <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  expect_false(
    identical(
      suppressWarnings(add_biomass(
        trees, species, site = "scbi", dbh_unit = "cm"
      )),
      suppressWarnings(add_biomass(
        trees, species, site = "scbi", dbh_unit = "mm"
      ))
    )
  )
})

test_that("add_biomass informs guessed dbh units", {
  trees <- fgeo.biomass::scbi_stem_tiny_tree
  species <- fgeo.biomass::scbi_species

  expect_output(
    add_biomass(trees, species, site = "scbi"),
    "Guessing dbh.*in.*mm"
  )
})



context("add_component_biomass")

test_that("add_equations output original names' case", {
  data <- fgeo.biomass::scbi_tree1 %>% slice(1:100)
  species <- fgeo.biomass::scbi_species
  site <- "scbi"

  out <- suppressWarnings(add_component_biomass(data, species, site))
  preserves_names_case <- any(grepl("treeID", names(out)))
  expect_true(preserves_names_case)

  has_odd_name <- any(grepl("names\\(data\\)", names(out)))
  expect_false(has_odd_name)
})

test_that("add_component_biomass retuns some duplicated rowid", {
  trees <- fgeo.biomass::scbi_tree1 %>%
    slice(1:150)
  species <- fgeo.biomass::scbi_species
  out <- suppressWarnings(add_component_biomass(trees, species, site = "scbi"))
  expect_true(any(duplicated(out$rowid)))
})

