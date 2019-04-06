context("add_biomass")

library(dplyr)
set.seed(1)

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

  expect_message(
    out <- suppressWarnings(add_biomass(data, species, site)),
    paste0(setdiff(names(out), names(data)), collapse = ".*")
  )
})

context("evaluate_equations")

test_that("evaluate_equations with tree table with trees and shrubs, warns both", {
  tree_table_with_shrub_only <- fgeo.biomass::scbi_stem_tiny_tree %>%
    slice(1:20) %>%
    fgeo.tool::pick_main_stem()
  tree_table_with_shrubs_only <- fgeo.biomass::scbi_stem_tiny_shrub %>%
    slice(1:20) %>%
    fgeo.tool::pick_main_stem()

  both <- bind_rows(tree_table_with_shrub_only, tree_table_with_shrubs_only)

  eqn <- suppressWarnings({
    both %>%
      add_species(scbi_species, "scbi") %>%
      add_equations(dbh_unit = "mm")
  })
  expect_warning(
    evaluate_equations(eqn, dbh_unit = "mm"),
    "Detected a single stem per tree"
  )
  expect_warning(
    evaluate_equations(eqn, dbh_unit = "mm"),
    "For shrubs, `biomass` is that of the entire shrub"
  )
  expect_warning(
    evaluate_equations(eqn, dbh_unit = "mm"),
    "For trees, `biomass` is that of the main stem."
  )
})

test_that("evaluate_equations handles independent variable `dba`", {
  shrubs <- fgeo.biomass::scbi_stem_tiny_shrub

  eqn <- suppressWarnings({
    shrubs %>%
      add_species(scbi_species, "scbi") %>%
      add_equations(dbh_unit = "mm")
  })
  eqn <- eqn %>%
    filter(grepl("dba", .data$eqn))

  out <- suppressWarnings(evaluate_equations(eqn, dbh_unit = "mm"))
  can_handle_dba <- all(is.na(out$biomass))
  expect_false(can_handle_dba)
})

test_that("evaluate_equations with shrub-dba outputs known output", {
  shrubs <- fgeo.biomass::scbi_stem_tiny_shrub

  eqn <- suppressWarnings({
    shrubs %>%
      add_species(scbi_species, "scbi") %>%
      add_equations(dbh_unit = "mm")
  })
  eqn <- eqn %>%
    filter(grepl("dba", .data$eqn))

  out <- suppressWarnings(evaluate_equations(eqn, dbh_unit = "mm"))
  expect_known_output(out, "ref-shrub-dba", update = FALSE)
})

test_that("evaluate_equations with stem table computes biomass of main shrub stem", {
  shrubs <- fgeo.biomass::scbi_stem_tiny_shrub

  eqn <- suppressWarnings({
    shrubs %>%
      add_species(scbi_species, "scbi") %>%
      add_equations(dbh_unit = "mm") %>%
      filter(matches_string(.data$eqn, "dbh"))
  })

  bmss <- suppressWarnings(evaluate_equations(eqn, dbh_unit = "mm"))
  biomass_asis <- sum(bmss$biomass, na.rm = TRUE)

  biomass_is_distributed_beyond_main_stems <- eqn %>%
    left_join(bmss) %>%
    select(rowid, treeID, dbh, biomass) %>%
    filter(!is.na(dbh)) %>%
    add_count(treeID) %>%
    filter(n > 1) %>%
    group_by(treeID) %>%
    mutate(no_na = any(is.na(biomass))) %>%
    pull() %>%
    Negate(any)()

  expect_true(biomass_is_distributed_beyond_main_stems)
})

test_that("evaluate_equations with shrub-dbh outputs known output", {
  shrubs <- fgeo.biomass::scbi_stem_tiny_shrub

  eqn <- suppressWarnings({
    shrubs %>%
      add_species(scbi_species, "scbi") %>%
      add_equations(dbh_unit = "mm")
  })
  out <- suppressWarnings(evaluate_equations(eqn, dbh_unit = "mm"))
  expect_known_output(out, "ref-shrub-dbh", update = FALSE)
})

test_that("evaluate_equations with stem table computes biomass of main shrub stem", {
  shrubs <- fgeo.biomass::scbi_stem_tiny_shrub

  eqn <- suppressWarnings({
    shrubs %>%
      add_species(scbi_species, "scbi") %>%
      add_equations(dbh_unit = "mm") %>%
      filter(matches_string(.data$eqn, "dbh"))
  })

  out1 <- suppressWarnings(evaluate_equations(eqn, dbh_unit = "mm"))
  biomass_asis <- sum(out1$biomass, na.rm = TRUE)

  eqn2 <- suppressWarnings({
    fgeo.tool::pick_main_stem(shrubs) %>%
      add_species(scbi_species, "scbi") %>%
      add_equations(dbh_unit = "mm") %>%
      filter(matches_string(.data$eqn, "dbh"))
  })

  out2 <- suppressWarnings(evaluate_equations(eqn2, dbh_unit = "mm"))
  biomass_main_stems <- sum(out2$biomass, na.rm = TRUE)

  expect_equal(biomass_main_stems, biomass_asis)
})

test_that("evaluate_equations with shrub-dbh outputs known output", {
  shrubs <- fgeo.biomass::scbi_stem_tiny_shrub

  eqn <- suppressWarnings({
    shrubs %>%
      add_species(scbi_species, "scbi") %>%
      add_equations(dbh_unit = "mm")
  })
  out <- suppressWarnings(evaluate_equations(eqn, dbh_unit = "mm"))
  expect_known_output(out, "ref-shrub-dbh", update = FALSE)
})

test_that("evaluate_equations warns if the data is a tree table", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(add_equations(cns_sp))
  expect_warning(
    evaluate_equations(eqn),
    "Detected a single stem per tree"
  )
})

test_that("evaluate_equations with tree-dbh outputs equal to known reference", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(add_equations(cns_sp))
  out <- suppressWarnings(evaluate_equations(eqn))
  expect_known_output(out, "ref-tree-dbh", update = FALSE)
})

test_that("evaluate_equations informs returned value is in [kg]", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    filter(!is.na(dbh)) %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(add_equations(cns_sp, dbh_unit = "mm"))

  expect_message(
    suppressWarnings(evaluate_equations(eqn, dbh_unit = "mm")),
    "`biomass`.*kg"
  )

  expect_false(
    identical(
      suppressWarnings(evaluate_equations_impl(eqn, "cm", "g")),
      suppressWarnings(evaluate_equations_impl(eqn, "cm", "kg"))
    )
  )
})

test_that("evaluate_equations is sensitive to dbh_units", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(suppressMessages(add_equations(cns_sp)))

  out <- suppressWarnings(evaluate_equations(eqn))
  out_mm <- suppressWarnings(evaluate_equations(eqn, dbh_unit = "mm"))
  expect_identical(out, out_mm)

  out_cm <- suppressWarnings(evaluate_equations(eqn, dbh_unit = "cm"))
  expect_false(identical(out, out_cm))
})

test_that("evaluate_equations informs guessed dbh units and given `biomass` units", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(add_equations(cns_sp))

  expect_message(
    suppressWarnings(evaluate_equations(eqn)),
    "Guessing `dbh`.*in.*mm"
  )
  expect_message(
    suppressWarnings(evaluate_equations(eqn)),
    "`biomass`.*in.*kg"
  )
})

test_that("evaluate_equations retuns no duplicated rowid", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    filter(!is.na(dbh)) %>%
    dplyr::sample_n(500) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(add_equations(cns_sp))

  out <- suppressWarnings(evaluate_equations(eqn))
  expect_false(any(duplicated(out$rowid)))
})

test_that("evaluate_equations returns expected columns", {
  census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(100)
  cns_sp <- census %>% add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(add_equations(cns_sp))

  expect_named(
    suppressWarnings(evaluate_equations(eqn)),
    c("rowid", "biomass")
  )
})

