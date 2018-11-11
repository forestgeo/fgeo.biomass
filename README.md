
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

### Basics

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
```

### Manipulate equations

You can use popular(tools to manipulate the nested dataframe of
equations. For example:

``` r
filter(equations, eqn_type %in% c("species", "mixed_hardwood"))
#> # A tibble: 2 x 2
#>   eqn_type       data                
#>   <chr>          <list>              
#> 1 species        <tibble [8,930 x 8]>
#> 2 mixed_hardwood <tibble [5,516 x 8]>
# Same
equations %>% slice(c(1, 3))
#> # A tibble: 2 x 2
#>   eqn_type       data                
#>   <chr>          <list>              
#> 1 species        <tibble [8,930 x 8]>
#> 2 mixed_hardwood <tibble [5,516 x 8]>

equations %>% 
  slice(c(1, 3)) %>% 
  unnest()
#> # A tibble: 14,446 x 9
#>    eqn_type rowid site  sp      dbh equation_id eqn   eqn_source eqn_type1
#>    <chr>    <int> <chr> <chr> <dbl> <chr>       <chr> <chr>      <chr>    
#>  1 species      4 scbi  nyss~ 135   8da09d      1.54~ default    species  
#>  2 species     21 scbi  liri~ 232.  34fe5a      1.02~ default    species  
#>  3 species     29 scbi  acer~ 326.  7c72ed      exp(~ default    species  
#>  4 species     38 scbi  frax~  42.8 0edaff      0.16~ default    species  
#>  5 species     72 scbi  acer~ 289.  7c72ed      exp(~ default    species  
#>  6 species     77 scbi  quer~ 636.  07dba7      1.56~ default    species  
#>  7 species     79 scbi  tili~ 475   3f99ba      1.44~ default    species  
#>  8 species     79 scbi  tili~ 475   76d19b      0.00~ default    species  
#>  9 species     84 scbi  frax~ 170.  0edaff      0.16~ default    species  
#> 10 species     89 scbi  fagu~  27.2 74186d      2.03~ default    species  
#> # ... with 14,436 more rows
```

### Prioritize equations

You can prioritize available equations by setting the order in which
equations of different types overwrite each other. Here is a toy example
to show how this works.

  - Toy data.

<!-- end list -->

``` r
toy_equations <- tibble::tribble(
  ~eqn,       ~dbh,  ~eqn_type, ~rowid, ~where,
  "dbh + 1",    10,  "species",      1, "rowid only in species",
  "dbh + 1",    10,  "species",      3, "rowid in both: lhs overwrites rhs",

  "dbh + 2",    10,  "genus",        2, "rowid only in genus",
  "dbh + 2",    10,  "genus",        3, "rowid in both: lhs overwrites rhs",
)
toy_equations
#> # A tibble: 4 x 5
#>   eqn       dbh eqn_type rowid where                            
#>   <chr>   <dbl> <chr>    <dbl> <chr>                            
#> 1 dbh + 1    10 species      1 rowid only in species            
#> 2 dbh + 1    10 species      3 rowid in both: lhs overwrites rhs
#> 3 dbh + 2    10 genus        2 rowid only in genus              
#> 4 dbh + 2    10 genus        3 rowid in both: lhs overwrites rhs

toy_nested <- nest(toy_equations, -eqn_type)
toy_nested
#> # A tibble: 2 x 2
#>   eqn_type data            
#>   <chr>    <list>          
#> 1 species  <tibble [2 x 4]>
#> 2 genus    <tibble [2 x 4]>
```

  - Alternative results.

<!-- end list -->

``` r
species_overwrites_genus <- c("species", "genus")
pick_best_equations(toy_nested, order = species_overwrites_genus)
#> # A tibble: 3 x 5
#>   eqn_type eqn       dbh rowid where                            
#>   <chr>    <chr>   <dbl> <dbl> <chr>                            
#> 1 species  dbh + 1    10     3 rowid in both: lhs overwrites rhs
#> 2 species  dbh + 1    10     1 rowid only in species            
#> 3 genus    dbh + 2    10     2 rowid only in genus

genus_overwrites_species <- c("genus", "species")
pick_best_equations(toy_nested, order = genus_overwrites_species)
#> # A tibble: 3 x 5
#>   eqn_type eqn       dbh rowid where                            
#>   <chr>    <chr>   <dbl> <dbl> <chr>                            
#> 1 genus    dbh + 2    10     3 rowid in both: lhs overwrites rhs
#> 2 genus    dbh + 2    10     2 rowid only in genus              
#> 3 species  dbh + 1    10     1 rowid only in species
```

### Calculate biomass

Calculate biomass by evaluating each allometric equations using its
corresponding `dbh`.

``` r
equations %>% 
  pick_best_equations() %>% 
  evaluate_equations()
#> # A tibble: 30,229 x 10
#>    eqn_type rowid site  sp      dbh equation_id eqn   eqn_source eqn_type1
#>    <chr>    <int> <chr> <chr> <dbl> <chr>       <chr> <chr>      <chr>    
#>  1 family       1 scbi  lind~  27.9 f08fff      exp(~ default    family   
#>  2 family       2 scbi  lind~  23.7 f08fff      exp(~ default    family   
#>  3 family       3 scbi  lind~  22.2 f08fff      exp(~ default    family   
#>  4 family       8 scbi  lind~  51.4 f08fff      exp(~ default    family   
#>  5 family      13 scbi  lind~  15.4 f08fff      exp(~ default    family   
#>  6 family      14 scbi  lind~  14.8 f08fff      exp(~ default    family   
#>  7 family      15 scbi  lind~  15.5 f08fff      exp(~ default    family   
#>  8 family      16 scbi  lind~  17.4 f08fff      exp(~ default    family   
#>  9 family      17 scbi  lind~  68.2 f08fff      exp(~ default    family   
#> 10 family      18 scbi  lind~  19.3 f08fff      exp(~ default    family   
#> # ... with 30,219 more rows, and 1 more variable: biomass <dbl>
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
    species tables; ViewFullTable and ViewTaxonomy tables; or any two
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
