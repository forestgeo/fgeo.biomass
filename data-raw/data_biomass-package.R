noura_tree <- BIOMASS::NouraguesHD %>%
  as_tibble() %>%
  mutate(dbh = D, sp = paste(genus, species)) %>%
  select(-plotId, -genus, -species, -D)

use_data(noura_tree, overwrite = TRUE)

noura_species <- BIOMASS::NouraguesHD %>%
  as_tibble() %>%
  transmute(
    Latin = paste(genus, species),
    sp = Latin,
    species,
    genus,
  ) %>%
  unique()

use_data(noura_species, overwrite = TRUE)

# add_species(noura_tree, species, site = "noura")
