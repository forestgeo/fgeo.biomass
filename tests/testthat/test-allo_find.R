context("allo_find")

library(dplyr)
set.seed(1)

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

test_that("allo_find informs expected dbh units in [mm]", {
  cns_sp <- fgeo.biomass::scbi_tree1 %>%
    dplyr::sample_n(30) %>%
    add_species(fgeo.biomass::scbi_species, "scbi")

  expect_message(
    suppressWarnings(allo_find(cns_sp)),
    "Assuming.*dbh.*in.*mm"
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

test_that("allo_find errs if custom_eqn is not created with as_eqn", {
  census <- dplyr::sample_n(fgeo.biomass::scbi_tree1, 30)
  species <- fgeo.biomass::scbi_species
  census_species <- add_species(
    census, species,
    site = "scbi"
  )
  your_equations <- tibble::tibble(
    equation_id = c("000001"),
    site = c("scbi"),
    sp = c("paulownia tomentosa"),
    eqn = c("exp(-2.48 + 2.4835 * log(dbh))"),
    eqn_type = c("mixed_hardwood"),
    anatomic_relevance = c("total aboveground biomass")
  )

  expect_error(
    suppressWarnings(allo_find(census_species, custom_eqn = your_equations)),
    "must be of class 'eqn'"
  )
})
