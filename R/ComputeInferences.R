#' @title ComputeInferences
#'
#'@description
#' This function calculates Statistical Inferences from Posterior Distributions
#'
#' @param samples A numeric vector containing samples from a posterior distribution of any estimate.
#' @param HPD A scalar value between 0 and 1 specifying the desired probability to compute the highest posterior density (HPD) interval. Default value is 0.95.
#' @param P0 A logical (default is `TRUE`). If `TRUE`, computes the probability that the posterior distribution is greater than zero if the median is positive, or less than zero if the median is negative.
#' @param K A logical(default is `FALSE`). If `TRUE`, computes a "guaranteed" value of the posterior distribution with a specified probability (`probK`). This value is only displayed if its sign matches the sign of the median of the posterior distribution.
#' @param probK A numeric value between 0 and 1 specifying the probability threshold for computing the guaranteed value when `K` is `TRUE`. If `K` is `TRUE` and `probK` is not specified, a default value of 0.80 is used.
#' @param PR A logical (default is `FALSE`). If `TRUE`, computes the probability that the posterior distribution is greater than a relevant value (`R`) if the median is positive, or less than `R` if the median is negative.
#' @param R A scalar specifying a relevant value for computing `PR`. It's mandatory if `PR` or `PS` is `TRUE`.
#' @param PS A logical (default is `FALSE`). If `TRUE`, computes the probability of similarity, i.e., the probability that the posterior distribution lies within `-R` to `R`
#' @param askCompare Specifies the mode of comparison, either "D" for differences or "R" for ratios, affecting how `PR` and `PS` are calculated. If "D", PR is computed assuming -R as threshold if the median is <0, and PS is computed between -R and R. If "R", PR is computed assuming 1/R as threshold if the median is <1, and PS is computed between 1/R and R.
#'
#' @return Returns a numeric vector containing calculated inferences from the posterior samples
#' @importFrom HDInterval hdi
#' @export
#'
#' @examples
#' \dontrun{
#'  # Example:
#'  # Basic inference calculation
#'  basic_inf <- computeInferences(samples)
#'  # Advanced inference calculation with custom settings
#'  advanced_inf <- computeInferences(samples, askCompare="R", HPD=0.7, P0=TRUE, K=TRUE,
#'  probK=0.8, PR=TRUE, R=1.1, PS=FALSE)
#'}

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
  hpdInterval <- HDInterval::hdi(samples, credMass = HPD)

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
