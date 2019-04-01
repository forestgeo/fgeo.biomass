
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
#>  1  14548  14548 1112~ 1       caovl 1111    217.  213.  19996        1
#>  2   8588   8588 70589 1       litu  0714    139.  272.  12835        1
#>  3  19240  19240 1404~ 1       libe  1402    279.   30.5 25749        1
#>  4  20907  20907 1503~ 1       ulru  1501    286    14.7 27713        1
#>  5  16376  16376 1212~ 1       cato  1209    228.  176.  22356        1
#>  6  37228     NA 2015~ <NA>    libe  2011    380   204.     NA       NA
#>  7  38646     NA 23165 <NA>    libe  0205     36.1  94.5    NA       NA
#>  8  10918  10918 90674 1       havi  0914    168.  271.  15552        1
#>  9  35757     NA 1834~ <NA>    libe  1808    356.  160.     NA       NA
#> 10  36032     NA 1915~ <NA>    libe  1911    373.  205.     NA       NA
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
#>  1 caovl
#>  2 litu 
#>  3 libe 
#>  4 ulru 
#>  5 cato 
#>  6 libe 
#>  7 libe 
#>  8 havi 
#>  9 libe 
#> 10 libe 
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
#>  1 carya ovalis           
#>  2 liriodendron tulipifera
#>  3 lindera benzoin        
#>  4 ulmus rubra            
#>  5 carya tomentosa        
#>  6 lindera benzoin        
#>  7 lindera benzoin        
#>  8 hamamelis virginiana   
#>  9 lindera benzoin        
#> 10 lindera benzoin        
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
#>   acer sp, carya sp, crataegus sp, fraxinus sp, quercus prinus, quercus sp, ulmus sp, unidentified unk
#> Warning: Can't find equations for 3239 rows (inserting `NA`).

equations
#> # A tibble: 5,035 x 32
#>    rowid treeID stemID tag   StemTag sp    quadrat    gx    gy DBHID
#>    <int>  <int>  <int> <chr> <chr>   <chr> <chr>   <dbl> <dbl> <int>
#>  1     1  14548  14548 1112~ 1       cary~ 1111    217.  213.  19996
#>  2     2   8588   8588 70589 1       liri~ 0714    139.  272.  12835
#>  3     3  19240  19240 1404~ 1       lind~ 1402    279.   30.5 25749
#>  4     4  20907  20907 1503~ 1       ulmu~ 1501    286    14.7 27713
#>  5     5  16376  16376 1212~ 1       cary~ 1209    228.  176.  22356
#>  6     6  37228     NA 2015~ <NA>    lind~ 2011    380   204.     NA
#>  7     7  38646     NA 23165 <NA>    lind~ 0205     36.1  94.5    NA
#>  8     8  10918  10918 90674 1       hama~ 0914    168.  271.  15552
#>  9     9  35757     NA 1834~ <NA>    lind~ 1808    356.  160.     NA
#> 10    10  36032     NA 1915~ <NA>    lind~ 1911    373.  205.     NA
#> # ... with 5,025 more rows, and 22 more variables: CensusID <int>,
#> #   dbh <dbl>, pom <chr>, hom <dbl>, ExactDate <chr>, DFstatus <chr>,
#> #   codes <chr>, nostems <dbl>, date <dbl>, status <chr>, agb <dbl>,
#> #   site <chr>, equation_id <chr>, eqn <chr>, eqn_source <chr>,
#> #   eqn_type <chr>, anatomic_relevance <chr>, dbh_unit <chr>,
#> #   bms_unit <chr>, dbh_min_mm <dbl>, dbh_max_mm <dbl>, is_generic <lgl>
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
#> Guessing `dbh` in [mm]
#> You may provide the `dbh` unit manually via the argument `dbh_unit`.
#> Converting `dbh` based on `dbh_unit`.
#> `biomass` values are given in [kg].
#> Warning: Can't convert all units (inserting 3239 missing values):
#> the 'to' argument is not an acceptable unit.
#> Warning: Can't convert all units (inserting 3239 missing values):
#> the 'from' argument is not an acceptable unit.
#> Warning: Can't evaluate all equations (inserting 29 missing values):
#> object 'dba' not found
#> Warning: `biomass` may be invalid. This is still work in progress.
biomass
#> # A tibble: 5,000 x 2
#>    rowid biomass
#>    <int>   <dbl>
#>  1     1    230.
#>  2     2    209.
#>  3     3     NA 
#>  4     4    214.
#>  5     5     NA 
#>  6     6     NA 
#>  7     7     NA 
#>  8     8     NA 
#>  9     9     NA 
#> 10    10     NA 
#> # ... with 4,990 more rows

with_biomass <- biomass %>% right_join(equations)
#> Joining, by = "rowid"

with_biomass %>% 
  select(eqn, dbh, biomass)
#> # A tibble: 5,035 x 3
#>    eqn                                  dbh biomass
#>    <chr>                              <dbl>   <dbl>
#>  1 10^(-1.326 + 2.762 * (log10(dbh))) 216.     230.
#>  2 10^(-1.236 + 2.635 * (log10(dbh))) 224.     209.
#>  3 <NA>                                10.4     NA 
#>  4 2.17565 * (dbh^2)^1.2481           219      214.
#>  5 <NA>                                22.2     NA 
#>  6 <NA>                                NA       NA 
#>  7 <NA>                                NA       NA 
#>  8 <NA>                                62.8     NA 
#>  9 <NA>                                NA       NA 
#> 10 <NA>                                NA       NA 
#> # ... with 5,025 more rows
```

Commonly we would further summarize the result. For that you can use the
**dplyr** package or any general purpose tool. For example, this summary
gives the total biomass for each species in descending order.

``` r
with_biomass %>% 
  group_by(sp) %>% 
  summarize(total_biomass = sum(biomass, na.rm = TRUE)) %>% 
  arrange(desc(total_biomass))
#> # A tibble: 57 x 2
#>    sp                      total_biomass
#>    <chr>                           <dbl>
#>  1 liriodendron tulipifera       143694.
#>  2 quercus velutina              110923.
#>  3 carya glabra                   45350.
#>  4 quercus alba                   38318.
#>  5 quercus rubra                  25880.
#>  6 juglans nigra                  21318.
#>  7 carya tomentosa                19183.
#>  8 fraxinus americana             17213.
#>  9 carya cordiformis              10377.
#> 10 carya ovalis                    8992.
#> # ... with 47 more rows
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
