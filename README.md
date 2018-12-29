---
title: "Lag phase detection package"
output:
  html_document: default
  pdf_document: default
  word_document: default
bibliography: bibliography.bib
---



This package fits glms over species time series to detect time lag in species population growth. The code is based on @Hyndman2015-rt and the code published on




## Installation
You can install lag detection package from github with:

``` r
# install.packages("devtools")
devtools::install_github("PhillRob/lag-package")
```

## Example
This is a basic example which shows you how to solve a common problem:

``` r
## basic example code
```


## Data
Invasive species time series from NZ is included as test data is included from @Aikio2010-fv. 
```r
load("data/AnnualFrequencyNatPlantNZ.rda")
load("data/TimeSeriesNatPlantNZ.rda")
```
You can use **filename** to wrap **GBIF** data into the format required by the code. 



# References
