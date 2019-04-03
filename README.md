
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
#>  1  19017  19017 1401~ 1       libe  1402    275    28.8 25496        1
#>  2  34342     NA 1631~ <NA>    libe  1602    306.   23.6    NA       NA
#>  3  18511  18511 1321~ 1       qual  1321    250   401.  24966        1
#>  4   9140   9140 80038 1       amar  0802    145.   37.1 13421        1
#>  5   4721   4721 32500 1       cato  0331     56.4 608.   7934        1
#>  6  33381     NA 1433~ <NA>    prse  1407    267.  126      NA       NA
#>  7  25486  25486 1721~ 1       nysy  1724    322.  474.  33423        1
#>  8  34575     NA 1633~ <NA>    libe  1605    320.   99.7    NA       NA
#>  9  27828  27828 1902~ 1       libe  1903    372.   48   36244        1
#> 10  18314  18314 1314~ 1       astr  1316    253.  300.  24732        1
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
#>  1 libe 
#>  2 libe 
#>  3 qual 
#>  4 amar 
#>  5 cato 
#>  6 prse 
#>  7 nysy 
#>  8 libe 
#>  9 libe 
#> 10 astr 
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
#>  1 lindera benzoin    
#>  2 lindera benzoin    
#>  3 quercus alba       
#>  4 amelanchier arborea
#>  5 carya tomentosa    
#>  6 prunus serotina    
#>  7 nyssa sylvatica    
#>  8 lindera benzoin    
#>  9 lindera benzoin    
#> 10 asimina triloba    
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
#>   carya sp, crataegus sp, fraxinus sp, hamamelis virginiana, juniperus virginiana, quercus prinus, quercus sp, rosa multiflora, rubus allegheniensis, rubus phoenicolasius, ulmus sp, unidentified unk, viburnum prunifolium
#> Warning: Can't find equations for 3281 rows (inserting `NA`).

equations
#> # A tibble: 5,029 x 33
#>    rowid treeID stemID tag   StemTag sp    quadrat    gx    gy DBHID
#>    <int>  <int>  <int> <chr> <chr>   <chr> <chr>   <dbl> <dbl> <int>
#>  1     1  19017  19017 1401~ 1       lind~ 1402    275    28.8 25496
#>  2     2  34342     NA 1631~ <NA>    lind~ 1602    306.   23.6    NA
#>  3     3  18511  18511 1321~ 1       quer~ 1321    250   401.  24966
#>  4     4   9140   9140 80038 1       amel~ 0802    145.   37.1 13421
#>  5     4   9140   9140 80038 1       amel~ 0802    145.   37.1 13421
#>  6     5   4721   4721 32500 1       cary~ 0331     56.4 608.   7934
#>  7     6  33381     NA 1433~ <NA>    prun~ 1407    267.  126      NA
#>  8     7  25486  25486 1721~ 1       nyss~ 1724    322.  474.  33423
#>  9     8  34575     NA 1633~ <NA>    lind~ 1605    320.   99.7    NA
#> 10     9  27828  27828 1902~ 1       lind~ 1903    372.   48   36244
#> # ... with 5,019 more rows, and 23 more variables: CensusID <int>,
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
biomass
#> # A tibble: 5,000 x 2
#>    rowid biomass
#>    <int>   <dbl>
#>  1     1   NA   
#>  2     2   NA   
#>  3     3  967.  
#>  4     4    2.10
#>  5     5  183.  
#>  6     6   NA   
#>  7     7   27.8 
#>  8     8   NA   
#>  9     9   NA   
#> 10    10    3.63
#> # ... with 4,990 more rows

with_biomass <- biomass %>% right_join(equations)
#> Joining, by = "rowid"

with_biomass %>% 
  select(eqn, dbh, biomass)
#> # A tibble: 5,029 x 3
#>    eqn                                   dbh biomass
#>    <chr>                               <dbl>   <dbl>
#>  1 <NA>                                 15.1   NA   
#>  2 <NA>                                 NA     NA   
#>  3 10^(-1.266 + 2.613 * (log10(dbh)))  424.   967.  
#>  4 10^(2.5368 + 1.3197 * (log10(dbh)))  85.8    2.10
#>  5 10^(2.0865 + 0.9449 * (log10(dbh)))  85.8    2.10
#>  6 10^(-1.326 + 2.762 * (log10(dbh)))  199.   183.  
#>  7 <NA>                                 NA     NA   
#>  8 2.56795 * (dbh^2)^1.18685            96.7   27.8 
#>  9 <NA>                                 NA     NA   
#> 10 <NA>                                 22.5   NA   
#> # ... with 5,019 more rows
```

Commonly we would further summarize the result. For that you can use the
**dplyr** package or any general purpose tool. For example, this summary
gives the total biomass for each species in descending order.

``` r
with_biomass %>% 
  group_by(sp) %>% 
  summarize(total_biomass = sum(biomass, na.rm = TRUE)) %>% 
  arrange(desc(total_biomass))
#> # A tibble: 55 x 2
#>    sp                      total_biomass
#>    <chr>                           <dbl>
#>  1 liriodendron tulipifera       135487.
#>  2 quercus velutina              128961.
#>  3 quercus alba                   45888.
#>  4 juglans nigra                  34762.
#>  5 carya glabra                   33651.
#>  6 quercus rubra                  25647.
#>  7 carya tomentosa                23494.
#>  8 fraxinus americana             23372.
#>  9 carya cordiformis              12760.
#> 10 carya ovalis                   12220.
#> # ... with 45 more rows
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
