#' get species from time series objects
#'
#' @param x data.frame with cumulative record counts per year
#' @param y data.frame with occurence records per species and year
#' @param species #vector of species or other time series objects
#' @param zeros binomimal if to treat missing data as 0. If zeros=TRUE, include zeros in returned data.
#' @return results data.frame with species
#' @export get.species



get.species <- function(x, y, species, zeros=FALSE)
{
  out <- subset(x, x[,1]==species)
  out <- out[,c(2,3,5)]
  colnames(out) <- c("year","frequency","specimens")
  if(zeros)
  {
    yrs <- min(out$year):max(out$year)
    zeros <- as.data.frame(matrix(0,nrow=length(yrs),ncol=3))
    colnames(zeros) <- colnames(out)
    zeros[,"year"] <- yrs
    j <- is.element(zeros[,"year"],out[,"year"])
    zeros[j,"frequency"] <- out[,"frequency"]
    j <- is.element(y[,"Year"],zeros[,"year"])
    zeros[,3] <- y[j,2]
    out <- zeros
  }
  # Either way, frequency is missing if specimens=0
  #out$frequency[out$specimens==0] <- NA
  out <- as.list(out)
  out$species <- species
  # out$island <- island
  return(out)
}

#' Main function fitting glms to detect get end of constant population growth.
#' Give it a set of data where the columns include year, frequency, specimens
#' It will find appropriate knots if not specified. It will choose an appropriate
#' order if not specified. Just don't give it knots but no order
#' If gam=TRUE, it will return a gam model instead.
#'
#' @param data data.frame
#' @param knots the numbr of nots
#' @param order the order of the knots
#' @param gam If gam=TRUE, it will return a gam model instead
#' @return results data.frame with species
#' @export lagphase

lagphase <- function(data, knots=NULL, order=1, gam=FALSE)
{
  # Set zeros to missing if no specimens
  nospec <- data$specimens==0
  data$frequency[nospec] <- NA
  specimens <- data$specimens
  # Fit gam
  if(gam)
  {
    gamfit <- gam(frequency ~ s(year), offset=log(specimens), data=data, family=poisson)
    gamfit$year <- data$year
    gamfit$name <- paste(data$species)
    return(gamfit)
  }

  # Otherwise fit a glm
  # Check if knots==0 meaning no knots to be included
  if(!is.null(knots))
  {
    if(length(knots)==1)
    {
      if(knots==0) # i.e., no knots to be included
      {
        # Fit model with no knots
        fit <- glm(frequency ~ 1, offset=log(specimens), data=data, family=poisson, na.action=na.omit)
        fit$year <- data$year
        if(!is.null(data$island))
          fit$name <- paste(data$island,"island:",data$species)
        else
          fit$name <- deparse(substitute(data))
        fit$data <- data
        return(fit)
      }
    }
  }

  # Otherwise proceed
  # Choose order if not provided
  if(is.null(order))
  {
    if(!is.null(knots))
      stop("Not implemented. If you specify the knots, you need to specify the order.")
    fit1 <- lagphase(data, order=1)
    fit3 <- lagphase(data, order=3)
    bestfit <- fit1
    if(AICc(fit3) < AICc(bestfit))
      bestfit <- fit3
    return(bestfit)
  }
  # Otherwise proceed with specified order
  if(!is.null(knots))
    return(lagphase.knots(knots, data, order))
  # Otherwise order specified but knots unspecified

  # Choose some initial knots
  knots <- quantile(data$year,prob=c(0.2,0.4,0.6,0.8))
  names(knots) <- NULL

  # Fit best 4, 3, 2, 1 and 0 knot models
  fit4 <- optim(knots, tryknots, data=data, order=order)
  fit3 <- optim(knots[2:4], tryknots, data=data, order=order)
  fit2 <- optim(knots[c(2,4)], tryknots, data=data, order=order)
  fit1 <- optim(knots[2], tryknots, data=data, order=order, method="Brent",
                lower=min(data$year), upper=max(data$year))
  fit0 <- glm(frequency ~ 1, offset=log(specimens), family=poisson, data=data, na.action=na.omit)

  # Find best of these models:
  bestfit <- fit4
  if(fit3$value < bestfit$value)
    bestfit <- fit3
  if(fit2$value < bestfit$value)
    bestfit <- fit2
  if(fit1$value < bestfit$value)
    bestfit <- fit1
  if(AICc(fit0) < bestfit$value)
  {
    bestfit <- fit0
    bestfit$year <- data$year
    if(!is.null(data$island))
      bestfit$name <- paste(data$island,"island:",data$species)
    else
      bestfit$name <- deparse(substitute(data))
    bestfit$data <- data
  }
  else  # Refit best model
    bestfit <- lagphase.knots(bestfit$par, data=data, order=order)
  return(bestfit)
}


#' Function model with lag phase followed by growth where knots and order are specified
#'
#' @param data data.frame
#' @param knots the numbr of nots
#' @param order the order of the knots
#' @return results data.frame with species
#' @export lagphase.knots

lagphase.knots <- function(knots, data, order)
{
  specimens <- data$specimens
  x <- matrix(NA,ncol=length(knots),nrow=length(data$year))
  #x[,1] <- as.numeric(data$year < knots[1])
  for(i in 1:length(knots))
    x[,i] <- pmax((data$year-knots[i])^order,0)

  fit <- glm(frequency ~ x, offset=log(specimens), family=poisson, data=data, na.action=na.omit)
  fit$knots <- knots
  names(fit$knots) <- paste("K",1:length(knots),sep="")
  fit$year <- data$year
  fit$order <- order
  if(!is.null(data$island))
    fit$name <- paste(data$island,"island:",data$species)
  else
    fit$name <- deparse(substitute(data))
  fit$data <- data
  return(fit)
}

#' Function that checks that the specified knots make sense then use lagphase.knots
#' to fit the model and returns AIC of fitted model
#'
#' @param data data.frame
#' @param knots the numbr of nots
#' @param order the order of the knots
#' @return AIC of fitted model
#' @export tryknots

tryknots <- function(knots, data, order)
{
  # Knots must be interior to the data
  if(min(knots) < min(data$year))
    return(1e50)
  if(max(knots) > max(data$year))
    return(1e50)
  # Knots must be five years apart and ordered
  if(length(knots) > 1)
  {
    dk <- diff(knots)
    if(min(diff(knots)) < 5)
      return(1e50)
  }
  # OK. Now fit the model
  fit <- lagphase.knots(knots, data, order)
  # Return the AICc of the fitted model
  return(AICc(fit))
}

#' Function to return corrected AIC from a fitted object
#'
#' @param object model object
#' @return AICc
#' @export AICc

# Function to return corrected AIC from a fitted object
AICc <- function(object)
{
  aic <- object$aic
  k <- length(object$coefficients)
  n <- object$df.residual+k
  aicc <- aic + 2*k*(k+1)/(n-k-1)
  return(aicc)
}


#' Function to plot the fitted spline function after adjusting for number of specimens (records)
#'
#' @param fit the model fit
#' @param ylim limit of y axis
#' @param xlab x lable
#' @param ylab y lable
#' @param ... further arguments to be passed to the predict funtion
#' @param main the title
#' @return plot
#' @export lagphaseplot

lagphaseplot <- function(fit,ylim=NULL,xlab="Year", ylab="Adjusted frequency", main=fit$name, ...)
{
  fits <- predict(fit, se.fit=TRUE)
  #specimens <- model.matrix(fit)[,"specimens"]
  #adjfits <- fits$fit - coef(fit)["specimens"]*(specimens - mean(specimens))
  adjfits <- exp(fits$fit - fit$offset + mean(fit$offset,na.rm=TRUE))
  up <- adjfits * exp(2*fits$se.fit)
  lo <- adjfits * exp(-2*fits$se.fit)
  if(is.null(ylim))
    ylim <- range(lo,up)
  j <- (fit$data$specimens > 0)
  plot(fit$data$year[j],adjfits, ylim=ylim, type="n", xlab=xlab,ylab=ylab,
       main=main,...)
  polygon(c(fit$data$year[j],rev(fit$data$year[j])),c(lo,rev(up)),border=FALSE,col="gray")
  lines(fit$data$year[j],adjfits)
  if(!is.null(fit$knots))
    abline(v=fit$knots[1],col="gray")
  rug(fit$year[fit$data$frequency > 0])
}


#' Function to plot the frequency
#' @param fit1 the model fit1
#' @param fit2 the model fit2
#' @param fit3 the model fit3
#' @param fit4 the model fit4
#' @param xlab x lable
#' @param ylab y lable
#' @param ... further arguments to be passed to the predict funtion
#' @param main the title
#' @param cols numberof columns
#' @return plot
#' @export freqplot

freqplot <- function(fit1, fit2=NULL, fit3=NULL, fit4=NULL,
                     xlab="Year", ylab="Frequency", main=fit1$name, cols=2:5, ...)
{
  if(is.element("data",names(fit1)))
    data <- fit1$data
  else
  {
    data <- fit1
    fit1 <- NULL
  }

  plot(frequency ~ year, data=data, xlab=xlab, ylab=ylab, main=main,
       ylim=range(0,data$frequency,na.rm=TRUE),...)
  j <- (data$specimens > 0)
  if(!is.null(fit1))
    lines(data$year[j],fitted(fit1),col=cols[1])
  if(!is.null(fit2))
    lines(data$year[j],fitted(fit2),col=cols[2])
  if(!is.null(fit3))
    lines(data$year[j],fitted(fit3),col=cols[3])
  if(!is.null(fit4))
    lines(data$year[j],fitted(fit4),col=cols[4])
}

#' Fit piecewise linear model
#'
#' @param x time series object
#' @param y frequency counts
#' @return results
#' @export pwlm

pwlm <- function(x,y)
{
  # choose knot
  minmse <- Inf
  xgrid <- seq(min(x),max(x),l=102)[-c(1,102)]
  for(k in xgrid)
  {
    x2 <- pmax(x-k,0)
    fit <- lm(y ~ x + x2)
    res <- residuals(fit)
    mse <- mean(res^2)
    if(mse < minmse)
    {
      bestfit <- fit
      bestfit$k <- k
      minmse <- mse
    }
  }
  return(bestfit)
}
