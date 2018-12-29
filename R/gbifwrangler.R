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
#'
#' @examples
#' \dontrun{
#'  gbifwrangler(x)
#' }
#'
#'

gbifwrangler <- function(x, year=2017, minocc = 15, noyears=5){

  # filter data
  x <- x[!is.na(x$year),] # remove all records without time stamp

  if (year <= 2018) and (year >= 0){
    x <- x[(USA.occ.df.y.ll$year<year),]
  else
    stop("year value is not between 0 and 2018")
  }

  if (minnocc >= 1){
    x <- subset(x, with(x, unsplit(table(species), species)) >= minocc)
  else
    stop("minoc must be larger or equal to 1")
  }
  if (noyear >0){
    x.noyear <- by(x, x$species, function(x) (nrow(count(x[,c("year")])) < noyear) == T)
    x.noyear <- ldply(x.noyear, data.frame)
    x.noyear <- x.noyear[(x.noyear$X..i.. == TRUE),1]
    x <- x[!(x$species %in% x.noyear),]
    else
      continue
  }

# remove species with less than 5 occurence years
sp.5 <-
  by(USA.occ.df.y.ll.12.15, USA.occ.df.y.ll.12.15$species, function(x)
    (nrow(count(x[,c("year")])) < 7) == T)
sp.5.df <- ldply(sp.5, data.frame)
sp.5.df.1 <- sp.5.df[(sp.5.df$X..i.. == TRUE),1]
USA.occ.df.y.ll.12.15.5 <-
  USA.occ.df.y.ll.12.15[!(USA.occ.df.y.ll.12.15$species %in% sp.5.df.1),]

nrow(USA.occ.df.y.ll.12.15.5)
USA.l <- USA.occ.df.y.ll.12.15.5[c("species", "year")]

# freq
f_y_sp <- as.data.frame(table(USA.l$species, USA.l$year))
colnames(f_y_sp) <- c("species", "year")
df_n1 <- merge(USA.l, f_y_sp, by = c("species", "year"))
df_n2 <- unique(df_n1[, 1:3])
colnames(df_n2) <- c("Species", "Year", "Fre")
f_s_cum_n <- aggregate(Fre ~ Species, df_n2, function(x) cumsum(x))
df_n3 <- cbind(df_n2, as.vector(unlist(f_s_cum_n[2])))
colnames(df_n3) <- c("Species", "Year","Fre", "Cum")
#unique(IR.ALL.df$speciesKey)
f_y <- aggregate(Fre ~ Year, df_n3, function(x) sum(x))
df4 <- merge(df_n3, f_y, by = "Year")
df5 <- df4[order(df4$Species, df4$Year), ]


# prepare for lag
df5$Island<-"North"
df5 <- df5[c(6,2,1,3,4,5)]
colnames(df5) <- c("Island","Species","Year", "COUNT", "CUM_FREQ", "No_specimen_year")
df5 <- df5[order(df5$Island, df5$Species, df5$Year), ]

f <- as.data.frame(seq.int(from = (f_y[1, 1]), to = (f_y[as.numeric(length(f_y$Fre)),
                                                         1])))
colnames(f)[1] <- "Year"
f1 <- merge(f_y, f, all = TRUE, by = "Year")
f1$Fre[is.na(f1$Fre)] <- 0
colnames(f1) <- c("Year", "No_speciemen")
#table(table(df5$Species)<5)
}
