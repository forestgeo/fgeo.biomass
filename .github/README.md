
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

## Installation

Install the development version of **fgeo.biomass**:

    # install.packages("devtools")
    devtools::install_github("forestgeo/fgeo.biomass")

For details on how to install packages from GitHub, see [this
article](https://goo.gl/dQKEeg).

## Example

This is a basic example which shows you how to solve a common problem:

``` r
## TODO: Add example
```

[Get started with
**fgeo**](https://forestgeo.github.io/fgeo/articles/fgeo.html)

## Information

EDIT: Run this chunk then delete it: TODO: Move files to .github/ but
refer to (FILE.md), not (.github/FILE.md)

    usethis::use_template("SUPPORT.md", package = "fgeo.template")
    usethis::use_template("CONTRIBUTING.md", package = "fgeo.template")
    usethis::use_template("CODE_OF_CONDUCT.md", package = "fgeo.template")
    usethis::use_template("ISSUE_TEMPLATE.md", package = "fgeo.template")

  - [Getting help](SUPPORT.md).
  - [Contributing](CONTRIBUTING.md).
  - [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

## Acknowledgments

Thanks to all partners of ForestGEO, for sharing their ideas and code.

## READ AND DELETE THIS SECTION

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date.

You can also embed plots, for example:

![](man/figures/README-pressure-1.png)<!-- -->

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub\!
