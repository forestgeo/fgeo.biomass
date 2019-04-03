
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
#>    treeID stemID tag   StemTag sp    quadrat    gx     gy DBHID CensusID
#>     <int>  <int> <chr> <chr>   <chr> <chr>   <dbl>  <dbl> <int>    <int>
#>  1   1180   1180 10210 1       libe  0104      9.5  71.8   3432        1
#>  2  22948  22948 1606~ 1       libe  1603    309.   48.8  30349        1
#>  3  11645  11645 92501 1       litu  0929    178.  563.   16378        1
#>  4  39674     NA 81028 <NA>    ceca  0907    163.  135.      NA       NA
#>  5  11558  11558 92411 1       acru  0926    170.  507    16289        1
#>  6  29100  29100 1927~ 1       fram  1932    362.  625.   37717        1
#>  7   9069   9069 72430 1       ceca  0731    140.  607.   13344        1
#>  8  37529     NA 2030~ <NA>    libe  2001    390.    8.10    NA       NA
#>  9  32072     NA 1232~ <NA>    libe  1206    230.  119.      NA       NA
#> 10   8503   8503 70501 1       caca  0710    136.  181    12729        1
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
#>  3 litu 
#>  4 ceca 
#>  5 acru 
#>  6 fram 
#>  7 ceca 
#>  8 libe 
#>  9 libe 
#> 10 caca 
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
#>  3 liriodendron tulipifera
#>  4 cercis canadensis      
#>  5 acer rubrum            
#>  6 fraxinus americana     
#>  7 cercis canadensis      
#>  8 lindera benzoin        
#>  9 lindera benzoin        
#> 10 carpinus caroliniana   
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
#>   carya sp, crataegus sp, fraxinus sp, quercus prinus, quercus sp, ulmus sp, unidentified unk
#> Warning: Can't find equations for 3252 rows (inserting `NA`).

equations
#> # A tibble: 5,022 x 33
#>    rowid treeID stemID tag   StemTag sp    quadrat    gx     gy DBHID
#>    <int>  <int>  <int> <chr> <chr>   <chr> <chr>   <dbl>  <dbl> <int>
#>  1     1   1180   1180 10210 1       lind~ 0104      9.5  71.8   3432
#>  2     2  22948  22948 1606~ 1       lind~ 1603    309.   48.8  30349
#>  3     3  11645  11645 92501 1       liri~ 0929    178.  563.   16378
#>  4     4  39674     NA 81028 <NA>    cerc~ 0907    163.  135.      NA
#>  5     5  11558  11558 92411 1       acer~ 0926    170.  507    16289
#>  6     6  29100  29100 1927~ 1       frax~ 1932    362.  625.   37717
#>  7     7   9069   9069 72430 1       cerc~ 0731    140.  607.   13344
#>  8     8  37529     NA 2030~ <NA>    lind~ 2001    390.    8.10    NA
#>  9     9  32072     NA 1232~ <NA>    lind~ 1206    230.  119.      NA
#> 10    10   8503   8503 70501 1       carp~ 0710    136.  181    12729
#> # ... with 5,012 more rows, and 23 more variables: CensusID <int>,
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
#>  1     1    2.98
#>  2     2   NA   
#>  3     3  130.  
#>  4     4   NA   
#>  5     5   67.6 
#>  6     6  648.  
#>  7     7    8.81
#>  8     8   NA   
#>  9     9   NA   
#> 10    10   13.3 
#> # ... with 4,990 more rows

with_biomass <- biomass %>% right_join(equations)
#> Joining, by = "rowid"

with_biomass %>% 
  select(eqn, dbh, biomass)
#> # A tibble: 5,022 x 3
#>    eqn                                        dbh biomass
#>    <chr>                                    <dbl>   <dbl>
#>  1 exp(-2.2118 + 2.4133 * log(dbh))          39.3    2.98
#>  2 <NA>                                      23.2   NA   
#>  3 10^(-1.236 + 2.635 * (log10(dbh)))       187.   130.  
#>  4 <NA>                                      NA     NA   
#>  5 exp(4.5893 + 2.43 * log(dbh))            147     67.6 
#>  6 3.203 + (-0.234 * dbh) + 0.006 * (dbh^2) 348    648.  
#>  7 exp(-2.5095 + 2.5437 * log(dbh))          63.1    8.81
#>  8 <NA>                                      NA     NA   
#>  9 <NA>                                      NA     NA   
#> 10 exp(-2.48 + 2.4835 * log(dbh))            76.9   13.3 
#> # ... with 5,012 more rows
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
#>  1 liriodendron tulipifera       162662.
#>  2 quercus velutina              107577.
#>  3 carya glabra                   38897.
#>  4 quercus alba                   37609.
#>  5 quercus rubra                  34530.
#>  6 carya tomentosa                24536.
#>  7 juglans nigra                  18711.
#>  8 fraxinus americana             18102.
#>  9 carya ovalis                   15899.
#> 10 nyssa sylvatica                 7760.
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
