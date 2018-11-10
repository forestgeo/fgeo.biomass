
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src="https://i.imgur.com/vTLlhbp.png" align="right" height=88 /> Calculate biomass

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/forestgeo/fgeo.biomass.svg?branch=master)](https://travis-ci.org/forestgeo/fgeo.biomass)
[![Coverage
status](https://coveralls.io/repos/github/forestgeo/fgeo.biomass/badge.svg)](https://coveralls.io/r/forestgeo/fgeo.biomass?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/fgeo.biomass)](https://cran.r-project.org/package=fgeo.biomass)

The goal of **fgeo.biomass** is to calculate biomass using allometric
equations from the **allodb** package.

## Warning

This package is not ready for research. This is work in progress and you
are encouraged to try this package and suggest improvements but you
should not trust the results yet.

## Installation

Install the development version of **fgeo.biomass**:

    # install.packages("devtools")
    devtools::install_github("forestgeo/fgeo.biomass")

For details on how to install packages from GitHub, see [this
article](https://goo.gl/dQKEeg).

## Example

``` r
library(tidyverse)
library(fgeo.biomass)
```

Right now these are the key functions:

``` r
census <- allodb::scbi_tree1
species <- allodb::scbi_species
dbh_species <- census_species(census, species, site = "scbi")
dbh_species
#> # A tibble: 40,283 x 4
#>    rowid site  sp                     dbh
#>  * <int> <chr> <chr>                <dbl>
#>  1     1 scbi  lindera benzoin       27.9
#>  2     2 scbi  lindera benzoin       23.7
#>  3     3 scbi  lindera benzoin       22.2
#>  4     4 scbi  nyssa sylvatica      135  
#>  5     5 scbi  hamamelis virginiana  87  
#>  6     6 scbi  hamamelis virginiana  22.5
#>  7     7 scbi  unidentified unk      42.6
#>  8     8 scbi  lindera benzoin       51.4
#>  9     9 scbi  viburnum prunifolium  38.3
#> 10    10 scbi  asimina triloba       14.5
#> # ... with 40,273 more rows

equations <- get_equations(dbh_species)
equations
#> # A tibble: 5 x 2
#>   eqn_type       data                 
#>   <chr>          <list>               
#> 1 species        <tibble [8,930 x 8]> 
#> 2 genus          <tibble [5,642 x 8]> 
#> 3 mixed_hardwood <tibble [5,516 x 8]> 
#> 4 family         <tibble [10,141 x 8]>
#> 5 woody_species  <tibble [0 x 8]>

best <- pick_best_equations(equations)
best
#> # A tibble: 30,229 x 8
#>    rowid site  sp           dbh equation_id eqn        eqn_source eqn_type
#>    <int> <chr> <chr>      <dbl> <chr>       <chr>      <chr>      <chr>   
#>  1     4 scbi  nyssa syl~ 135   8da09d      1.5416 * ~ default    species 
#>  2    21 scbi  liriodend~ 232.  34fe5a      1.0259 * ~ default    species 
#>  3    29 scbi  acer rubr~ 326.  7c72ed      exp(4.589~ default    species 
#>  4    38 scbi  fraxinus ~  42.8 0edaff      0.1634 * ~ default    species 
#>  5    72 scbi  acer rubr~ 289.  7c72ed      exp(4.589~ default    species 
#>  6    77 scbi  quercus a~ 636.  07dba7      1.5647 * ~ default    species 
#>  7    79 scbi  tilia ame~ 475   3f99ba      1.4416 * ~ default    species 
#>  8    79 scbi  tilia ame~ 475   76d19b      0.004884 ~ default    species 
#>  9    84 scbi  fraxinus ~ 170.  0edaff      0.1634 * ~ default    species 
#> 10    89 scbi  fagus gra~  27.2 74186d      2.0394 * ~ default    species 
#> # ... with 30,219 more rows

biomass <- evaluate_equations(best)
biomass
#> # A tibble: 30,229 x 9
#>    rowid site  sp       dbh equation_id eqn    eqn_source eqn_type biomass
#>    <int> <chr> <chr>  <dbl> <chr>       <chr>  <chr>      <chr>      <dbl>
#>  1     4 scbi  nyssa~ 135   8da09d      1.541~ default    species  1.10e12
#>  2    21 scbi  lirio~ 232.  34fe5a      1.025~ default    species  2.99e 6
#>  3    29 scbi  acer ~ 326.  7c72ed      exp(4~ default    species  1.26e 8
#>  4    38 scbi  fraxi~  42.8 0edaff      0.163~ default    species  1.11e 3
#>  5    72 scbi  acer ~ 289.  7c72ed      exp(4~ default    species  9.38e 7
#>  6    77 scbi  querc~ 636.  07dba7      1.564~ default    species  5.41e 7
#>  7    79 scbi  tilia~ 475   3f99ba      1.441~ default    species  2.97e 7
#>  8    79 scbi  tilia~ 475   76d19b      0.004~ default    species  1.97e 3
#>  9    84 scbi  fraxi~ 170.  0edaff      0.163~ default    species  2.81e 4
#> 10    89 scbi  fagus~  27.2 74186d      2.039~ default    species  9.97e 3
#> # ... with 30,219 more rows
```

### Improvements

But the function names will soon change to something like this:

``` r
census %>%
  add_species(species) %>%  # instead of census_species()
  allo_find() %>%           # instead of get_equations()
  allo_customize() %>%      # new function to insert custom equations
  allo_prioritize()         # instead of pick_best_equations()
  allo_evaluate()           # instead of evaluate_equations()
```

Some other possible improvements:

  - Allow using ViewFullTable and ViewTaxonomy.
  - Allow using any table with the required columns.
  - Simplify interfaces via generic functions that ‘know’ what to do
    with different (S3) classes of ForestGEO data – i.e. census and
    scpecies tables; ViewFullTable and ViewTaxonomy talbles; or any two
    tables of unknown class.

### fgeo.biomass and allodb

Allometric equations come from the **allodb** package.

``` r
# Internal
fgeo.biomass:::.default_eqn
#> # A tibble: 619 x 6
#>    equation_id site     sp           eqn               eqn_source eqn_type
#>  * <chr>       <chr>    <chr>        <chr>             <chr>      <chr>   
#>  1 2060ea      lilly d~ acer rubrum  10^(1.1891 + 1.4~ default    species 
#>  2 2060ea      tyson    acer rubrum  10^(1.1891 + 1.4~ default    species 
#>  3 a4d879      lilly d~ acer saccha~ 10^(1.2315 + 1.6~ default    species 
#>  4 a4d879      tyson    acer saccha~ 10^(1.2315 + 1.6~ default    species 
#>  5 c59e03      lilly d~ amelanchier~ exp(7.217 + 1.51~ default    genus   
#>  6 c59e03      scbi     amelanchier~ exp(7.217 + 1.51~ default    genus   
#>  7 c59e03      serc     amelanchier~ exp(7.217 + 1.51~ default    genus   
#>  8 c59e03      serc     amelanchier~ exp(7.217 + 1.51~ default    genus   
#>  9 c59e03      tyson    amelanchier~ exp(7.217 + 1.51~ default    genus   
#> 10 c59e03      umbc     amelanchier~ exp(7.217 + 1.51~ default    genus   
#> # ... with 609 more rows
```

For now we are excluding some equations.

``` r
# Internal
excluding <- fgeo.biomass:::.bad_eqn_id

allodb::equations %>% 
  filter(equation_id %in% excluding) %>% 
  select(equation_id, equation_allometry)
#> # A tibble: 25 x 2
#>    equation_id equation_allometry         
#>    <chr>       <chr>                      
#>  1 76aa3c      38.111*(dba^2.9)           
#>  2 28dce6      51.996*(dba^2.77)          
#>  3 a1646f      37.637*(dba^2.779)         
#>  4 b61369      43.992*(dba^2.86)          
#>  5 5e2dea      29.615*(dba^3.243)         
#>  6 3cb95a      exp(2.025+3.527*log(dba))  
#>  7 c94845      51.68+0.02*BA              
#>  8 6b3b2a      exp(3.67+2.847*log(dba))   
#>  9 b95baf      exp(3.892+3.122*log(dba))  
#> 10 e8f868      exp(3.6123+2.9944*log(dba))
#> # ... with 15 more rows
```

## Information

  - [Getting help](SUPPORT.md).
  - [Contributing](CONTRIBUTING.md).
  - [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
