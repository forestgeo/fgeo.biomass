
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
redirect our effort. The resulting biomass is still meaningless.

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
(SCBI).

``` r
census <- fgeo.biomass::scbi_tree1
census
#> # A tibble: 40,283 x 20
#>    treeID stemID tag   StemTag sp    quadrat    gx    gy DBHID CensusID
#>     <int>  <int> <chr> <chr>   <chr> <chr>   <dbl> <dbl> <int>    <int>
#>  1      1      1 10079 1       libe  0104     3.70  73       1        1
#>  2      2      2 10168 1       libe  0103    17.3   58.9     3        1
#>  3      3      3 10567 1       libe  0110     9    197.      5        1
#>  4      4      4 12165 1       nysy  0122    14.2  428.      7        1
#>  5      5      5 12190 1       havi  0122     9.40 436.      9        1
#>  6      6      6 12192 1       havi  0122     1.30 434      13        1
#>  7      7      7 12212 1       unk   0123    17.8  447.     15        1
#>  8      8      8 12261 1       libe  0125    18    484.     17        1
#>  9      9      9 12456 1       vipr  0130    18    598.     19        1
#> 10     10     10 12551 1       astr  0132     5.60 628.     22        1
#> # ... with 40,273 more rows, and 10 more variables: dbh <dbl>, pom <chr>,
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
#> # A tibble: 40,283 x 1
#>    sp   
#>    <chr>
#>  1 libe 
#>  2 libe 
#>  3 libe 
#>  4 nysy 
#>  5 havi 
#>  6 havi 
#>  7 unk  
#>  8 libe 
#>  9 vipr 
#> 10 astr 
#> # ... with 40,273 more rows
```

The species’ Latin names are recorded in *species* tables.

``` r
species <- fgeo.biomass::scbi_species
species %>% 
  select(matches(sp_or_latin), everything())
#> # A tibble: 73 x 10
#>    sp    Latin Genus Species Family SpeciesID Authority IDLevel syn   subsp
#>    <chr> <chr> <chr> <chr>   <chr>      <int> <chr>     <chr>   <lgl> <lgl>
#>  1 acne  Acer~ Acer  negundo Sapin~         1 ""        species NA    NA   
#>  2 acpl  Acer~ Acer  platan~ Sapin~         2 ""        species NA    NA   
#>  3 acru  Acer~ Acer  rubrum  Sapin~         3 ""        species NA    NA   
#>  4 acsp  Acer~ Acer  sp      Sapin~         4 ""        Multip~ NA    NA   
#>  5 aial  Aila~ Aila~ altiss~ Simar~         5 ""        species NA    NA   
#>  6 amar  Amel~ Amel~ arborea Rosac~         6 ""        species NA    NA   
#>  7 astr  Asim~ Asim~ triloba Annon~         7 ""        species NA    NA   
#>  8 beth  Berb~ Berb~ thunbe~ Berbe~         8 ""        species NA    NA   
#>  9 caca  Carp~ Carp~ caroli~ Betul~         9 ""        species NA    NA   
#> 10 caco  Cary~ Carya cordif~ Jugla~        10 ""        species NA    NA   
#> # ... with 63 more rows
```

We can then add species’ Latin names to the census data by joining the
*census* and *species* tables. We may do that with `dplyr::left_join()`
but `fgeo.biomass::add_species()` is more specialized.

``` r
census_species <- census %>%
  add_species(species, "scbi")
#> Storing Latin species names into `sp`.

census_species %>% 
  select(matches(sp_or_latin))
#> # A tibble: 40,283 x 1
#>    sp                  
#>  * <chr>               
#>  1 lindera benzoin     
#>  2 lindera benzoin     
#>  3 lindera benzoin     
#>  4 nyssa sylvatica     
#>  5 hamamelis virginiana
#>  6 hamamelis virginiana
#>  7 unidentified unk    
#>  8 lindera benzoin     
#>  9 viburnum prunifolium
#> 10 asimina triloba     
#> # ... with 40,273 more rows
```

### Finding the best available allometric-equations

We have just added the Latin name of each species to the census data
into the `sp` column. Now we can try to find the best available
allometric-equations for as many rows as possible with `allo_find()`.

``` r
equations <- census_species %>% 
  allo_find()

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

The output is a nested tibble (dataframe), which we can unnest it with
`tidyr::unnest()`.

``` r
unnest(equations)
#> # A tibble: 30,229 x 9
#>    eqn_type rowid site  sp      dbh equation_id eqn   eqn_source
#>    <chr>    <int> <chr> <chr> <dbl> <chr>       <chr> <chr>     
#>  1 species      4 scbi  nyss~ 135   8da09d      1.54~ default   
#>  2 species     21 scbi  liri~ 232.  34fe5a      1.02~ default   
#>  3 species     29 scbi  acer~ 326.  7c72ed      exp(~ default   
#>  4 species     38 scbi  frax~  42.8 0edaff      0.16~ default   
#>  5 species     72 scbi  acer~ 289.  7c72ed      exp(~ default   
#>  6 species     77 scbi  quer~ 636.  07dba7      1.56~ default   
#>  7 species     79 scbi  tili~ 475   3f99ba      1.44~ default   
#>  8 species     79 scbi  tili~ 475   76d19b      0.00~ default   
#>  9 species     84 scbi  frax~ 170.  0edaff      0.16~ default   
#> 10 species     89 scbi  fagu~  27.2 74186d      2.03~ default   
#> # ... with 30,219 more rows, and 1 more variable: anatomic_relevance <chr>
```

We may not have allometric equations form all species. Although the code
will eventually fall back to more general equations, for now we just
drop the rows that don’t match the available species for the specified
site.

``` r
nrow(census_species)
#> [1] 40283

# Less rows. We lack equations for some all of the species censused in SCBI
nrow(unnest(equations))
#> [1] 30229
```

If you need more information about each equation, `allo_lookup()` helps
you to look it up in **allodb**.

``` r
equations %>% 
  unnest() %>% 
  allo_lookup(allodb::master()) %>% 
  glimpse()
#> Joining, by = "equation_id"
#> Observations: 1,127,698
#> Variables: 44
#> $ rowid                                <int> 4, 21, 29, 29, 29, 29, 38...
#> $ equation_id                          <chr> "8da09d", "34fe5a", "7c72...
#> $ ref_id                               <chr> "jenkins_2004_cdod", "jen...
#> $ equation_allometry                   <chr> "1.5416*(dbh^2)^2.7818", ...
#> $ equation_form                        <chr> "a*(DBH^2)^b", "a*(DBH^b)...
#> $ dependent_variable_biomass_component <chr> "Stem and branches (live)...
#> $ independent_variable                 <chr> "DBH", "DBH", "DBH", "DBH...
#> $ allometry_specificity                <chr> "Species", "Species", "Sp...
#> $ geographic_area                      <chr> "North Carolina, USA", "W...
#> $ dbh_min_cm                           <chr> "14.48", "5.08", "1", "1"...
#> $ dbh_max_cm                           <chr> "25.4", "50.8", "55", "55...
#> $ sample_size                          <chr> NA, NA, NA, NA, NA, NA, N...
#> $ dbh_units_original                   <chr> "in", "in", "cm", "cm", "...
#> $ biomass_units_original               <chr> "lb", "lb", "g", "g", "g"...
#> $ allometry_development_method         <chr> "harvest", "harvest", "ha...
#> $ regression_model                     <chr> NA, NA, NA, NA, NA, NA, N...
#> $ other_equations_tested               <chr> NA, NA, NA, NA, NA, NA, N...
#> $ log_biomass                          <chr> NA, NA, NA, NA, NA, NA, N...
#> $ bias_corrected                       <chr> "1", "0", "0", "0", "0", ...
#> $ bias_correction_factor               <chr> "included in model", NA, ...
#> $ notes_fitting_model                  <chr> NA, NA, NA, NA, NA, NA, N...
#> $ original_data_availability           <chr> NA, NA, NA, NA, NA, NA, N...
#> $ warning                              <chr> NA, NA, NA, NA, NA, NA, N...
#> $ site                                 <chr> "SCBI", "SCBI", "SCBI", "...
#> $ family                               <chr> "Nyssaceae", "Magnoliacea...
#> $ species                              <chr> "Nyssa sylvatica", "Lirio...
#> $ species_code                         <chr> "nysy", "litu", "acru", "...
#> $ life_form                            <chr> "Tree", "Tree", "Tree", "...
#> $ equation_group                       <chr> "E", "E", "E", "E", "E", ...
#> $ equation_taxa                        <chr> "Nyssa sylvatica", "Lirio...
#> $ notes_on_species                     <chr> NA, NA, NA, NA, NA, NA, N...
#> $ wsg_id                               <chr> NA, NA, NA, NA, NA, NA, N...
#> $ wsg_specificity                      <chr> NA, NA, NA, NA, NA, NA, N...
#> $ id                                   <chr> NA, NA, NA, NA, NA, NA, N...
#> $ Site                                 <chr> NA, NA, NA, NA, NA, NA, N...
#> $ lat                                  <chr> NA, NA, NA, NA, NA, NA, N...
#> $ long                                 <chr> NA, NA, NA, NA, NA, NA, N...
#> $ UTM_Zone                             <chr> NA, NA, NA, NA, NA, NA, N...
#> $ UTM_X                                <chr> NA, NA, NA, NA, NA, NA, N...
#> $ UTM_Y                                <chr> NA, NA, NA, NA, NA, NA, N...
#> $ intertropical                        <chr> NA, NA, NA, NA, NA, NA, N...
#> $ size.ha                              <chr> NA, NA, NA, NA, NA, NA, N...
#> $ E                                    <chr> NA, NA, NA, NA, NA, NA, N...
#> $ wsg.site.name                        <chr> NA, NA, NA, NA, NA, NA, N...
```

### Calculating biomass

For the rows for which an equation was found in **allodb**, we can now
calculate biomass. `allo_evaluate()` evaluates each allometric equation
by replacing the literal string “dbh” with the corresponding value for
each row in the `dbh` column, then doing the actual computation and
storing the result in the the new `biomass` column.

``` r
with_biomass <- equations %>% 
  unnest() %>% 
  allo_evaluate()

with_biomass %>% 
  select(eqn, dbh, biomass)
#> # A tibble: 30,229 x 3
#>    eqn                             dbh biomass
#>    <chr>                         <dbl>   <dbl>
#>  1 1.5416 * (dbh^2)^2.7818       135   1.10e12
#>  2 1.0259 * (dbh^2.7324)         232.  2.99e 6
#>  3 exp(4.5893 + 2.43 * log(dbh)) 326.  1.26e 8
#>  4 0.1634 * (dbh^2.348)           42.8 1.11e 3
#>  5 exp(4.5893 + 2.43 * log(dbh)) 289.  9.38e 7
#>  6 1.5647 * (dbh^2.6887)         636.  5.41e 7
#>  7 1.4416 * (dbh^2.7324)         475   2.97e 7
#>  8 0.004884 * (dbh^2.094)        475   1.97e 3
#>  9 0.1634 * (dbh^2.348)          170.  2.81e 4
#> 10 2.0394 * (dbh^2.5715)          27.2 9.97e 3
#> # ... with 30,219 more rows
```

Commonly we would further summarize the result. For that you can use the
**dplyr** package or any general purpose tool. For example, this summary
gives the total biomass for each species in descending order.

``` r
with_biomass %>% 
  group_by(sp) %>% 
  summarize(total_biomass = sum(biomass, na.rm = TRUE)) %>% 
  arrange(desc(total_biomass))
#> # A tibble: 52 x 2
#>    sp                      total_biomass
#>    <chr>                           <dbl>
#>  1 platanus occidentalis         2.24e17
#>  2 nyssa sylvatica               5.07e16
#>  3 liriodendron tulipifera       4.63e10
#>  4 acer rubrum                   1.31e10
#>  5 quercus alba                  1.26e10
#>  6 quercus falcata               9.21e 9
#>  7 quercus velutina              7.47e 9
#>  8 sassafras albidum             6.37e 9
#>  9 quercus rubra                 4.64e 9
#> 10 fraxinus americana            2.80e 9
#> # ... with 42 more rows
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
#> equation_id, site, sp, eqn, eqn_type, anatomic_relevance

# GOOD
custom_equations <- tibble::tibble(
  equation_id = c("000001"),
  site = c("scbi"),
  sp = c("paulownia tomentosa"),
  eqn = c("exp(-2.48 + 2.4835 * log(dbh))"),
  eqn_type = c("mixed_hardwood"),
  anatomic_relevance = c("total aboveground biomass")
)

class(as_eqn(custom_equations))
#> [1] "eqn"        "tbl_df"     "tbl"        "data.frame"
```

We can now use the argument `custom_eqn` to pass our custom equations to
`allo_find()`.

``` r
allo_find(census_species, custom_eqn = as_eqn(custom_equations))
#> # A tibble: 1 x 2
#>   eqn_type       data            
#>   <chr>          <list>          
#> 1 mixed_hardwood <tibble [3 x 8]>
```

This is what the entire workflow looks like:

``` r
census_species %>%
  allo_find(custom_eqn = as_eqn(custom_equations)) %>%
  unnest() %>%
  allo_evaluate()
#> # A tibble: 3 x 10
#>   eqn_type rowid site  sp      dbh equation_id eqn   eqn_source
#>   <chr>    <int> <chr> <chr> <dbl> <chr>       <chr> <chr>     
#> 1 mixed_h~  9645 scbi  paul~  462. 000001      exp(~ custom    
#> 2 mixed_h~ 10838 scbi  paul~  363. 000001      exp(~ custom    
#> 3 mixed_h~ 10842 scbi  paul~  531. 000001      exp(~ custom    
#> # ... with 2 more variables: anatomic_relevance <chr>, biomass <dbl>
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

  - The output excludes equations that apply to only part of a tree –
    instead of the whole tree
    (e.g. <https://github.com/forestgeo/allodb/issues/63>,
    <https://github.com/forestgeo/fgeo.biomass/issues/9>).

  - We exclude equations from shrubs:
    <https://github.com/forestgeo/allodb/issues/41>

### Enhancements

This section shows pseudo-code: Code that doesn’t actually run but shows
what it would look like if it did work.

  - Add `site` during construction, e.g. `as_species(data, site =
    "scbi")` and drop the `site` argument to `add_species()`.

<!-- end list -->

``` r
census_species <- census %>% 
  add_species(species)
```

  - New single interface to automatically calculates biomass.

<!-- end list -->

``` r
census_species %>% 
  auto_biomass()
```

  - New single interface to automatically add equations to a census
    dataframe.

<!-- end list -->

``` r
census_species %>% 
  auto_equations()
```

  - Helper to replace specific equations.

<!-- end list -->

``` r
census_species %>% 
  allo_find() %>% 
  allo_replace(
    eqn_id = c("abcd", "efgh"),
    eqn = c("2.0394 * (dbh^2.5715)", "2.0394 * (dbh^2.5715)")
  )
```

### fgeo.biomass and allodb

Allometric equations come from the **allodb** package.

``` r
# Internal
fgeo.biomass:::.default_eqn
#> # A tibble: 620 x 7
#>    equation_id site   sp      eqn      eqn_source eqn_type anatomic_releva~
#>  * <chr>       <chr>  <chr>   <chr>    <chr>      <chr>    <chr>           
#>  1 2060ea      lilly~ acer r~ 10^(1.1~ default    species  total abovegrou~
#>  2 2060ea      tyson  acer r~ 10^(1.1~ default    species  total abovegrou~
#>  3 a4d879      lilly~ acer s~ 10^(1.2~ default    species  total abovegrou~
#>  4 a4d879      tyson  acer s~ 10^(1.2~ default    species  total abovegrou~
#>  5 c59e03      lilly~ amelan~ exp(7.2~ default    genus    stem biomass (w~
#>  6 c59e03      scbi   amelan~ exp(7.2~ default    genus    stem biomass (w~
#>  7 c59e03      serc   amelan~ exp(7.2~ default    genus    stem biomass (w~
#>  8 c59e03      serc   amelan~ exp(7.2~ default    genus    stem biomass (w~
#>  9 c59e03      tyson  amelan~ exp(7.2~ default    genus    stem biomass (w~
#> 10 c59e03      umbc   amelan~ exp(7.2~ default    genus    stem biomass (w~
#> # ... with 610 more rows
```

For now we are excluding some equations.

``` r
# Internal
excluding <- fgeo.biomass:::.bad_eqn_id

allodb::equations %>% 
  filter(equation_id %in% excluding) %>% 
  select(equation_id, equation_allometry)
#> # A tibble: 24 x 2
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
#> # ... with 14 more rows
```

## Information

  - [Getting help](SUPPORT.md).
  - [Contributing](CONTRIBUTING.md).
  - [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
