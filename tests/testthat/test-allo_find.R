context("allo_find")

library(dplyr)
set.seed(1)



test_that("allo_find matches 'any *'", {
  census <- fgeo.biomass::scbi_tree1
  species <- fgeo.biomass::scbi_species
  data <- add_species(
    census, species,
    site = "scbi"
  )

  dbh_values <- c(10, 50, 600)
  data2 <- data %>%
    # Pull any three rows of one species
    filter(sp %in% unique(sp)[[1]]) %>%
    slice(1:3) %>%
    # Replace sp by one that for which site = "any *"
    mutate(sp = "abies amabilis", dbh = dbh_values)

  equation_id_are_missing <- suppressWarnings(allo_find(data2)) %>%
    select(rowid, sp, equation_id, site) %>%
    pull(equation_id) %>%
    is.na() %>%
    all()

  expect_false(equation_id_are_missing)
})





test_that("allo_find prefers expert over generic equations (allo#72)", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(1000) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")

  some_generic_equations <- any(
    as.vector(na.omit(
      suppressWarnings(allo_find(cns_sp))$is_generic
    ))
  )
  expect_true(some_generic_equations)

  out <- allo_find(cns_sp)
  pref <- out %>%
    group_by(rowid) %>%
    filter(
        replace_na(prefer_false(is_generic), TRUE)
      ) %>%
    ungroup()
  expect_equal(out, pref)
})

test_that("allo_find does not warn if dbh in [mm]", {
  data <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(1000) %>%
    filter(!is.na(dbh)) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")

  warnings <- paste0(purrr::quietly(allo_find)(data)$warnings, collapse = ", ")
  expect_false(grepl("should be.*mm", warnings))
})

test_that("allo_find is sensitive to units", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")

  expect_equal(
    suppressWarnings(allo_find(cns_sp))$dbh,
    suppressWarnings(allo_find(cns_sp, dbh_unit = "mm"))$dbh
  )
  expect_false(
    identical(
      suppressWarnings(allo_find(cns_sp, dbh_unit = "cm"))$dbh,
      suppressWarnings(allo_find(cns_sp, dbh_unit = "mm"))$dbh
    )
  )
})

test_that("allo_find guesses dbh units in [mm]", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")

  expect_message(
    suppressWarnings(allo_find(cns_sp)),
    "Guessing.*dbh.*in.*mm"
  )
})

test_that("allo_find warns non matching species", {
  census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(1000)
  species <- fgeo.biomass::scbi_species
  census_species <- census %>% add_species(species, site = "scbi")

  expect_warning(
    allo_find(census_species),
    "Can't find.*equations matching these species"
  )
})

test_that("allo_find drops no row", {
  census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(30)
  species <- fgeo.biomass::scbi_species
  census_species <- census %>% add_species(species, site = "scbi")

  out <- suppressWarnings(allo_find(census_species))
  expect_true(nrow(census_species) <= nrow(out))
})
