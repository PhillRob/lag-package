---
title: "Lag phase detection package"
output:
  html_document: default
  pdf_document: default
  word_document: default
bibliography: bibliography.bib
csl: apa-5th.csl
---



This package fits glms over species time series to detect time lag in species population growth. The code is based on @Hyndman2015-rt and the code published on [www.robjhyndman.com](https://robjhyndman.com/Rfiles/lagphase.R).




## Installation
You can install the lag detection package from github with:

``` r
# install.packages("devtools")
devtools::install_github("PhillRob/lag-package")
library(lag-package)
```

## Example
This is a basic example which shows you how to solve a common problem:

``` r
lagTest <- runlag(x = TimeSeriesNatPlantNZ,y = AnnualFrequencyNatPlantNZ)
```


## Data
Invasive species time series from NZ is included as test data is included from @Aikio2010-fv. 
```r
load("data/AnnualFrequencyNatPlantNZ.rda")
load("data/TimeSeriesNatPlantNZ.rda")
```
You can use `gbifwranger.R` to wrap [GBIF](https://www.gbif.org/) data downloaded using the [rgbif package](https://cran.r-project.org/web/packages/rgbif/rgbif.pdf) [@Scott_Chamberlain_Vijay_Barve_Dan_Mcglinn_Damiano_Oldoni_Laurens_Geffert_Karthik_Ram2018-zi] into the format required by the lag code. 



# References
