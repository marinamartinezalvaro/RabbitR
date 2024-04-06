# test_that("iCreateParam works", {
#   iCreateParam()
# })
# library(testthat)
#
#
# # Test if the function correctly processes traits, treatments, noise, covariates, interactions, and random effects
# test_that("CreateParam correctly processes effects", {
#   # Provide sample input arguments
#   filePath <- "DataFixed.csv"
#   hTrait <- c("IMF", "PFat")
#   hNoise <- c("AE")
#   hCov <- c("LW", "pH")
#   hInter <- matrix(c("Sex", "pH", "pH","Sex"), nrow = 1)
#   hRand <- c("OP")
#   # Call the function
#   result <- CreateParam(filePath, hTrait = hTrait, hTreatment = hTreatment,
#                         hNoise = hNoise, hCov = hCov, hInter = hInter, hRand = hRand)
#   # Check if the output contains the expected values
#   expect_equal(result[["hTrait"]], hTrait)
#   expect_equal(result[["hTreatment"]], hTreatment)
#   expect_equal(result[["hNoise"]], hNoise)
#   expect_equal(result[["hCov"]], hCov)
#   expect_equal(result[["hInter"]], hInter)
#   expect_equal(result[["hRand"]], hRand)
# })
#
# #Test Function using headers
# resultados<-rabbit()
#
# parametros<-iCreateParam()
#
# be<-CreateParam(file.name = "~/Dropbox/Rpackages/RabbitR/DataFixed.csv",
#             na.codes ="99999",
#             hTrait = c("IMF"),
#             hTreatment = c("AE","LG"),
#             hNoise = c("OP"),
#             askCompare="R",
#             hCov=c("LW"))
#
#             #hRand = c("pH"),
#             #hCov=c("LW","pH"))
#
#             # hInter=c("Sex","LG"),
#             # typeInter=c("F","F"),
#             # ShowInter=c("T"),
#             # hRand = c("pH","PFat"))
#
# #Test Bunny
# be_result<-bunny(params=be, Chain = FALSE)
#
# #Test BAYES
# INFERENCES<-bayes(params=be, bunny=be_result, HPD=0.95, P0=TRUE,
#                   K=T, probK=0.80,
#                   PR=T, R=c(1.1),PS=T,
#                   SaveTable=TRUE, plot=T)
#
# params=parametras
# bunny=result
# HPD=0.95
# P0=TRUE
# K=TRUE
# probK=0.80
# PR=TRUE
# R=0.05
# PS=TRUE
# tables=TRUE
# plot=FALSE
#
# test<-extract_list_data()
#
#
# #Compare with LSMEANS
# data$Sex<-as.factor(data$Sex)
# data$OP<-as.factor(data$OP)
# str(data)
# TESTBRMS <- brm(IMF ~ Sex + OP + LW,
#                 data    = data,
#                 family  = gaussian(),
#                 iter    = 30000,
#                 chains  = 1,
#                 warmup  = 5000,
#                 thin    = 10,
#                 control = list(adapt_delta = 0.99),
#                 silent  = 2,
#                 refresh = 0,
#                 backend = "cmdstanr",
#                 threads = threading(1),
#                 seed    = NA)
#
# #With package EMMEANS
# library(emmeans)
# library(tidybayes)
# library(dplyr)
# library(tidyr)
#
# print(summary(TESTBRMS), digits=10)
# epred <- emmeans(TESTBRMS, specs = c("Sex"))
# #epred2 <- emmeans(TESTBRMS, specs = pairwise ~ Sex * OP)
# iter_posterior <- gather_emmeans_draws(epred)
# iter_bylevels <- iter_posterior %>%
#   pivot_wider(names_from = c("Sex") , values_from = ".value")
# head(iter_bylevels)
# iter_bylevels<-data.frame(iter_bylevels[-c(1:3)])
# colMeans(iter_bylevels)
# summary(data)
