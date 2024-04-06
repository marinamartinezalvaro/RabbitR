

#' Title Rabbit
#'
#'@description
#'this function `runs general linear models and computes inferences from posterior chains.Its a didactic function as it has no arguments and all required information is interactively obtain through questions answered by the user
#'
#' @param Chain Logical (default=FALSE). If TRUE, all the samples of the posterior distributions of the estimated parameters are stored for each trait.
#'
#' @return three lists: params (containing the parameter file), bunny (a list containing the samples of the posterior distributions of the estimated parameters for each trait), and inferences (a list with the inferences computed for each trait)
#' @import HDInterval
#' @import ggplot2
#' @import tidyr
#' @import MCMCglmm
#' @import coda
#' @import knitr
#' @import openxlsx
#' @import readxl
#' @importFrom utils read.csv
#' @import dplyr
#' @export
#'
#' @examples


Rabbit<-function() {

  params<-iCreateParam()

  bunny<-Bunny(params, Chain=FALSE)

  inferences<-iBayes(params, bunny)

  return(inferences)
}
