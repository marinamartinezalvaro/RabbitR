# test_that("iCreateParam works", {
#   iCreateParam()
# })
# library(testthat)
#
#

test_that("Rabbit works")
be2<-iCreateParam()
be<-CreateParam(file.name = "~/Dropbox/Rpackages/RabbitR/DataFixed.csv",
            na.codes ="99999",
            hTrait = c("IMF","PFat"),
            hTreatment = c("AE","LG"),
            hNoise = c("OP"),
            askCompare="R",
            hCov=c("LW"))

            #hRand = c("pH"),
            #hCov=c("LW","pH"))

            # hInter=c("Sex","LG"),
            # typeInter=c("F","F"),
            # ShowInter=c("T"),
            # hRand = c("pH","PFat"))

#Test Bunny
be_result<-Bunny(params=be, Chain = FALSE)

#Test BAYES
INFERENCES<-Bayes(params=be, bunny=be_result, HPD=0.95, P0=TRUE,
                  K=T, probK=0.80,
                  PR=T, R=c(1.1,1.2),PS=T,
                  SaveTable=TRUE, plot=T)

params=parametras
bunny=result
HPD=0.95
P0=TRUE
K=TRUE
probK=0.80
PR=TRUE
R=0.05
PS=TRUE
tables=TRUE
plot=FALSE

test<-extract_list_data()


#Compare with LSMEANS
data$Sex<-as.factor(data$Sex)
data$OP<-as.factor(data$OP)
str(data)
TESTBRMS <- brm(IMF ~ Sex + OP + LW,
                data    = data,
                family  = gaussian(),
                iter    = 30000,
                chains  = 1,
                warmup  = 5000,
                thin    = 10,
                control = list(adapt_delta = 0.99),
                silent  = 2,
                refresh = 0,
                backend = "cmdstanr",
                threads = threading(1),
                seed    = NA)


