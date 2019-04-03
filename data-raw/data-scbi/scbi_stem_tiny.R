library(tidyverse)
library(fgeo.biomass)

set.seed(1)

path <- paste0(
  "https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/",
  "master/tree_main_census/data/census-csv-files/scbi.stem1.csv"
)

stem <- readr::read_csv(path) %>%
  group_by(treeID) %>%
  mutate(n = n_distinct(stemID)) %>%
  ungroup() %>%
  filter(n > 1) %>%
  arrange(treeID, stemID, tag, dbh) %>%
  filter(!is.na(dbh))

spp <- allodb::master_tidy() %>%
  filter(
    site == "scbi",
    str_detect(tolower(life_form), "shrub"),
    grepl("dbh", equation_form),
    !grepl("[^a-z]h[^a-z]", equation_form),
  ) %>%
  pull(species) %>%
  unique()

dbh_dependent_shrub_codes <- fgeo.biomass::scbi_species %>%
  filter(Latin %in% spp) %>%
  pull(sp)

common_min_dbh_for_trees <- 85
ids_tree <- stem %>%
  filter(!sp %in% dbh_dependent_shrub_codes) %>%
  fgeo.tool::pick_main_stem() %>%
  filter(dbh > common_min_dbh_for_trees) %>%
  sample_n(5) %>%
  pull(treeID)
scbi_stem_tiny_tree <- stem %>%
  filter(treeID %in% ids_tree) %>%
  select(-n)

use_data(scbi_stem_tiny_tree, overwrite =  TRUE)



pick_independent_variable <- function(indep_var) {
  set.seed(1)

  spp <- allodb::master_tidy() %>%
    filter(
      site == "scbi",
      str_detect(tolower(life_form), "shrub"),
      grepl(indep_var, equation_form),
      !grepl("[^a-z]h[^a-z]", equation_form),
    ) %>%
    pull(species) %>%
    unique()

  shrub_dbh <- fgeo.biomass::scbi_species %>%
    filter(Latin %in% spp) %>%
    pull(sp)

  common_min_dbh_for_shrubs <- 30

  ids <- stem %>%
    filter(sp %in% shrub_dbh) %>%
    fgeo.tool::pick_main_stem() %>%
    filter(dbh > common_min_dbh_for_shrubs) %>%
    sample_n(5) %>%
    pull(treeID)

  stem %>%
    filter(treeID %in% ids) %>%
    select(-n)
}

scbi_stem_tiny_shrub <- bind_rows(
  pick_independent_variable("dbh"),
  pick_independent_variable("dba")
)

use_data(scbi_stem_tiny_shrub, overwrite = TRUE)
