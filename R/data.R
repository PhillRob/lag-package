#' Time series data of NZN (north island) naturalised plants
#'
#' @source Aikio et al. \url{https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1600-0706.2009.17963.x}
#' @format A data frame with columns:
#' \describe{
#'  \item{Species}{String to separate species.}
#'  \item{Year}{Year of records.}
#'  \item{COUNT}{Number of species recorded per year. }
#'  \item{CUM_FREQ}{Cumulative frequency: total count of species per year.}
#' }
#' @examples
#' \dontrun{
#'  TimeSeriesNatPlantNZN
#' }
"TimeSeriesNatPlantNZN"

#' Annual frequency count of NZ (north island) naturalised plants
#'
#' @source Aikio et al. \url{https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1600-0706.2009.17963.x}
#' @format A data frame with columns:
#' \describe{
#'  \item{Year}{Year of records.}
#'  \item{No_speciemen}{Number of species recorded per year.}
#' }
#' @examples
#' \dontrun{
#'  AnnualFrequencyNatPlantNZ
#' }
"AnnualFrequencyNatPlantNZ"


#' GBIF raw data obtained via rgbif
#'
#' @source gbif.org \url{https://gbif.org}
#' @format A data frame with columns
#' \describe{
#'  \item{.id}{ID}
#'  \item{name}{name}
#'  \item{key}{key}
#'  \item{basisOfRecord}{basisOfRecord}
#'  \item{year}{year}
#'  \item{month}{month}
#'  \item{day}{day}
#'  \item{issues}{issues}
#'  \item{countryCode}{countryCode}
#'  \item{gbifID}{gbifID}
#'  \item{verbatimLocality}{verbatimLocality}
#'  \item{occurrenceID}{occurrenceID}
#'  \item{coordinateUncertaintyInMeters}{coordinateUncertaintyInMeters}
#'  \item{continent}{continent}
#'  \item{stateProvince}{stateProvince}
#'  \item{coordinatePrecision}{coordinatePrecision}
#' }
#' @examples
#' \dontrun{
#'  GBIFraw
#' }
"GBIFraw"
