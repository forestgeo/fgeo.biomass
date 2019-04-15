context("add_equations")

library(dplyr)
set.seed(1)

test_that("add_equations warns number of rows with NA based on input", {
  data <- tibble(
    rowid = c(1, 1, 2, 2, 3, 3),
    eqn_id = c("a", NA, NA, NA, NA, NA)
  )
  expect_warning(
    warn_if_missing_equations(data),
    "Can't find equations for 2 rows"
  )
})

test_that("add_equations returns expected names", {
  census <- dplyr::sample_n(fgeo.biomass::scbi_tree1, 30)
  species <- fgeo.biomass::scbi_species
  census_species <- add_species(
    census, species,
    site = "scbi"
  )
  out <- suppressWarnings(add_equations(census_species, dbh_unit = "mm"))
  expect_true(all(names(census) %in% names(out)))
})

test_that("add_equations matches 'any *'", {
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

  eqn_id_are_missing <- suppressWarnings(add_equations(data2)) %>%
    select(rowid, sp, eqn_id, site) %>%
    pull(eqn_id) %>%
    is.na() %>%
    all()

  expect_false(eqn_id_are_missing)
})

test_that("add_equations prefers expert over generic equations (allo#72)", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(1000) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")

  some_generic_equations <- any(
    as.vector(na.omit(
      suppressWarnings(add_equations(cns_sp))$is_generic
    ))
  )
  expect_true(some_generic_equations)

  out <- add_equations(cns_sp)
  pref <- out %>%
    group_by(rowid) %>%
    filter(
        replace_na(prefer_false(is_generic), TRUE)
      ) %>%
    ungroup()
  expect_equal(out, pref)
})

test_that("add_equations does not warn if dbh in [mm]", {
  data <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(1000) %>%
    filter(!is.na(dbh)) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")

  warnings <- paste0(
    purrr::quietly(add_equations)(data)$warnings, collapse = ", "
  )
  expect_false(grepl("should be.*mm", warnings))
})

test_that("add_equations is sensitive to units", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")

  expect_equal(
    suppressWarnings(add_equations(cns_sp))$dbh,
    suppressWarnings(add_equations(cns_sp, dbh_unit = "mm"))$dbh
  )
  expect_false(
    identical(
      suppressWarnings(add_equations(cns_sp, dbh_unit = "cm"))$dbh,
      suppressWarnings(add_equations(cns_sp, dbh_unit = "mm"))$dbh
    )
  )
})

test_that("add_equations guesses dbh units in [mm]", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(100) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")

  expect_output(
    suppressWarnings(add_equations(cns_sp)),
    "Guessing.*dbh.*in.*mm"
  )
})

test_that("add_equations warns non matching species", {
  census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(1000)
  species <- fgeo.biomass::scbi_species
  census_species <- census %>% add_species(species, site = "scbi")

  expect_warning(
    add_equations(census_species),
    "Can't find.*equations matching these species"
  )
})

test_that("add_equations drops no row", {
  census <- fgeo.biomass::scbi_tree1 %>% dplyr::sample_n(30)
  species <- fgeo.biomass::scbi_species
  census_species <- census %>% add_species(species, site = "scbi")

  out <- suppressWarnings(add_equations(census_species))
  expect_true(nrow(census_species) <= nrow(out))
})
