---
title: "Lag phase detection"
output:
  html_document: default
  pdf_document: default
  word_document: default
bibliography: bibliography.bib
csl: apa-5th.csl
---

This package fits glms over species time series to detect time lag in species population growth. The code is based on @Hyndman2015-rt and has been published on [www.robjhyndman.com](https://robjhyndman.com/Rfiles/lagphase.R).


## Installation
You can install the lag phase detection package from github with:

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
### GBIF wrangler
You can use `gbifwranger.R` to wrap [GBIF](https://www.gbif.org/) data downloaded using the [rgbif package](https://cran.r-project.org/web/packages/rgbif/rgbif.pdf) by @Scott_Chamberlain_Vijay_Barve_Dan_Mcglinn_Damiano_Oldoni_Laurens_Geffert_Karthik_Ram2018-zi into the format required by the lag code. 
``` r
# get gbif occurences
if (!require(rgbif)) install.packages('rgbif')
library(rgbif)

species <- c("Vachellia farnesiana", "Achyranthes aspera"))
gbifkey <- sapply(species, function(x)
        name_backbone(name = x, kingdom = 'plants'),
        USE.NAMES = FALSE)
gbifkey <- as.data.frame(gbifkey)


gbifocc <- occ_search(taxonKey = gbifkey[1,], limit = 200000, country = "US",  return = "data")
gbifocc <- ldply(gbifocc, data.frame)

# format gbif data to format for lag code
lagdata <- gbifwrangler(x = gbifocc)
```


# References
