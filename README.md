
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src="https://i.imgur.com/vTLlhbp.png" align="right" height=88 /> Calculate biomass

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/forestgeo/fgeo.biomass.svg?branch=master)](https://travis-ci.org/forestgeo/fgeo.biomass)
[![Coverage
status](https://coveralls.io/repos/github/forestgeo/fgeo.biomass/badge.svg)](https://coveralls.io/r/forestgeo/fgeo.biomass?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/fgeo.biomass)](https://cran.r-project.org/package=fgeo.biomass)

The goal of **fgeo.biomass** is to calculate biomass using best
available allometric-equations from the
[**allodb**](https://forestgeo.github.io/allodb/) package.

## Warning

This package is not ready for research. We are now building a [Minimum
Viable Product](https://en.wikipedia.org/wiki/Minimum_viable_product),
with just enough features to collect feedback from alpha users and
redirect our effort. The resulting biomass is still meaningless. For a
working product see the
[BIOMASS](https://CRAN.R-project.org/package=BIOMASS) package.

## Installation

Install the development version of **fgeo.biomass** with:

    # install.packages("devtools")
    devtools::install_github("forestgeo/fgeo.biomass")

## Example

In addition to **fgeo.biomass**, here we will use some other general
purpose packages for manipulating data.

``` r
library(fgeo.biomass)
library(dplyr)
library(tidyr)
```

As an example, we will use census and species datasets from the
ForestGEO plot at the [Smithsonian Conservation Biology
Institute](https://forestgeo.si.edu/sites/north-america/smithsonian-conservation-biology-institute)
(SCBI). This is a relatively large dataset. For a quick example we’ll
pick just a few rows.

``` r
census <- fgeo.biomass::scbi_tree1 %>% 
  # Pick a few rows for speed
  sample_n(5000)

census
#> # A tibble: 5,000 x 20
#>    treeID stemID tag   StemTag sp    quadrat    gx    gy DBHID CensusID
#>     <int>  <int> <chr> <chr>   <chr> <chr>   <dbl> <dbl> <int>    <int>
#>  1  11356  11356 92193 1       nysy  0921     171  410.  16077        1
#>  2  10892  10892 90648 1       caca  0912     160. 229.  15521        1
#>  3  30255  30255 2012~ 1       juni  2013     380. 257.  39164        1
#>  4  37112     NA 1939~ <NA>    libe  1909     375. 170.     NA       NA
#>  5  21991  21991 1522~ 1       astr  1521     288. 402   29086        1
#>  6  33883     NA 1530~ <NA>    libe  1502     290.  36.3    NA       NA
#>  7  22812  22812 1604~ 1       libe  1603     309.  41.5 30146        1
#>  8  29025  29025 1926~ 1       astr  1926     377. 515.  37635        1
#>  9  31794     NA 1132~ <NA>    libe  1106     212. 116.     NA       NA
#> 10   6484   6484 50613 1       quru  0512      93  233.  10161        1
#> # ... with 4,990 more rows, and 10 more variables: dbh <dbl>, pom <chr>,
#> #   hom <dbl>, ExactDate <chr>, DFstatus <chr>, codes <chr>,
#> #   nostems <dbl>, date <dbl>, status <chr>, agb <dbl>
```

To match the census data with the best available allometric-equations we
need (a) the name of the ForestGEO site (here “scbi”), and (b) each
species’ Latin name. But instead of Latin names, ForestGEO’s *census*
tables record species codes.

``` r
# To search for specific columns in the datasets
sp_or_latin <- "^sp$|^Latin$"

census %>% 
  select(matches(sp_or_latin))
#> # A tibble: 5,000 x 1
#>    sp   
#>    <chr>
#>  1 nysy 
#>  2 caca 
#>  3 juni 
#>  4 libe 
#>  5 astr 
#>  6 libe 
#>  7 libe 
#>  8 astr 
#>  9 libe 
#> 10 quru 
#> # ... with 4,990 more rows
```

The species’ Latin names are recorded in *species* tables.

``` r
species <- fgeo.biomass::scbi_species

species %>% 
  select(matches(sp_or_latin))
#> # A tibble: 73 x 2
#>    sp    Latin               
#>    <chr> <chr>               
#>  1 acne  Acer negundo        
#>  2 acpl  Acer platanoides    
#>  3 acru  Acer rubrum         
#>  4 acsp  Acer sp             
#>  5 aial  Ailanthus altissima 
#>  6 amar  Amelanchier arborea 
#>  7 astr  Asimina triloba     
#>  8 beth  Berberis thunbergii 
#>  9 caca  Carpinus caroliniana
#> 10 caco  Carya cordiformis   
#> # ... with 63 more rows
```

We can then add species’ Latin names to the census data by joining the
*census* and *species* tables. We may do that with `dplyr::left_join()`
but `fgeo.biomass::add_species()` is more specialized.

``` r
census_species <- census %>%
  add_species(species, "scbi")
#> Adding `site`.
#> Overwriting `sp`; it now stores Latin species names.
#> Adding `rowid`.

census_species %>% 
  select(matches(sp_or_latin))
#> # A tibble: 5,000 x 1
#>    sp                  
#>  * <chr>               
#>  1 nyssa sylvatica     
#>  2 carpinus caroliniana
#>  3 juglans nigra       
#>  4 lindera benzoin     
#>  5 asimina triloba     
#>  6 lindera benzoin     
#>  7 lindera benzoin     
#>  8 asimina triloba     
#>  9 lindera benzoin     
#> 10 quercus rubra       
#> # ... with 4,990 more rows
```

### Finding the best available allometric-equations

Before we added the Latin name of each species to the census data into
the `sp` column. Now we want to find the best available
allometric-equations for as many rows as possible with `allo_find()`. We
may not have allometric equations form all species. Although the code
will eventually fall back to more general equations, for now we just
drop the rows that don’t match the available species for the specified
site.

``` r
equations <- census_species %>% 
  allo_find()
#>   Guessing `dbh` in [mm] (required to find dbh-specific equations).
#> You may provide the `dbh` unit manually via the argument `dbh_unit`.
#> * Matching equations by site and species.
#> * Refining equations according to dbh.
#> * Using generic equations where expert equations can't be found.
#> Warning:   Can't find equations matching these species:
#>   carya sp, crataegus sp, fraxinus sp, hamamelis virginiana, juniperus virginiana, lonicera maackii, quercus prinus, quercus sp, rosa multiflora, rubus allegheniensis, rubus phoenicolasius, ulmus sp, unidentified unk, viburnum prunifolium
#> Warning: Can't find equations for 3267 rows (inserting `NA`).

equations
#> # A tibble: 5,025 x 33
#>    rowid treeID stemID tag   StemTag sp    quadrat    gx    gy DBHID
#>    <int>  <int>  <int> <chr> <chr>   <chr> <chr>   <dbl> <dbl> <int>
#>  1     1  11356  11356 92193 1       nyss~ 0921     171  410.  16077
#>  2     2  10892  10892 90648 1       carp~ 0912     160. 229.  15521
#>  3     3  30255  30255 2012~ 1       jugl~ 2013     380. 257.  39164
#>  4     4  37112     NA 1939~ <NA>    lind~ 1909     375. 170.     NA
#>  5     5  21991  21991 1522~ 1       asim~ 1521     288. 402   29086
#>  6     6  33883     NA 1530~ <NA>    lind~ 1502     290.  36.3    NA
#>  7     7  22812  22812 1604~ 1       lind~ 1603     309.  41.5 30146
#>  8     8  29025  29025 1926~ 1       asim~ 1926     377. 515.  37635
#>  9     9  31794     NA 1132~ <NA>    lind~ 1106     212. 116.     NA
#> 10    10   6484   6484 50613 1       quer~ 0512      93  233.  10161
#> # ... with 5,015 more rows, and 23 more variables: CensusID <int>,
#> #   dbh <dbl>, pom <chr>, hom <dbl>, ExactDate <chr>, DFstatus <chr>,
#> #   codes <chr>, nostems <dbl>, date <dbl>, status <chr>, agb <dbl>,
#> #   site <chr>, eqn_id <chr>, eqn <chr>, eqn_source <chr>, eqn_type <chr>,
#> #   anatomic_relevance <chr>, dbh_unit <chr>, bms_unit <chr>,
#> #   dbh_min_mm <dbl>, dbh_max_mm <dbl>, is_generic <lgl>, life_form <chr>
```

### Calculating biomass

For the rows for which an equation was found in **allodb**, we can now
calculate biomass. `allo_evaluate()` evaluates each allometric equation
by replacing the literal string “dbh” with the corresponding value for
each row in the `dbh` column, then doing the actual computation and
storing the result in the the new `biomass` column.

``` r
biomass <- equations %>% 
  allo_evaluate()
#> Warning:   Detected a single stem per tree. Consider these properties of the result:
#>   * For trees, `biomass` is that of the main stem.
#>   * For shrubs, `biomass` is that of the entire shrub.
#>   Do you need a multi-stem table?
#> Guessing `dbh` in [mm]
#> You may provide the `dbh` unit manually via the argument `dbh_unit`.
#> Converting `dbh` based on `dbh_unit`.
#> `biomass` values are given in [kg].
#> Warning: Can't convert all units (inserting 3267 missing values):
#> the 'to' argument is not an acceptable unit.
#> Warning: Can't convert all units (inserting 3267 missing values):
#> the 'from' argument is not an acceptable unit.
#> Joining, by = c("rowid", "treeID", "stemID", "tag", "StemTag", "sp", "quadrat", "gx", "gy", "DBHID", "CensusID", "dbh", "pom", "hom", "ExactDate", "DFstatus", "codes", "nostems", "date", "status", "agb", "site", "eqn_id", "eqn", "eqn_source", "eqn_type", "anatomic_relevance", "dbh_unit", "bms_unit", "dbh_min_mm", "dbh_max_mm", "is_generic", "life_form", "presplit_rowid", "is_shrub")
biomass
#> # A tibble: 5,000 x 2
#>    rowid biomass
#>    <int>   <dbl>
#>  1     1   11.8 
#>  2     2    1.60
#>  3     3 1769.  
#>  4     4   NA   
#>  5     5   NA   
#>  6     6   NA   
#>  7     7   NA   
#>  8     8   NA   
#>  9     9   NA   
#> 10    10   NA   
#> # ... with 4,990 more rows

with_biomass <- biomass %>% right_join(equations)
#> Joining, by = "rowid"

with_biomass %>% 
  select(eqn, dbh, biomass)
#> # A tibble: 5,025 x 3
#>    eqn                                dbh biomass
#>    <chr>                            <dbl>   <dbl>
#>  1 2.56795 * (dbh^2)^1.18685         67.4   11.8 
#>  2 exp(-2.48 + 2.4835 * log(dbh))    32.8    1.60
#>  3 exp(-2.5095 + 2.6175 * log(dbh)) 454.  1769.  
#>  4 <NA>                              NA     NA   
#>  5 <NA>                              23.8   NA   
#>  6 <NA>                              NA     NA   
#>  7 <NA>                              12     NA   
#>  8 <NA>                              13.3   NA   
#>  9 <NA>                              NA     NA   
#> 10 <NA>                             668.    NA   
#> # ... with 5,015 more rows
```

Commonly we would further summarize the result. For that you can use the
**dplyr** package or any general purpose tool. For example, this summary
gives the total biomass for each species in descending order.

``` r
with_biomass %>% 
  group_by(sp) %>% 
  summarize(total_biomass = sum(biomass, na.rm = TRUE)) %>% 
  arrange(desc(total_biomass))
#> # A tibble: 56 x 2
#>    sp                      total_biomass
#>    <chr>                           <dbl>
#>  1 liriodendron tulipifera       168975.
#>  2 quercus velutina              108593.
#>  3 carya glabra                   43604.
#>  4 quercus alba                   33349.
#>  5 carya tomentosa                26200.
#>  6 fraxinus americana             22532.
#>  7 quercus rubra                  13947.
#>  8 juglans nigra                  10756.
#>  9 fagus grandifolia               8997.
#> 10 carya ovalis                    8673.
#> # ... with 46 more rows
```

### Issues

Our progress is recorded in this [Kanban project
board](https://github.com/forestgeo/allodb/projects/4). Because we still
don’t support some features, the the biomass result currently is invalid
and excludes some trees.

Issues that result in invalid biomass:

  - We still don’t handle units correctly
    (<https://github.com/forestgeo/allodb/issues/42>).

Issues that result in data loss:

  - The output excludes equations that apply to only part of a tree
    instead of the whole tree
    (<https://github.com/forestgeo/allodb/issues/63>,
    <https://github.com/forestgeo/fgeo.biomass/issues/9>).

  - We exclude equations from shrubs
    (<https://github.com/forestgeo/allodb/issues/41>).

## General information

  - [Getting help](SUPPORT.md).
  - [Contributing](CONTRIBUTING.md).
  - [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

## Related project

  - [BIOMASS](https://CRAN.R-project.org/package=BIOMASS)

<!-- end list -->

    A BibTeX entry for LaTeX users is
    
      @Article{,
        title = {BIOMASS : an {R} package for estimating above-ground biomass and its uncertainty in tropical forests},
        volume = {8},
        issn = {2041210X},
        url = {http://doi.wiley.com/10.1111/2041-210X.12753},
        doi = {10.1111/2041-210X.12753},
        language = {en},
        number = {9},
        urldate = {2018-12-13},
        journal = {Methods in Ecology and Evolution},
        author = {Maxime Rejou-Mechain and Ariane Tanguy and Camille Piponiot and Jerome Chave and Bruno Herault},
        editor = {Sarah Goslee},
        year = {2017},
      }
