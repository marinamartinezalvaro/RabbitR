

#' @title Rabbit
#'
#'@description
#' This function runs an Interactive Analysis with General Linear Models and Bayesian Inferences. `Rabbit` serves as an all-in-one interactive function for running general linear models, generating posterior distributions, and computing inferences.
#'
#' @details
#' `Rabbit` integrates several steps of Bayesian analysis into a single, interactive function. Starting with parameter specification via `iCreateParam`, it proceeds to model execution with `Bunny`, and concludes with inferential statistics using `iBayes`. This function is particularly useful for educational purposes, offering a hands-on experience with Bayesian statistical analysis. Users are prompted to input various parameters and options at different stages, ensuring a tailored analysis process.
#'
#' @param Chain A logical value (default is `FALSE`). If set to `TRUE`, the function stores all samples of the posterior distributions of the estimated parameters for each trait, allowing for detailed post-hoc analysis.
#'
#' @return Returns a list with computed inferences for each trait, including model means, treatments, contrasts, covariates, variance components, and probabilities associated with specified thresholds.
#'
#' @importFrom HDInterval hdi
#' @import ggplot2
#' @import tidyr
#' @import MCMCglmm
#' @import coda
#' @import knitr
#' @import openxlsx
#' @import readxl
#' @importFrom utils read.csv
#' @import dplyr
#' @importFrom ggdist stat_halfeye
#'
#' @examples
#' \dontrun{
#' # Example
#' results <- Rabbit()
#' results <- Rabbit(Chain=TRUE)
#'}
#' @export


Rabbit<-function(Chain=FALSE) {

  params<-iCreateParam()

  bunny<-Bunny(params, Chain=FALSE)

  inferences<-iBayes(params, bunny)

  return(inferences)
}
