
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
#> `sp` now stores Latin species names

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
#> Warning: Dropping 58 equations that can't be evaluated.
#> Identify failing equations with `fgeo.biomass::failing_eqn_id`
#> Joining, by = c("sp", "site")
#> Warning:   The input and output datasets have different number of rows:
#>   * Input: 40283.
#>   * Output: 30229.

equations
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

If you need more information about each equation, `allo_lookup()` helps
you to look it up in **allodb**.

``` r
equations %>% 
  allo_lookup(allodb::master())
#> Joining, by = "equation_id"
#> # A tibble: 1,127,698 x 44
#>    rowid equation_id ref_id equation_allome~ equation_form dependent_varia~
#>    <int> <chr>       <chr>  <chr>            <chr>         <chr>           
#>  1     4 8da09d      jenki~ 1.5416*(dbh^2)^~ a*(DBH^2)^b   Stem and branch~
#>  2    21 34fe5a      jenki~ 1.0259*(dbh^2.7~ a*(DBH^b)     Stem and branch~
#>  3    29 7c72ed      jenki~ exp(4.5893+2.43~ exp(a+b*ln(D~ Total abovegrou~
#>  4    29 7c72ed      jenki~ exp(4.5893+2.43~ exp(a+b*ln(D~ Total abovegrou~
#>  5    29 7c72ed      jenki~ exp(4.5893+2.43~ exp(a+b*ln(D~ Total abovegrou~
#>  6    29 7c72ed      jenki~ exp(4.5893+2.43~ exp(a+b*ln(D~ Total abovegrou~
#>  7    38 0edaff      ter-m~ 0.1634*(dbh^2.3~ a*(DBH^b)     Total abovegrou~
#>  8    38 0edaff      ter-m~ 0.1634*(dbh^2.3~ a*(DBH^b)     Total abovegrou~
#>  9    38 0edaff      ter-m~ 0.1634*(dbh^2.3~ a*(DBH^b)     Total abovegrou~
#> 10    38 0edaff      ter-m~ 0.1634*(dbh^2.3~ a*(DBH^b)     Total abovegrou~
#> # ... with 1,127,688 more rows, and 38 more variables:
#> #   independent_variable <chr>, allometry_specificity <chr>,
#> #   geographic_area <chr>, dbh_min_cm <chr>, dbh_max_cm <chr>,
#> #   sample_size <chr>, dbh_units_original <chr>,
#> #   biomass_units_original <chr>, allometry_development_method <chr>,
#> #   regression_model <chr>, other_equations_tested <chr>,
#> #   log_biomass <chr>, bias_corrected <chr>, bias_correction_factor <chr>,
#> #   notes_fitting_model <chr>, original_data_availability <chr>,
#> #   warning <chr>, site <chr>, family <chr>, species <chr>,
#> #   species_code <chr>, life_form <chr>, equation_group <chr>,
#> #   equation_taxa <chr>, notes_on_species <chr>, wsg_id <chr>,
#> #   wsg_specificity <chr>, id <chr>, Site <chr>, lat <chr>, long <chr>,
#> #   UTM_Zone <chr>, UTM_X <chr>, UTM_Y <chr>, intertropical <chr>,
#> #   size.ha <chr>, E <chr>, wsg.site.name <chr>
```

### Calculating biomass

For the rows for which an equation was found in **allodb**, we can now
calculate biomass. `allo_evaluate()` evaluates each allometric equation
by replacing the literal string “dbh” with the corresponding value for
each row in the `dbh` column, then doing the actual computation and
storing the result in the the new `biomass` column.

``` r
with_biomass <- equations %>% 
  allo_evaluate()
#> Assuming `dbh` units in [cm] (to convert units see `?measurements::conv_unit()`).
#> Warning: `biomass` values may be invalid.
#> This is work in progress and we still don't handle units correctly.

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
#> Joining, by = c("sp", "site")
#> Warning:   The input and output datasets have different number of rows:
#>   * Input: 40283.
#>   * Output: 3.
#> # A tibble: 3 x 9
#>   eqn_type rowid site  sp      dbh equation_id eqn   eqn_source
#>   <chr>    <int> <chr> <chr> <dbl> <chr>       <chr> <chr>     
#> 1 mixed_h~  9645 scbi  paul~  462. 000001      exp(~ custom    
#> 2 mixed_h~ 10838 scbi  paul~  363. 000001      exp(~ custom    
#> 3 mixed_h~ 10842 scbi  paul~  531. 000001      exp(~ custom    
#> # ... with 1 more variable: anatomic_relevance <chr>
```

This is what the entire workflow looks like:

``` r
census_species %>%
  allo_find(custom_eqn = as_eqn(custom_equations)) %>%
  allo_evaluate()
#> Joining, by = c("sp", "site")
#> Warning:   The input and output datasets have different number of rows:
#>   * Input: 40283.
#>   * Output: 3.
#> Assuming `dbh` units in [cm] (to convert units see `?measurements::conv_unit()`).
#> Warning: `biomass` values may be invalid.
#> This is work in progress and we still don't handle units correctly.
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
