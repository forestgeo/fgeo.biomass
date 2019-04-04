context("allo_evaluate")

library(dplyr)

set.seed(1)

test_that("allo_evaluate handles independent variable `dba`", {
  shrubs <- fgeo.biomass::scbi_stem_tiny_shrub

  eqn <- suppressWarnings({
    shrubs %>%
      add_species(scbi_species, "scbi") %>%
      allo_find(dbh_unit = "mm")
  })
  eqn_dba <- eqn %>%
    filter(grepl("dba", .data$eqn))

  out <- suppressWarnings(allo_evaluate(eqn_dba, dbh_unit = "mm"))
  can_handle_dba <- all(is.na(out$biomass))
  expect_false(can_handle_dba)
})

test_that("allo_evaluate with shrub-dba outputs known output", {
  shrubs <- fgeo.biomass::scbi_stem_tiny_shrub

  eqn <- suppressWarnings({
    shrubs %>%
      add_species(scbi_species, "scbi") %>%
      allo_find(dbh_unit = "mm")
  })
  eqn_dba <- eqn %>%
    filter(grepl("dba", .data$eqn))

  out <- suppressWarnings(allo_evaluate(eqn_dba, dbh_unit = "mm"))
  expect_known_output(out, "ref-shrub-dba", update = FALSE)
})

test_that("allo_evaluate with stem table computes biomass of main shrub stem", {
  shrubs <- fgeo.biomass::scbi_stem_tiny_shrub

  eqn <- suppressWarnings({
    shrubs %>%
      add_species(scbi_species, "scbi") %>%
      allo_find(dbh_unit = "mm") %>%
      filter(matches_string(.data$eqn, "dbh"))
  })

  bmss <- suppressWarnings(allo_evaluate(eqn, dbh_unit = "mm"))
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

test_that("allo_evaluate with shrub-dbh outputs known output", {
  shrubs <- fgeo.biomass::scbi_stem_tiny_shrub

  eqn <- suppressWarnings({
    shrubs %>%
      add_species(scbi_species, "scbi") %>%
      allo_find(dbh_unit = "mm")
  })
  out <- suppressWarnings(allo_evaluate(eqn, dbh_unit = "mm"))
  expect_known_output(out, "ref-shrub-dbh", update = FALSE)
})

test_that("allo_evaluate with stem table computes biomass of main shrub stem", {
  shrubs <- fgeo.biomass::scbi_stem_tiny_shrub

  eqn <- suppressWarnings({
    shrubs %>%
      add_species(scbi_species, "scbi") %>%
      allo_find(dbh_unit = "mm") %>%
      filter(matches_string(.data$eqn, "dbh"))
  })

  out1 <- suppressWarnings(allo_evaluate(eqn, dbh_unit = "mm"))
  biomass_asis <- sum(out1$biomass, na.rm = TRUE)

  eqn2 <- suppressWarnings({
    fgeo.tool::pick_main_stem(shrubs) %>%
      add_species(scbi_species, "scbi") %>%
      allo_find(dbh_unit = "mm") %>%
      filter(matches_string(.data$eqn, "dbh"))
  })

  out2 <- suppressWarnings(allo_evaluate(eqn2, dbh_unit = "mm"))
  biomass_main_stems <- sum(out2$biomass, na.rm = TRUE)

  expect_equal(biomass_main_stems, biomass_asis)
})

test_that("allo_evaluate with shrub-dbh outputs known output", {
  shrubs <- fgeo.biomass::scbi_stem_tiny_shrub

  eqn <- suppressWarnings({
    shrubs %>%
      add_species(scbi_species, "scbi") %>%
      allo_find(dbh_unit = "mm")
  })
  out <- suppressWarnings(allo_evaluate(eqn, dbh_unit = "mm"))
  expect_known_output(out, "ref-shrub-dbh", update = FALSE)
})

test_that("allo_evaluate informs how we hanlde biomass of multi-stem shrubs", {
  spp <- suppressWarnings(
    add_species(
      fgeo.biomass::scbi_stem_tiny_shrub, fgeo.biomass::scbi_species, "scbi"
    )
  )
  eqn <- suppressWarnings(allo_find(spp, dbh_unit = "mm"))
  expect_message(
    allo_evaluate(eqn, dbh_unit = "mm"),
    "Shrub `biomass` given for main stems only but applies to the whole shrub."
  )
})

test_that("allo_evaluate warns if the data is a tree table", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))
  expect_warning(
    allo_evaluate(eqn),
    "Detected a single stem per tree"
  )
})

test_that("allo_evaluate with tree-dbh outputs equal to known reference", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))
  out <- suppressWarnings(allo_evaluate(eqn))
  expect_known_output(out, "ref-tree-dbh", update = FALSE)
})

test_that("allo_evaluate informs returned value is in [kg]", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    filter(!is.na(dbh)) %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp, dbh_unit = "mm"))

  expect_message(
    suppressWarnings(allo_evaluate(eqn, dbh_unit = "mm")),
    "`biomass`.*kg"
  )

  expect_false(
    identical(
      suppressWarnings(allo_evaluate_impl(eqn, "cm", "g")),
      suppressWarnings(allo_evaluate_impl(eqn, "cm", "kg"))
    )
  )
})

test_that("allo_evaluate is sensitive to dbh_units", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(suppressMessages(allo_find(cns_sp)))

  out <- suppressWarnings(allo_evaluate(eqn))
  out_mm <- suppressWarnings(allo_evaluate(eqn, dbh_unit = "mm"))
  expect_identical(out, out_mm)

  out_cm <- suppressWarnings(allo_evaluate(eqn, dbh_unit = "cm"))
  expect_false(identical(out, out_cm))
})

test_that("allo_evaluate informs guessed dbh units and given `biomass` units", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  expect_message(
    suppressWarnings(allo_evaluate(eqn)),
    "Guessing `dbh`.*in.*mm"
  )
  expect_message(
    suppressWarnings(allo_evaluate(eqn)),
    "`biomass`.*in.*kg"
  )
})

test_that("allo_evaluate informs that it converts `dbh` as in `dbh_unit`", {
  census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(100)
  species <- fgeo.biomass::scbi_species
  census_species <- add_species(
    census, species,
    site = "scbi"
  )
  eqn <- suppressMessages(suppressWarnings(allo_find(census_species)))

  expect_message(
    suppressWarnings(allo_evaluate(eqn)),
    "Converting `dbh` based on `dbh_unit`"
  )
})

test_that("allo_evaluate retuns no duplicated rowid", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    filter(!is.na(dbh)) %>%
    dplyr::sample_n(500) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  out <- suppressWarnings(allo_evaluate(eqn))
  expect_false(any(duplicated(out$rowid)))
})

test_that("allo_evaluate returns expected columns", {
  census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(100)
  cns_sp <- census %>% add_species(fgeo.biomass::scbi_species, "scbi")
  eqn <- suppressWarnings(allo_find(cns_sp))

  expect_named(
    suppressWarnings(allo_evaluate(eqn)),
    c("rowid", "biomass")
  )
})
