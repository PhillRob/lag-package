#' Prepare GBIF data for lag test
#'
#' @param x GBIF data.frame obtained using rgibf package
#' @param year cut off year to truncate dataset to cater for the delay between surveys and submission to GBIF. Defaults to 2017.
#' @param minocc minimum occurences per species (defaults to 15)
#' @param noyears number of years with occurences (defauls to 5). Set to 0 if you do not want to set a minumum.
#'
#' @return timeseries data.frame for use as x in lag test
#' @return frequency data.frame for use as y in lag test
#' @export gbifwrangler
#' @examples{
#'  gbifwrangler(GBIFraw, year=2017, minocc = 15, noyears=5)
#' }
#'
#'

gbifwrangler <- function(x, year=2017, minocc = 15, noyears=5){

  #x<-MDG
  # filter data
  x <- x[!is.na(x$year),] # remove all records without time stamp

  if (year <= 2018 & year >= 0) {
      x <- x[(x$year < year),]
    } else {
      stop("year value is not between 0 and 2018")
    }

  if (minocc >= 1) {
    x <- subset(x, with(x, unsplit(table(name), name)) >= minocc)
  } else {
    stop("minocc parameter must be larger or equal to 1")
  }

  if (noyears > 0) {
    x.noyears <-
      by(x, x$name, function(x)
        (nrow(plyr::count(x[, c("year")])) < noyears) == T)
    x.noyears <- plyr::ldply(x.noyears, data.frame)
    x.noyears <- x.noyears[(x.noyears$X..i.. == TRUE), 1]
    x <- x[!(x$name %in% x.noyears),]
  } else {
    stop("noyears parameter is <= 0")
  }

  x <- x[c("name", "year")]

  # time series
  x.freq <- as.data.frame(table(x$name, x$year))
  colnames(x.freq) <- c("name", "year")

  x.freq.1 <- merge(x, x.freq, by = c("name", "year"))
  x.freq.1 <- unique(x.freq.1[, 1:3])
  colnames(x.freq.1) <- c("Species", "Year", "Fre")

  x.freq.2 <-
    aggregate(Fre ~ Species, x.freq.1, function(x)
      cumsum(x))
  x.freq.3 <- cbind(x.freq.1, as.vector(unlist(x.freq.2[2])))

  colnames(x.freq.3) <- c("Species", "Year", "Fre", "Cum")

  x.freq.4 <- aggregate(Fre ~ Year, x.freq.3, function(x)
    sum(x))
  x.freq.5 <- merge(x.freq.3, x.freq.4, by = "Year")
  x.freq.5 <- x.freq.5[order(x.freq.5$Species, x.freq.5$Year),]

  x.freq.5 <- x.freq.5[c(2, 1, 3, 4, 5)]
  colnames(x.freq.5) <-
    c("Species", "Year", "COUNT", "CUM_FREQ", "No_specimen_year")
  timeseries <- x.freq.5[order(x.freq.5$Species, x.freq.5$Year),]

  # annual frequency counts (survey effort)
  x.freq.6 <-
    as.data.frame(seq.int(from = (x.freq.4[1, 1]), to = (x.freq.4[as.numeric(length(x.freq.4$Fre)), 1])))
  colnames(x.freq.6)[1] <- "Year"

  x.freq.7 <- merge(x.freq.4, x.freq.6, all = TRUE, by = "Year")
  x.freq.7$Fre[is.na(x.freq.7$Fre)] <- 0
  colnames(x.freq.7) <- c("Year", "No_speciemen")
  frequency <- x.freq.7

  output=list(timeseries,frequency)
}
