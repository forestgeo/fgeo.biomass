
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
#>  1  16014  16014 1208~ 1       libe  1205    235.   97.2 21878        1
#>  2  34229     NA 1534~ <NA>    astr  1522    290.  426.     NA       NA
#>  3  38845     NA 33122 <NA>    libe  0301     57.6  14.8    NA       NA
#>  4  29821  29821 2007~ 1       astr  2010    392.  185.  38611        1
#>  5  39455     NA 53167 <NA>    astr  0516     88.7 316.     NA       NA
#>  6  39420     NA 53132 <NA>    qupr  0505     90.5  95.8    NA       NA
#>  7   3995   3995 30361 1       unk   0307     57.7 139.   7095        1
#>  8  23729  23729 1623~ 1       cagl  1623    314.  449.  31219        1
#>  9  10622  10622 90369 1       litu  0905    173.   94.6 15201        1
#> 10  39651     NA 73116 <NA>    libe  0715    127   297.     NA       NA
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
#>  2 astr 
#>  3 libe 
#>  4 astr 
#>  5 astr 
#>  6 qupr 
#>  7 unk  
#>  8 cagl 
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
#>  2 asimina triloba        
#>  3 lindera benzoin        
#>  4 asimina triloba        
#>  5 asimina triloba        
#>  6 quercus prinus         
#>  7 unidentified unk       
#>  8 carya glabra           
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
#> Warning: Can't find equations matching these species (inserting 148 missing values):
#> acer sp, carya sp, crataegus sp, quercus prinus, ulmus sp, unidentified unk
#> Joining, by = sp, site.

equations
#> # A tibble: 5,822 x 29
#>    rowid treeID stemID tag   StemTag sp    quadrat    gx    gy DBHID
#>    <int>  <int>  <int> <chr> <chr>   <chr> <chr>   <dbl> <dbl> <int>
#>  1     1  16014  16014 1208~ 1       lind~ 1205    235.   97.2 21878
#>  2     2  34229     NA 1534~ <NA>    asim~ 1522    290.  426.     NA
#>  3     3  38845     NA 33122 <NA>    lind~ 0301     57.6  14.8    NA
#>  4     4  29821  29821 2007~ 1       asim~ 2010    392.  185.  38611
#>  5     5  39455     NA 53167 <NA>    asim~ 0516     88.7 316.     NA
#>  6     6  39420     NA 53132 <NA>    quer~ 0505     90.5  95.8    NA
#>  7     7   3995   3995 30361 1       unid~ 0307     57.7 139.   7095
#>  8     8  23729  23729 1623~ 1       cary~ 1623    314.  449.  31219
#>  9     9  10622  10622 90369 1       liri~ 0905    173.   94.6 15201
#> 10     9  10622  10622 90369 1       liri~ 0905    173.   94.6 15201
#> # ... with 5,812 more rows, and 19 more variables: CensusID <int>,
#> #   dbh <dbl>, pom <chr>, hom <dbl>, ExactDate <chr>, DFstatus <chr>,
#> #   codes <chr>, nostems <dbl>, date <dbl>, status <chr>, agb <dbl>,
#> #   site <chr>, equation_id <chr>, eqn <chr>, eqn_source <chr>,
#> #   eqn_type <chr>, anatomic_relevance <chr>, dbh_unit <chr>,
#> #   bms_unit <chr>
```

If you need more information about each equation, `allo_lookup()` helps
you to look it up in **allodb**.

``` r
equations %>% 
  allo_lookup(allodb::master())
#> Joining `equations` and `sitespecies` by 'equation_id'; then `sites_info` by 'site'.
#> Joining, by = "equation_id"
#> # A tibble: 245,281 x 44
#>    rowid equation_id ref_id equation_allome~ equation_form dependent_varia~
#>    <int> <chr>       <chr>  <chr>            <chr>         <chr>           
#>  1     1 f08fff      chojn~ exp(-2.2118+2.4~ exp(a+b*log(~ Total abovegrou~
#>  2     1 f08fff      chojn~ exp(-2.2118+2.4~ exp(a+b*log(~ Total abovegrou~
#>  3     1 f08fff      chojn~ exp(-2.2118+2.4~ exp(a+b*log(~ Total abovegrou~
#>  4     1 f08fff      chojn~ exp(-2.2118+2.4~ exp(a+b*log(~ Total abovegrou~
#>  5     1 f08fff      chojn~ exp(-2.2118+2.4~ exp(a+b*log(~ Total abovegrou~
#>  6     1 f08fff      chojn~ exp(-2.2118+2.4~ exp(a+b*log(~ Total abovegrou~
#>  7     1 f08fff      chojn~ exp(-2.2118+2.4~ exp(a+b*log(~ Total abovegrou~
#>  8     1 f08fff      chojn~ exp(-2.2118+2.4~ exp(a+b*log(~ Total abovegrou~
#>  9     1 f08fff      chojn~ exp(-2.2118+2.4~ exp(a+b*log(~ Total abovegrou~
#> 10     1 f08fff      chojn~ exp(-2.2118+2.4~ exp(a+b*log(~ Total abovegrou~
#> # ... with 245,271 more rows, and 38 more variables:
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
biomass <- equations %>% 
  allo_evaluate()
#> Assuming `dbh` unit in [mm].
#> Converting `dbh` based on `dbh_unit`.
#> Warning: Can't convert all units (inserting 148 missing values):
#> the 'to' argument is not an acceptable unit.
#> `biomass` values are given in [kg].
#> Warning: Can't convert all units (inserting 148 missing values):
#> the 'from' argument is not an acceptable unit.
#> Warning: Can't evaluate all equations (inserting 119 missing values):
#> object 'dba' not found
#> Warning: 
#>     `biomass` may be invalid.
#>     We still don't suppor the ability to select dbh-specific equations
#>     (see https://github.com/forestgeo/fgeo.biomass/issues/9).
#> 
biomass
#> # A tibble: 5,000 x 2
#>    rowid  biomass
#>    <int>    <dbl>
#>  1     1    0.273
#>  2     2   NA    
#>  3     3   NA    
#>  4     4    0.684
#>  5     5   NA    
#>  6     6   NA    
#>  7     7   NA    
#>  8     8    1.09 
#>  9     9 6033.   
#> 10    10   NA    
#> # ... with 4,990 more rows

with_biomass <- biomass %>% right_join(equations)
#> Joining, by = "rowid"

with_biomass %>% 
  select(eqn, dbh, biomass)
#> # A tibble: 5,822 x 3
#>    eqn                                     dbh  biomass
#>    <chr>                                 <dbl>    <dbl>
#>  1 exp(-2.2118 + 2.4133 * log(dbh))       14.6    0.273
#>  2 exp(-2.48 + 2.4835 * log(dbh))         NA     NA    
#>  3 exp(-2.2118 + 2.4133 * log(dbh))       NA     NA    
#>  4 exp(-2.48 + 2.4835 * log(dbh))         23.3    0.684
#>  5 exp(-2.48 + 2.4835 * log(dbh))         NA     NA    
#>  6 <NA>                                   NA     NA    
#>  7 <NA>                                   87.3   NA    
#>  8 10^(-1.326 + 2.762 * (log10(dbh)))     31.2    1.09 
#>  9 10^(0.8306 + 2.7308 * (log10(dbh^2))) 123.  6033.   
#> 10 10^(-1.236 + 2.635 * (log10(dbh)))    123.  6033.   
#> # ... with 5,812 more rows
```

Commonly we would further summarize the result. For that you can use the
**dplyr** package or any general purpose tool. For example, this summary
gives the total biomass for each species in descending order.

``` r
with_biomass %>% 
  group_by(sp) %>% 
  summarize(total_biomass = sum(biomass, na.rm = TRUE)) %>% 
  arrange(desc(total_biomass))
#> # A tibble: 54 x 2
#>    sp                      total_biomass
#>    <chr>                           <dbl>
#>  1 liriodendron tulipifera  17128238904.
#>  2 quercus velutina              404277.
#>  3 quercus rubra                  95656.
#>  4 quercus alba                   79730.
#>  5 nyssa sylvatica                72348.
#>  6 fraxinus americana             49579.
#>  7 carya glabra                   46606.
#>  8 tilia americana                29910.
#>  9 carya tomentosa                21039.
#> 10 juglans nigra                  18113.
#> # ... with 44 more rows
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
#> equation_id, site, sp, eqn, eqn_type, anatomic_relevance, dbh_unit, bms_unit

# GOOD
custom_equations <- tibble::tibble(
  equation_id = c("000001"),
  site = c("scbi"),
  sp = c("paulownia tomentosa"),
  eqn = c("exp(-2.48 + 2.4835 * log(dbh))"),
  eqn_type = c("mixed_hardwood"),
  anatomic_relevance = c("total aboveground biomass"),
  dbh_unit = "cm",
  bms_unit = "g"
)

class(as_eqn(custom_equations))
#> [1] "eqn"        "tbl_df"     "tbl"        "data.frame"
```

We can now use the argument `custom_eqn` to pass our custom equations to
`allo_find()`.

``` r
allo_find(census_species, custom_eqn = as_eqn(custom_equations))
#> Warning: Can't find equations matching these species (inserting 5000 missing values):
#> acer negundo, acer platanoides, acer rubrum, acer sp, ailanthus altissima, amelanchier arborea, asimina triloba, berberis thunbergii, carpinus caroliniana, carya cordiformis, carya glabra, carya ovalis, carya sp, carya tomentosa, castanea dentata, celtis occidentalis, cercis canadensis, chionanthus virginicus, cornus florida, corylus americana, crataegus sp, elaeagnus umbellata, fagus grandifolia, fraxinus americana, fraxinus nigra, fraxinus pennsylvanica, hamamelis virginiana, ilex verticillata, juglans cinerea, juglans nigra, lindera benzoin, liriodendron tulipifera, lonicera maackii, nyssa sylvatica, pinus strobus, platanus occidentalis, prunus avium, prunus serotina, quercus alba, quercus prinus, quercus rubra, quercus velutina, robinia pseudoacacia, rosa multiflora, rubus allegheniensis, rubus phoenicolasius, sambucus canadensis, sassafras albidum, tilia americana, ulmus americana, ulmus rubra, ulmus sp, unidentified unk, viburnum prunifolium
#> Joining, by = sp, site.
#> # A tibble: 5,000 x 29
#>    rowid treeID stemID tag   StemTag sp    quadrat    gx    gy DBHID
#>    <int>  <int>  <int> <chr> <chr>   <chr> <chr>   <dbl> <dbl> <int>
#>  1     1  16014  16014 1208~ 1       lind~ 1205    235.   97.2 21878
#>  2     2  34229     NA 1534~ <NA>    asim~ 1522    290.  426.     NA
#>  3     3  38845     NA 33122 <NA>    lind~ 0301     57.6  14.8    NA
#>  4     4  29821  29821 2007~ 1       asim~ 2010    392.  185.  38611
#>  5     5  39455     NA 53167 <NA>    asim~ 0516     88.7 316.     NA
#>  6     6  39420     NA 53132 <NA>    quer~ 0505     90.5  95.8    NA
#>  7     7   3995   3995 30361 1       unid~ 0307     57.7 139.   7095
#>  8     8  23729  23729 1623~ 1       cary~ 1623    314.  449.  31219
#>  9     9  10622  10622 90369 1       liri~ 0905    173.   94.6 15201
#> 10    10  39651     NA 73116 <NA>    lind~ 0715    127   297.     NA
#> # ... with 4,990 more rows, and 19 more variables: CensusID <int>,
#> #   dbh <dbl>, pom <chr>, hom <dbl>, ExactDate <chr>, DFstatus <chr>,
#> #   codes <chr>, nostems <dbl>, date <dbl>, status <chr>, agb <dbl>,
#> #   site <chr>, equation_id <chr>, eqn <chr>, eqn_source <chr>,
#> #   eqn_type <chr>, anatomic_relevance <chr>, dbh_unit <chr>,
#> #   bms_unit <chr>
```

This is what the entire workflow looks like:

``` r
census_species %>%
  allo_find(custom_eqn = as_eqn(custom_equations)) %>%
  allo_evaluate()
#> Assuming `dbh` unit in [mm].
#> Converting `dbh` based on `dbh_unit`.
#> Warning: Can't convert all units (inserting 5000 missing values):
#> the 'to' argument is not an acceptable unit.
#> `biomass` values are given in [kg].
#> Warning: Can't convert all units (inserting 5000 missing values):
#> the 'from' argument is not an acceptable unit.
#> Warning: 
#>     `biomass` may be invalid.
#>     We still don't suppor the ability to select dbh-specific equations
#>     (see https://github.com/forestgeo/fgeo.biomass/issues/9).
#> 
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
