
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
#> 1 species        <tibble [8,930 x 7]> 
#> 2 genus          <tibble [5,642 x 7]> 
#> 3 mixed_hardwood <tibble [5,516 x 7]> 
#> 4 family         <tibble [10,141 x 7]>
#> 5 woody_species  <tibble [0 x 7]>
```

### Manipulate equations

You can use popular(tools to manipulate the nested dataframe of
equations. For example:

``` r
filter(equations, eqn_type %in% c("species", "mixed_hardwood"))
#> # A tibble: 2 x 2
#>   eqn_type       data                
#>   <chr>          <list>              
#> 1 species        <tibble [8,930 x 7]>
#> 2 mixed_hardwood <tibble [5,516 x 7]>
# Same
equations %>% slice(c(1, 3))
#> # A tibble: 2 x 2
#>   eqn_type       data                
#>   <chr>          <list>              
#> 1 species        <tibble [8,930 x 7]>
#> 2 mixed_hardwood <tibble [5,516 x 7]>

equations %>% 
  slice(c(1, 3)) %>% 
  unnest()
#> # A tibble: 14,446 x 8
#>    eqn_type rowid site  sp           dbh equation_id eqn        eqn_source
#>    <chr>    <int> <chr> <chr>      <dbl> <chr>       <chr>      <chr>     
#>  1 species      4 scbi  nyssa syl~ 135   8da09d      1.5416 * ~ default   
#>  2 species     21 scbi  liriodend~ 232.  34fe5a      1.0259 * ~ default   
#>  3 species     29 scbi  acer rubr~ 326.  7c72ed      exp(4.589~ default   
#>  4 species     38 scbi  fraxinus ~  42.8 0edaff      0.1634 * ~ default   
#>  5 species     72 scbi  acer rubr~ 289.  7c72ed      exp(4.589~ default   
#>  6 species     77 scbi  quercus a~ 636.  07dba7      1.5647 * ~ default   
#>  7 species     79 scbi  tilia ame~ 475   3f99ba      1.4416 * ~ default   
#>  8 species     79 scbi  tilia ame~ 475   76d19b      0.004884 ~ default   
#>  9 species     84 scbi  fraxinus ~ 170.  0edaff      0.1634 * ~ default   
#> 10 species     89 scbi  fagus gra~  27.2 74186d      2.0394 * ~ default   
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

  - Alternative results (compare first rows).

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
best <- pick_best_equations(equations)
evaluate_equations(best)
#> # A tibble: 30,229 x 9
#>    eqn_type rowid site  sp       dbh equation_id eqn    eqn_source biomass
#>    <chr>    <int> <chr> <chr>  <dbl> <chr>       <chr>  <chr>        <dbl>
#>  1 family       1 scbi  linde~  27.9 f08fff      exp(-~ default      337. 
#>  2 family       2 scbi  linde~  23.7 f08fff      exp(-~ default      228. 
#>  3 family       3 scbi  linde~  22.2 f08fff      exp(-~ default      194. 
#>  4 family       8 scbi  linde~  51.4 f08fff      exp(-~ default     1474. 
#>  5 family      13 scbi  linde~  15.4 f08fff      exp(-~ default       80.4
#>  6 family      14 scbi  linde~  14.8 f08fff      exp(-~ default       73.0
#>  7 family      15 scbi  linde~  15.5 f08fff      exp(-~ default       81.7
#>  8 family      16 scbi  linde~  17.4 f08fff      exp(-~ default      108. 
#>  9 family      17 scbi  linde~  68.2 f08fff      exp(-~ default     2917. 
#> 10 family      18 scbi  linde~  19.3 f08fff      exp(-~ default      139. 
#> # ... with 30,219 more rows
```

### Known issues

Right now there may be multiple rows per `rowid`. This is because, for a
single stem, there may be multiple equations to reflect the allometries
of different parts of the stem. **fgeo.biomass** doesn’t deal with this
issue yet but helps you find them.

``` r
find_duplicated_rowid(best)
#> # A tibble: 1,809 x 9
#>    eqn_type rowid site  sp        dbh equation_id eqn     eqn_source     n
#>    <chr>    <int> <chr> <chr>   <dbl> <chr>       <chr>   <chr>      <int>
#>  1 genus      106 scbi  amelan~  13.8 c59e03      exp(7.~ default        3
#>  2 genus      106 scbi  amelan~  13.8 96c0af      10^(2.~ default        3
#>  3 genus      106 scbi  amelan~  13.8 529234      10^(2.~ default        3
#>  4 genus      125 scbi  amelan~  36.1 c59e03      exp(7.~ default        3
#>  5 genus      125 scbi  amelan~  36.1 96c0af      10^(2.~ default        3
#>  6 genus      125 scbi  amelan~  36.1 529234      10^(2.~ default        3
#>  7 genus      131 scbi  amelan~  79.1 c59e03      exp(7.~ default        3
#>  8 genus      131 scbi  amelan~  79.1 96c0af      10^(2.~ default        3
#>  9 genus      131 scbi  amelan~  79.1 529234      10^(2.~ default        3
#> 10 genus      132 scbi  amelan~  24   c59e03      exp(7.~ default        3
#> # ... with 1,799 more rows
```

Here you enter the danger zone. **fgeo.biomass** provides a quick and
dirty way of getting a single equation per stem.

``` r
danger <- pick_one_row_by_rowid(best)
danger
#> # A tibble: 29,203 x 8
#>    eqn_type rowid site  sp         dbh equation_id eqn          eqn_source
#>    <chr>    <int> <chr> <chr>    <dbl> <chr>       <chr>        <chr>     
#>  1 family       1 scbi  lindera~  27.9 f08fff      exp(-2.2118~ default   
#>  2 family       2 scbi  lindera~  23.7 f08fff      exp(-2.2118~ default   
#>  3 family       3 scbi  lindera~  22.2 f08fff      exp(-2.2118~ default   
#>  4 family       8 scbi  lindera~  51.4 f08fff      exp(-2.2118~ default   
#>  5 family      13 scbi  lindera~  15.4 f08fff      exp(-2.2118~ default   
#>  6 family      14 scbi  lindera~  14.8 f08fff      exp(-2.2118~ default   
#>  7 family      15 scbi  lindera~  15.5 f08fff      exp(-2.2118~ default   
#>  8 family      16 scbi  lindera~  17.4 f08fff      exp(-2.2118~ default   
#>  9 family      17 scbi  lindera~  68.2 f08fff      exp(-2.2118~ default   
#> 10 family      18 scbi  lindera~  19.3 f08fff      exp(-2.2118~ default   
#> # ... with 29,193 more rows
```

``` r
# No longer has duplicated rowid
find_duplicated_rowid(danger)
#> # A tibble: 0 x 9
#> # ... with 9 variables: eqn_type <chr>, rowid <int>, site <chr>, sp <chr>,
#> #   dbh <dbl>, equation_id <chr>, eqn <chr>, eqn_source <chr>, n <int>

evaluate_equations(danger)
#> # A tibble: 29,203 x 9
#>    eqn_type rowid site  sp       dbh equation_id eqn    eqn_source biomass
#>    <chr>    <int> <chr> <chr>  <dbl> <chr>       <chr>  <chr>        <dbl>
#>  1 family       1 scbi  linde~  27.9 f08fff      exp(-~ default      337. 
#>  2 family       2 scbi  linde~  23.7 f08fff      exp(-~ default      228. 
#>  3 family       3 scbi  linde~  22.2 f08fff      exp(-~ default      194. 
#>  4 family       8 scbi  linde~  51.4 f08fff      exp(-~ default     1474. 
#>  5 family      13 scbi  linde~  15.4 f08fff      exp(-~ default       80.4
#>  6 family      14 scbi  linde~  14.8 f08fff      exp(-~ default       73.0
#>  7 family      15 scbi  linde~  15.5 f08fff      exp(-~ default       81.7
#>  8 family      16 scbi  linde~  17.4 f08fff      exp(-~ default      108. 
#>  9 family      17 scbi  linde~  68.2 f08fff      exp(-~ default     2917. 
#> 10 family      18 scbi  linde~  19.3 f08fff      exp(-~ default      139. 
#> # ... with 29,193 more rows
```

### Add equations for each row of your census dataset

The `rowid`s were generated from the row-names of your original census
data. Now that you have a single row per `rowid`, you can add the
equations to your census data with `dplyr::left_join()`.

``` r
census_equations <- add_equations(census, danger)
#> Joining, by = "rowid"
census_equations
#> # A tibble: 40,283 x 22
#>    rowid treeID stemID tag   StemTag sp    quadrat    gx    gy DBHID
#>    <int>  <int>  <int> <chr> <chr>   <chr> <chr>   <dbl> <dbl> <int>
#>  1     1      1      1 10079 1       libe  0104     3.70  73       1
#>  2     2      2      2 10168 1       libe  0103    17.3   58.9     3
#>  3     3      3      3 10567 1       libe  0110     9    197.      5
#>  4     4      4      4 12165 1       nysy  0122    14.2  428.      7
#>  5     5      5      5 12190 1       havi  0122     9.40 436.      9
#>  6     6      6      6 12192 1       havi  0122     1.30 434      13
#>  7     7      7      7 12212 1       unk   0123    17.8  447.     15
#>  8     8      8      8 12261 1       libe  0125    18    484.     17
#>  9     9      9      9 12456 1       vipr  0130    18    598.     19
#> 10    10     10     10 12551 1       astr  0132     5.60 628.     22
#> # ... with 40,273 more rows, and 12 more variables: CensusID <int>,
#> #   dbh <dbl>, pom <chr>, hom <dbl>, ExactDate <chr>, DFstatus <chr>,
#> #   codes <chr>, nostems <dbl>, date <dbl>, status <chr>, agb <dbl>,
#> #   eqn <chr>
```

Thus you can now calculate and summarize biomass in the context of your
census data.

``` r
with_biomass <- census_equations %>% 
  evaluate_equations()

with_biomass %>% 
  group_by(sp) %>% 
  summarize(total_biomass = sum(biomass, na.rm = TRUE)) %>% 
  arrange(desc(total_biomass))
#> # A tibble: 73 x 2
#>    sp    total_biomass
#>    <chr>         <dbl>
#>  1 ploc        2.24e17
#>  2 nysy        5.07e16
#>  3 litu        4.63e10
#>  4 acru        1.31e10
#>  5 qual        1.26e10
#>  6 qufa        9.18e 9
#>  7 saal        6.37e 9
#>  8 quve        5.50e 9
#>  9 quru        4.64e 9
#> 10 fram        2.80e 9
#> # ... with 63 more rows
```

### Possible improvements

``` r
census_species <- add_species(census, species)  # instead of census_species()

# Single interface to automatically calculates biomass
auto_biomass(census_species)

# Single interface to automatically add equations to a census dataframe
auto_equations(census_species)  # Instead of add_equations()

# Functions for greater control over each step of the process.
census_species %>% 
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
