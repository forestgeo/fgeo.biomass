Plot dbh vs. biomass by species
================

``` r
# Setup
library(tidyverse)
library(fgeo.biomass)
```

-----

The goal is to plot dbh (x) versus biomass (y) by species
([issue](https://github.com/forestgeo/allodb/issues/73)).

Let’s first drop rows with missing `dbh` values as we can’t calculate
biomass for them.

``` r
census <- fgeo.biomass::scbi_tree1 %>% 
  filter(!is.na(dbh))
```

Let’s find allometric equations in allodb and calculate biomass.

``` r
species <- fgeo.biomass::scbi_species
census_species <- census %>% 
  add_species(species, site = "SCBI")
#> Adding `site`.
#> Overwriting `sp`; it now stores Latin species names.
#> Adding `rowid`.

census_equations <- allo_find(census_species)
#>   Guessing `dbh` in [mm] (required to find dbh-specific equations).
#> You may provide the `dbh` unit manually via the argument `dbh_unit`.
#> * Matching equations by site and species.
#> * Refining equations according to dbh.
#> * Using generic equations where expert equations can't be found.
#> Warning:   Can't find equations matching these species:
#>   acer sp, carya sp, crataegus sp, fraxinus sp, juniperus virginiana, quercus prinus, quercus sp, ulmus sp, unidentified unk
#> Warning: Can't find equations for 17132 rows (inserting `NA`).
```

Notice the warning that equations couldn’t be found. There may be two
reasons:

  - Some stems in the data belong to species with no matching species in
    allodb.
  - Some stems in the data belong to species that do match species in
    allodb but the available equations were designed for a dbh range
    that doesn’t include actual dbh values in the data.

Let’s drop those rows as we can’t calculate `biomass` for them.

``` r
census_equations2 <- census_equations %>% 
  filter(!is.na(eqn_id))
```

We can now calculate `biomass`.

``` r
biomass <- allo_evaluate(census_equations2)
#> Warning:   Detected a single stem per tree. Consider these properties of the result:
#>   * For trees, `biomass` is that of the main stem.
#>   * For shrubs, `biomass` is that of the entire shrub.
#>   Do you need a multi-stem table?
#> Guessing `dbh` in [mm]
#> You may provide the `dbh` unit manually via the argument `dbh_unit`.
#> Converting `dbh` based on `dbh_unit`.
#> `biomass` values are given in [kg].

biomass
#> # A tibble: 14,049 x 2
#>    rowid biomass
#>    <int>   <dbl>
#>  1     6   0.400
#>  2     8   5.69 
#>  3    17  11.3  
#>  4    21 231.   
#>  5    22  10.3  
#>  6    23   0.537
#>  7    26   4.15 
#>  8    29 469.   
#>  9    34   3.44 
#> 10    38   4.96 
#> # ... with 14,039 more rows
```

Notice the warning reminding us that we are using a tree-table (as
opposed to a stem-table), and informing us about how to interpret the
resulting `biomass` values for trees and shrubs.

Let’s add `biomass` to the data we’ve been using.

``` r
census_equations_biomass <- census_equations2 %>%
  right_join(biomass)
#> Joining, by = "rowid"

census_equations_biomass
#> # A tibble: 14,287 x 34
#>    rowid treeID stemID tag   StemTag sp    quadrat    gx     gy DBHID
#>    <int>  <int>  <int> <chr> <chr>   <chr> <chr>   <dbl>  <dbl> <int>
#>  1     6      6      6 12192 1       hama~ 0122     1.30 434       13
#>  2     8      8      8 12261 1       lind~ 0125    18    484.      17
#>  3    17     17     17 20031 1       lind~ 0201    37.1    7.40    40
#>  4    21     21     21 20064 1       liri~ 0217    31.4  322.      69
#>  5    22     22     22 20090 1       lind~ 0204    39.1   67.3     70
#>  6    23     23     23 20106 1       hama~ 0202    25.7   28.3     86
#>  7    26     26     26 20120 1       ilex~ 0202    22.3   32.6     96
#>  8    29     29     29 20151 1       acer~ 0203    31.5   45.8    130
#>  9    34     34     34 20169 1       lind~ 0203    37.2   53.4    149
#> 10    38     38     38 20181 1       frax~ 0203    29.8   59.2    169
#> # ... with 14,277 more rows, and 24 more variables: CensusID <int>,
#> #   dbh <dbl>, pom <chr>, hom <dbl>, ExactDate <chr>, DFstatus <chr>,
#> #   codes <chr>, nostems <dbl>, date <dbl>, status <chr>, agb <dbl>,
#> #   site <chr>, eqn_id <chr>, eqn <chr>, eqn_source <chr>, eqn_type <chr>,
#> #   anatomic_relevance <chr>, dbh_unit <chr>, bms_unit <chr>,
#> #   dbh_min_mm <dbl>, dbh_max_mm <dbl>, is_generic <lgl>, life_form <chr>,
#> #   biomass <dbl>
```

Now let’s make a box-plot of `biomass` by species.

``` r
census_equations_biomass %>% 
  ggplot(aes(sp, biomass)) +
  geom_boxplot() +
  ylab("biomass [kg]") +
  coord_flip()
```

<img src="dbh-vs-biomass_files/figure-gfm/unnamed-chunk-8-1.png" width="90%" />

Let’s explore `dbh` versus `biomass`.

``` r
census_equations_biomass %>% 
  # Convert agb from [Mg] to [kg]
  mutate(agb_kg = agb * 1e3) %>% 
  ggplot(aes(dbh, biomass)) + 
  # Reference based on allometries for tropical trees
  geom_point(aes(y = agb_kg), color = "grey", size = 4) +
  geom_point(aes(y = biomass, color = sp)) +
  ylab("Reference `agb` (grey) and calculated biomass (black) in [kg]") +
  xlab("dbh [mm]") +
  theme(legend.position = "bottom")
```

<img src="dbh-vs-biomass_files/figure-gfm/unnamed-chunk-9-1.png" width="90%" />

And now lets facet the plot by species.

``` r
census_equations_biomass %>% 
  # Convert agb from [Mg] to [kg]
  mutate(agb_kg = agb * 1e3) %>% 
  ggplot(aes(x = dbh)) +
  geom_point(aes(y = agb_kg), size = 1.5, color = "grey") +
  geom_point(aes(y = biomass), size = 1, color = "black") +
  facet_wrap("sp", ncol = 4) +
  ylab("Reference `agb` (grey) and calculated `biomass` (black) in [kg]") +
  xlab("dbh [mm]") +
  theme_bw()
```

<img src="dbh-vs-biomass_files/figure-gfm/unnamed-chunk-10-1.png" width="90%" />
