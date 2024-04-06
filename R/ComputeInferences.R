#' Title ComputeInferences
#'
#'@description
#'this function makes inferences from posterior chains.
#'
#' @param samples its an numeric vector containing samples from a posterior chain of any estimate
#' @param HPD a scalar from 0 to 1 specifying the amount of probability within the highest posterior density interval to be calculated.
#' @param P0 Logical (default=TRUE). If TRUE, the probability of the estimate to be greater than 0 if the median is positive, or lower than 0 if the median is negative, will be computed.
#' @param K Logical (default=FALSE). If TRUE, a guaranteed value of the estimate with probability Kprob is computed. Only displayed if K has the same sign as the median of the posterior chain.
#' @param probK a numeric value from 0 to 1 indicating the probability to consider in K. If K=TRUE and probK is not specified, a default value of 0.8 will be used.
#' @param PR Logical (default=FALSE). If TRUE, the probability of the posterior chain to be greater than a relevant value (R) if the median is positive, or lower than R if the median is negative, will be computed.
#' @param R a scalar containing a relevant value for computing PR. If any PR or PS is TRUE, this argument is mandatory.
#' @param PS Logical (default=FALSE). If TRUE, the probability of similarity of the estimate is computed. This is, the posterior probability that the estimate is between -R and R.
#' @param askCompare can be either "D" or "R". If "D", PR is computed assuming -R as threshold if the median is <0, and PS is computed between -R and R. If "R", PR is computed assuming 1/R as threshold if the median is <1, and PS is computed between 1/R and R.
#'
#' @return a numeric vector with the Inferences of the posterior chains
#' @import HDInterval
#' @export
#'
#' @examples
#'  # Example usage:
#'  # Inferences <- computeInferences(samples)
#'  # Inferences <- computeInferences(samples, askCompare="R", P0=TRUE, K=TRUE, probK=0.8, PR=TRUE, R=1.1, PS=FALSE)

ComputeInferences <- function(samples, HPD=0.95, P0=TRUE, K=FALSE, probK=0.8, PR=FALSE, R=NULL, PS=FALSE, askCompare="D") {

  # Validation and Defaults
  if ((PR || PS) && is.null(R)) {
    stop("When PR or PS is TRUE, R must be specified.")
  }

  if (PR && is.null(R)) {
    stop("PR is TRUE but R is not specified. Please provide a value for R.")
  }

  est <- median(samples)
  meanVal <- mean(samples)
  sdVal <- sd(samples)
  hpdInterval <- hdi(samples, credMass = HPD)

  # Initialize P0 and prValue
  p0 <- NA
  kGuaranteed <- NA
  pr <- NA
  ps <- NA

  # Calculate P0 based on the sign of the median and on params$askCompare
  if (P0) {
    if (askCompare == "D") {
      p0 <- if(est > 0) { length(which(samples > 0)) / length(samples) } else { length(which(samples < 0)) / length(samples) }
    } else if (askCompare == "R") {
      p0 <- if(est > 1) { length(which(samples > 1)) / length(samples) } else { length(which(samples < 1)) / length(samples) }
    }
  }

  #Calculate Guaranteed Value only if have the same sign as the median
  if (K) {
    quantileValue <- quantile(samples, probs = c(probK, 1 - probK))
    if (est > 0) {
      kGuaranteed <- ifelse(quantileValue[1] > 0, quantileValue[1], NA)  # For positive estimates, use lower quantile if positive
    } else {
      kGuaranteed <- ifelse(quantileValue[2] < 0, quantileValue[2], NA)  # For negative estimates, use upper quantile if negative
    }
  }

  # Calculate Probability of Relevance and Probability of similarity
  if ((PR || PS) && !is.null(R)) {
    if (askCompare == "D") {
      if (PR) {pr <- if(est > 0) { length(which(samples > R)) / length(samples) } else { length(which(samples < -R)) / length(samples) }}
      if (PS) {ps <- length(which(samples >= -R & samples <= R)) / length(samples)}
    } else if (askCompare == "R") {
      if (PR) {pr <- if(est > 1) { length(which(samples > R)) / length(samples) } else { length(which(samples < 1/R)) / length(samples) }}
      if (PS) {ps <- length(which(samples >= 1/R & samples <= R)) / length(samples)}
    }
  }

  return(c(Median=est,
           Mean=meanVal,
           SD=sdVal,
           HPD_low=hpdInterval[1],
           HPD_up=hpdInterval[2],
           P0=p0,
           K=kGuaranteed,
           PR=pr, PS=ps))
}
