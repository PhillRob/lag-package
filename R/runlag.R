#' Time lag detection in occurence data
#'
#' @param x data.frame with cumulative record counts per year
#' @param y data.frame with occurence records per species and year
#'
#' @return results data.frame with lag assessment results
#' @export runlag
#'
#' @examples
#' \dontrun{
#'  runlag(x,y)
#' }
runlag <- function(x,y)
{
    # # Now apply to all species and record the end of lag phase # Note
    # that the frequency may *decrease* after the lag phase # So also track
    # which species increase
    z <- sort(unique(paste(x$Species)))
    species <- substring(z, 15, 120)
    nspecies <- length(z)
    endlagphase <- increase <- lengthlag <- firstyear <- rep(NA, nspecies)
    endlagphase0 <- increase0 <- lengthlag0 <- firstyear0 <- rep(NA, nspecies)

    for (i in 1:nspecies) {

        subdata <- get.species(x, y, species[i], zeros = TRUE)
        fit0 <- lagphase(subdata)
        subdata <- get.species(x, y, species[i], zeros = FALSE)
        fit <- lagphase(subdata)

        if (length(fit$knots) > 0) {
            endlagphase[i] <- fit$knots[1]
            increase[i] <- (fit$coef[2] > 0)
            firstyear[i] <- fit$data$year[1]
            lengthlag[i] <- fit$knots[1] - fit$data$year[1]
        }
        if (length(fit0$knots) > 0) {
            endlagphase0[i] <- fit0$knots[1]
            increase0[i] <- (fit0$coef[2] > 0)
            firstyear0[i] <- fit0$data$year[1]
            lengthlag0[i] <- fit0$knots[1] - fit0$data$year[1]
        }
    }

    results <- as.data.frame(cbind(species, firstyear, increase0, lengthlag0, endlagphase0,
                                 increase, endlagphase, lengthlag))
    return(results)
}
