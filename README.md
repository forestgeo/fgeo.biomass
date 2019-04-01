
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
#>  1  26087  26087 1801~ 1       libe  1802    348.   31.8  34105        1
#>  2  37673     NA 2031~ <NA>    libe  2003    383.   40.9     NA       NA
#>  3   5013   5013 40536 1       fagr  0405     78.7  88.1   8331        1
#>  4  23111  23111 1607~ 1       cato  1610    310.  181.   30542        1
#>  5  24181  24181 1702~ 1       ulru  1701    335.    1.60 31778        1
#>  6  37944     NA 2034~ <NA>    libe  2004    399.   61.7     NA       NA
#>  7  38386     NA 2039~ <NA>    libe  2009    385.  160.      NA       NA
#>  8   8509   8509 70507 1       caca  0710    133.  180.   12736        1
#>  9   8863   8863 72220 1       litu  0722    134.  421.   13132        1
#> 10  35559     NA 1832~ <NA>    libe  1805    341    91.5     NA       NA
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
#>  3 fagr 
#>  4 cato 
#>  5 ulru 
#>  6 libe 
#>  7 libe 
#>  8 caca 
#>  9 litu 
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
#>  1 lindera benzoin        
#>  2 lindera benzoin        
#>  3 fagus grandifolia      
#>  4 carya tomentosa        
#>  5 ulmus rubra            
#>  6 lindera benzoin        
#>  7 lindera benzoin        
#>  8 carpinus caroliniana   
#>  9 liriodendron tulipifera
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
#>   carya sp, crataegus sp, fraxinus sp, quercus prinus, ulmus sp, unidentified unk
#> Warning: Can't find equations for 3221 rows (inserting `NA`).

equations
#> # A tibble: 5,032 x 33
#>    rowid treeID stemID tag   StemTag sp    quadrat    gx     gy DBHID
#>    <int>  <int>  <int> <chr> <chr>   <chr> <chr>   <dbl>  <dbl> <int>
#>  1     1  26087  26087 1801~ 1       lind~ 1802    348.   31.8  34105
#>  2     2  37673     NA 2031~ <NA>    lind~ 2003    383.   40.9     NA
#>  3     3   5013   5013 40536 1       fagu~ 0405     78.7  88.1   8331
#>  4     4  23111  23111 1607~ 1       cary~ 1610    310.  181.   30542
#>  5     5  24181  24181 1702~ 1       ulmu~ 1701    335.    1.60 31778
#>  6     6  37944     NA 2034~ <NA>    lind~ 2004    399.   61.7     NA
#>  7     7  38386     NA 2039~ <NA>    lind~ 2009    385.  160.      NA
#>  8     8   8509   8509 70507 1       carp~ 0710    133.  180.   12736
#>  9     9   8863   8863 72220 1       liri~ 0722    134.  421.   13132
#> 10    10  35559     NA 1832~ <NA>    lind~ 1805    341    91.5     NA
#> # ... with 5,022 more rows, and 23 more variables: CensusID <int>,
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
#> Guessing `dbh` in [mm]
#> You may provide the `dbh` unit manually via the argument `dbh_unit`.
#> Converting `dbh` based on `dbh_unit`.
#> `biomass` values are given in [kg].
#> Warning: Can't convert all units (inserting 3221 missing values):
#> the 'to' argument is not an acceptable unit.
#> Warning: Can't convert all units (inserting 3221 missing values):
#> the 'from' argument is not an acceptable unit.
#> Warning: Can't evaluate all equations (inserting 36 missing values):
#> object 'dba' not found
#> Warning: `biomass` may be invalid. This is still work in progress.
biomass
#> # A tibble: 5,000 x 2
#>    rowid biomass
#>    <int>   <dbl>
#>  1     1   NA   
#>  2     2   NA   
#>  3     3   67.4 
#>  4     4   99.6 
#>  5     5   46.4 
#>  6     6   NA   
#>  7     7   NA   
#>  8     8    3.41
#>  9     9 1007.  
#> 10    10   NA   
#> # ... with 4,990 more rows

with_biomass <- biomass %>% right_join(equations)
#> Joining, by = "rowid"

with_biomass %>% 
  select(eqn, dbh, biomass)
#> # A tibble: 5,032 x 3
#>    eqn                                  dbh biomass
#>    <chr>                              <dbl>   <dbl>
#>  1 <NA>                                14.7   NA   
#>  2 <NA>                                NA     NA   
#>  3 10^(2.1112 + 2.462 * (log10(dbh))) 127     67.4 
#>  4 10^(-1.326 + 2.762 * (log10(dbh))) 160.    99.6 
#>  5 2.17565 * (dbh^2)^1.2481           119.    46.4 
#>  6 <NA>                                NA     NA   
#>  7 <NA>                                NA     NA   
#>  8 exp(-2.48 + 2.4835 * log(dbh))      44.5    3.41
#>  9 10^(-1.236 + 2.635 * (log10(dbh))) 406.  1007.  
#> 10 <NA>                                NA     NA   
#> # ... with 5,022 more rows
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
#>  1 liriodendron tulipifera       137505.
#>  2 quercus velutina              113351.
#>  3 quercus alba                   35044.
#>  4 quercus rubra                  30584.
#>  5 carya tomentosa                29325.
#>  6 fraxinus americana             26961.
#>  7 carya glabra                   25936.
#>  8 juglans nigra                  24565.
#>  9 carya ovalis                   17547.
#> 10 carya cordiformis              12683.
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
