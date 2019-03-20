
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
#>  1  10484  10484 90224 1       libe  0901     174.  14.2 15039        1
#>  2  26916  26916 1815~ 1       unk   1803     342.  49.5 35147        1
#>  3  34582     NA 1633~ <NA>    libe  1605     316.  91.4    NA       NA
#>  4  23293  23293 1610~ 1       unk   1614     307. 271.  30736        1
#>  5  11455  11455 92297 1       astr  0923     178  451.  16179        1
#>  6  26248  26248 1803~ 1       libe  1803     359.  50.4 34348        1
#>  7  33806     NA 1530~ <NA>    libe  1502     280.  23.7    NA       NA
#>  8  28657  28657 1922~ 1       quru  1919     367. 380   37228        1
#>  9  28425  28425 1909~ 1       cato  1916     367. 319.  36983        1
#> 10  18743  18743 1324~ 1       qual  1328     245. 541.  25201        1
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
#>  2 unk  
#>  3 libe 
#>  4 unk  
#>  5 astr 
#>  6 libe 
#>  7 libe 
#>  8 quru 
#>  9 cato 
#> 10 qual 
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
#>  2 unidentified unk
#>  3 lindera benzoin 
#>  4 unidentified unk
#>  5 asimina triloba 
#>  6 lindera benzoin 
#>  7 lindera benzoin 
#>  8 quercus rubra   
#>  9 carya tomentosa 
#> 10 quercus alba    
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
#> Assuming `dbh` in [mm] (required to find dbh-specific equations).
#> * Searching equations according to site and species.
#> Warning: Can't find equations matching these species:
#> carya sp, crataegus sp, quercus prinus, quercus sp, ulmus sp, unidentified unk
#> * Refining equations according to dbh.
#> Warning: Can't find equations for 3255 rows (inserting `NA`).

equations
#> # A tibble: 5,036 x 31
#>    rowid treeID stemID tag   StemTag sp    quadrat    gx    gy DBHID
#>    <int>  <int>  <int> <chr> <chr>   <chr> <chr>   <dbl> <dbl> <int>
#>  1     1  10484  10484 90224 1       lind~ 0901     174.  14.2 15039
#>  2     2  26916  26916 1815~ 1       unid~ 1803     342.  49.5 35147
#>  3     3  34582     NA 1633~ <NA>    lind~ 1605     316.  91.4    NA
#>  4     4  23293  23293 1610~ 1       unid~ 1614     307. 271.  30736
#>  5     5  11455  11455 92297 1       asim~ 0923     178  451.  16179
#>  6     6  26248  26248 1803~ 1       lind~ 1803     359.  50.4 34348
#>  7     7  33806     NA 1530~ <NA>    lind~ 1502     280.  23.7    NA
#>  8     8  28657  28657 1922~ 1       quer~ 1919     367. 380   37228
#>  9     9  28425  28425 1909~ 1       cary~ 1916     367. 319.  36983
#> 10    10  18743  18743 1324~ 1       quer~ 1328     245. 541.  25201
#> # ... with 5,026 more rows, and 21 more variables: CensusID <int>,
#> #   dbh <dbl>, pom <chr>, hom <dbl>, ExactDate <chr>, DFstatus <chr>,
#> #   codes <chr>, nostems <dbl>, date <dbl>, status <chr>, agb <dbl>,
#> #   site <chr>, equation_id <chr>, eqn <chr>, eqn_source <chr>,
#> #   eqn_type <chr>, anatomic_relevance <chr>, dbh_unit <chr>,
#> #   bms_unit <chr>, dbh_min_mm <dbl>, dbh_max_mm <dbl>
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
#> Assuming `dbh` unit in [mm].
#> Converting `dbh` based on `dbh_unit`.
#> `biomass` values are given in [kg].
#> Warning: Can't convert all units (inserting 3255 missing values):
#> the 'to' argument is not an acceptable unit.
#> Warning: Can't convert all units (inserting 3255 missing values):
#> the 'from' argument is not an acceptable unit.
#> Warning: Can't evaluate all equations (inserting 23 missing values):
#> object 'dba' not found
#> Warning: `biomass` may be invalid. This is still work in progress.
biomass
#> # A tibble: 5,000 x 2
#>    rowid biomass
#>    <int>   <dbl>
#>  1     1    NA  
#>  2     2    NA  
#>  3     3    NA  
#>  4     4    NA  
#>  5     5    NA  
#>  6     6    NA  
#>  7     7    NA  
#>  8     8    51.5
#>  9     9    NA  
#> 10    10    NA  
#> # ... with 4,990 more rows

with_biomass <- biomass %>% right_join(equations)
#> Joining, by = "rowid"

with_biomass %>% 
  select(eqn, dbh, biomass)
#> # A tibble: 5,036 x 3
#>    eqn                               dbh biomass
#>    <chr>                           <dbl>   <dbl>
#>  1 <NA>                             10.8    NA  
#>  2 <NA>                             64.6    NA  
#>  3 <NA>                             NA      NA  
#>  4 <NA>                            174.     NA  
#>  5 <NA>                             20.8    NA  
#>  6 <NA>                             10.5    NA  
#>  7 <NA>                             NA      NA  
#>  8 exp(4.9967 + 2.3944 * log(dbh)) 115.     51.5
#>  9 <NA>                             48.9    NA  
#> 10 <NA>                            742.     NA  
#> # ... with 5,026 more rows
```

Commonly we would further summarize the result. For that you can use the
**dplyr** package or any general purpose tool. For example, this summary
gives the total biomass for each species in descending order.

``` r
with_biomass %>% 
  group_by(sp) %>% 
  summarize(total_biomass = sum(biomass, na.rm = TRUE)) %>% 
  arrange(desc(total_biomass))
#> # A tibble: 51 x 2
#>    sp                      total_biomass
#>    <chr>                           <dbl>
#>  1 liriodendron tulipifera       156171.
#>  2 quercus velutina               99156.
#>  3 quercus alba                   43186.
#>  4 carya glabra                   29234.
#>  5 carya tomentosa                28363.
#>  6 quercus rubra                  22465.
#>  7 fraxinus americana             20618.
#>  8 juglans nigra                  18932.
#>  9 carya ovalis                   16891.
#> 10 carya cordiformis              14357.
#> # ... with 41 more rows
```

### Providing custom equations

If we have our own equations, we can create an `equations`-like dataset
and use it. `as_eqn()` helps us to create such a dataset: It ensures
that our data has the correct structure.

``` r
# Checks that the structure of your data isn't terriby wrong
# BAD
as_eqn("really bad data")
#> Error in validate_eqn(data): is.data.frame(data) is not TRUE
as_eqn(data.frame(1))
#> Error: Ensure your data set has these variables:
#> equation_id, site, sp, eqn, eqn_type, anatomic_relevance, dbh_unit, bms_unit, dbh_min_mm, dbh_max_mm

# GOOD
custom_equations <- tibble::tibble(
  equation_id = c("000001"),
  site = c("scbi"),
  sp = c("paulownia tomentosa"),
  eqn = c("exp(-2.48 + 2.4835 * log(dbh))"),
  eqn_type = c("mixed_hardwood"),
  anatomic_relevance = c("total aboveground biomass"),
  dbh_unit = "cm",
  bms_unit = "g",
  dbh_min_mm = 0,
  dbh_max_mm = Inf,
)

class(as_eqn(custom_equations))
#> [1] "eqn"        "tbl_df"     "tbl"        "data.frame"
```

We can now use the argument `custom_eqn` to pass our custom equations to
`allo_find()`.

``` r
allo_find(census_species, custom_eqn = as_eqn(custom_equations))
#> Assuming `dbh` in [mm] (required to find dbh-specific equations).
#> * Searching equations according to site and species.
#> Warning: Can't find equations matching these species:
#> acer negundo, acer platanoides, acer rubrum, ailanthus altissima, amelanchier arborea, asimina triloba, carpinus caroliniana, carya cordiformis, carya glabra, carya ovalis, carya sp, carya tomentosa, castanea dentata, celtis occidentalis, cercis canadensis, cornus florida, crataegus sp, diospyros virginiana, elaeagnus umbellata, fagus grandifolia, fraxinus americana, fraxinus nigra, fraxinus pennsylvanica, hamamelis virginiana, ilex verticillata, juglans nigra, lindera benzoin, liriodendron tulipifera, lonicera maackii, nyssa sylvatica, pinus strobus, pinus virginiana, platanus occidentalis, prunus avium, prunus serotina, quercus alba, quercus prinus, quercus rubra, quercus sp, quercus velutina, robinia pseudoacacia, rosa multiflora, rubus phoenicolasius, sambucus canadensis, sassafras albidum, tilia americana, ulmus americana, ulmus rubra, ulmus sp, unidentified unk, viburnum prunifolium
#> * Refining equations according to dbh.
#> Warning: Can't find equations for 5000 rows (inserting `NA`).
#> # A tibble: 5,000 x 31
#>    rowid treeID stemID tag   StemTag sp    quadrat    gx    gy DBHID
#>    <int>  <int>  <int> <chr> <chr>   <chr> <chr>   <dbl> <dbl> <int>
#>  1     1  10484  10484 90224 1       lind~ 0901     174.  14.2 15039
#>  2     2  26916  26916 1815~ 1       unid~ 1803     342.  49.5 35147
#>  3     3  34582     NA 1633~ <NA>    lind~ 1605     316.  91.4    NA
#>  4     4  23293  23293 1610~ 1       unid~ 1614     307. 271.  30736
#>  5     5  11455  11455 92297 1       asim~ 0923     178  451.  16179
#>  6     6  26248  26248 1803~ 1       lind~ 1803     359.  50.4 34348
#>  7     7  33806     NA 1530~ <NA>    lind~ 1502     280.  23.7    NA
#>  8     8  28657  28657 1922~ 1       quer~ 1919     367. 380   37228
#>  9     9  28425  28425 1909~ 1       cary~ 1916     367. 319.  36983
#> 10    10  18743  18743 1324~ 1       quer~ 1328     245. 541.  25201
#> # ... with 4,990 more rows, and 21 more variables: CensusID <int>,
#> #   dbh <dbl>, pom <chr>, hom <dbl>, ExactDate <chr>, DFstatus <chr>,
#> #   codes <chr>, nostems <dbl>, date <dbl>, status <chr>, agb <dbl>,
#> #   site <chr>, equation_id <chr>, eqn <chr>, eqn_source <chr>,
#> #   eqn_type <chr>, anatomic_relevance <chr>, dbh_unit <chr>,
#> #   bms_unit <chr>, dbh_min_mm <chr>, dbh_max_mm <chr>
```

This is what the entire workflow looks like:

``` r
census_species %>%
  allo_find(custom_eqn = as_eqn(custom_equations)) %>%
  allo_evaluate()
#> Assuming `dbh` in [mm] (required to find dbh-specific equations).
#> Assuming `dbh` unit in [mm].
#> Converting `dbh` based on `dbh_unit`.
#> `biomass` values are given in [kg].
#> Warning: Can't convert all units (inserting 5000 missing values):
#> the 'to' argument is not an acceptable unit.
#> Warning: Can't convert all units (inserting 5000 missing values):
#> the 'from' argument is not an acceptable unit.
#> Warning: `biomass` may be invalid. This is still work in progress.
#> # A tibble: 5,000 x 2
#>    rowid biomass
#>    <int>   <dbl>
#>  1     1      NA
#>  2     2      NA
#>  3     3      NA
#>  4     4      NA
#>  5     5      NA
#>  6     6      NA
#>  7     7      NA
#>  8     8      NA
#>  9     9      NA
#> 10    10      NA
#> # ... with 4,990 more rows
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
