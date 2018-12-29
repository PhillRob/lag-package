#' Time series data of NZ naturalised plants
#'
#' @source Aikio et al. \url{https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1600-0706.2009.17963.x}
#' @format A data frame with columns:
#' \describe{
#'  \item{Island}{String to separate regions. Lag detection is run separatly in the Islands/regions.}
#'  \item{Species}{String to separate species.}
#'  \item{Year}{Year of records.}
#'  \item{COUNT}{Number of species recorded per year. }
#'  \item{CUM_FREQ}{Cumulative frequency: total count of species per year.}
#' }
#' @examples
#' \dontrun{
#'  TimeSeriesNatPlantNZ
#' }
"TimeSeriesPlantNZ"

#' Annual frequency count of NZ naturalised plants
#'
#' @source Aikio et al. \url{https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1600-0706.2009.17963.x}
#' @format A data frame with columns:
#' \describe{
#'  \item{Year}{Year of records.}
#'  \item{No_speciemen}{Number of species recorded per year. }
#' }
#' @examples
#' \dontrun{
#'  AnnualFrequencyNatPlantNZ
#' }
"y"


