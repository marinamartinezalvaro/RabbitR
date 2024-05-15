
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RabbitR

<!-- badges: start -->
<!-- badges: end -->

This is a teaching-oriented package for univariate linear mixed models
solved using Bayesian theory. The package includes visualization and
characterization of marginal posterior distributions of the estimates.

## Installation

You can install the development version of RabbitR from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("marinamartinezalvaro/RabbitR")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(RabbitR)
#> 
#>            / \  / \
#>           (   \/   )
#>            \      /
#>             \ .. /
#>             (o Y o)
#>             /    \
#>            (      )
#>           /        \
#>          (          )
#>         ( (  )  (  ) )
#>          (__(__)__)
#>          ------------
#>         |   RabbitR  |
#>          ------------
#>   Welcome to RabbitR! Hop into the documentation with '??RabbitR'.
#> 
```

In this example, we are going to use DataIMF from RabbitR package.The
DataIMF dataset (502 observations across 8 variables) comes from three
generations of a divergent selection experiment for intramuscular fat in
rabbits.The data are based on perirenal fat (PFat), intramuscular fat
(IMF) and loin pH of rabbits belonging to both sexes (Sex), with an
specific live weight (LW). The data have been taken at different seasons
(AE, 2 levels) and rabbits were born at different parity orders (OP),and
have a random litter effect (c).This is how DataIMF looks like:

``` r
data(DataIMF)
head(DataIMF)
#>   AE OP LG Sex c   LW       pH   IMF  PFat
#> 1  1  1  1   1 1 1790     5.64 1.089  9.20
#> 2  1  1  1   1 2 1795     5.45 1.118 12.40
#> 3  1  1  1   1 3 1505 99999.00 0.939  3.10
#> 4  1  1  1   1 4 1870     5.64 1.229 13.82
#> 5  1  1  1   1 5 1725     5.51 1.068  7.01
#> 6  1  1  1   1 6 1570     5.44 1.439  8.20
```

We aim to explore the impact of Sex on IMF and PFat traits.
Additionally, we recognize the potential influence of the season when
data were collected, the parity order of the animals, their LW, and
their common litter effects on IMF, which necessitates adjustment. In
this context, Sex is considered our treatment of interest. Other fixed
effects that require correction but are not our primary focus are
categorized as Noise effects (AE, OP). Live Weight (LW) is a continuous
trait and will thus be treated as a covariate. Effects from common
litter will be modeled as random effects.

The RabbitR package supports univariate analysis, applying the same
univariate model across multiple traits:

IMF = m + Sex + AE + OP + AE\*OP + b·LW + Rand(c) + e

PFat = m + Sex + AE + OP + AE\*OP + b·LW + Rand(c) + e

To carry out our analysis, we’ll utilize the CreateParam, Bunny, and
Bayes functions. This workflow covers creating a parameter file
(CreateParam), executing general linear models and producing posterior
distributions (Bunny), and performing inferences (Bayes). For beginners
or those less familiar with R, interactive versions are available:
iCreateParam for CreateParam and iBayes for Bayes. Additionally, the
Rabbit function merges iCreateParam, Bunny, and iBayes into a
comprehensive, interactive tool, ideal for educational purposes.

Lets start creating our parameter file. To initiate our analysis, we’ll
create a parameter file using a CreateParam function. User can specify
Traits, Treatments, Noise, covariates, or random effects. You can define
these either by their column names in the data file (hTrait, hTreatment,
hNoise, hCov, hRand) or by their positions (pTrait, pTreatment, pNoise,
pCov, pRand), useful for analyzing multiple traits. The askCompare
argument lets you choose how to contrast different treatment levels
(e.g., sex1 and Sex2) - as a difference (askCompare=“D”) or a ratio
(askCompare=“R”).

``` r

param_list<-CreateParam(
  file.name = "DataIMF",
  na.codes=c("99999"),
  hTrait = c("IMF", "PFat"),
  hTreatment = "Sex",
  askCompare="D",
  hNoise = c("AE", "OP"),
  hInter=matrix(c("AE","OP"), nrow=1),
  ShowInter=c("T"),
  hCov = c("LW"),
  hRand = "c")
#> 
#> Let's create you Parameter file:
#> ---------------------------------------------------
#> 'data.frame':    502 obs. of  9 variables:
#>  $ AE  : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ OP  : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ LG  : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ Sex : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ c   : int  1 2 3 4 5 6 7 8 9 10 ...
#>  $ LW  : int  1790 1795 1505 1870 1725 1570 1780 1675 1870 1500 ...
#>  $ pH  : num  5.64 5.45 NA 5.64 5.51 5.44 5.47 5.45 5.53 5.5 ...
#>  $ IMF : num  1.089 1.118 0.939 1.229 1.068 ...
#>  $ PFat: num  9.2 12.4 3.1 13.82 7.01 ...
#> The number of rows in the data file is 502
#> See below the summary statistics of the traits:  IMF PFat
#> 
#> 
#> Table: Summary Statistics of Traits
#> 
#>              Mean          SD     Min   1st Qu..25%   Median   3rd Qu..75%     Max         CV   Missing Values
#> -----  ----------  ----------  ------  ------------  -------  ------------  ------  ---------  ---------------
#> IMF      1.180445   0.1640249   0.796         1.061   1.1655       1.28975    1.72   13.89517                8
#> PFat    10.620199   4.5220638   2.510         7.480   9.8000      12.91500   44.06   42.57984                0
#> The number of levels read in Treatments are: 2.
#> The number of levels read in Noise are: 2, 3. Contingency Tables across effects 
#> [1] "Sex vs AE"
#>       
#>        AE1 AE2
#>   Sex1 192  56
#>   Sex2 208  46
#>  Contingency Tables across effects 
#> [1] "Sex vs OP"
#>       
#>        OP1 OP2 OP3
#>   Sex1 219  27   2
#>   Sex2 223  29   2
#>  Contingency Tables across effects 
#> [1] "AE vs OP"
#>      
#>       OP1 OP2 OP3
#>   AE1 348  48   4
#>   AE2  94   8   0
#> See below the summary statitics of covariates:  LW
#> 
#> 
#> Table: Summary Statistics of Covariates
#> 
#>           Mean         SD    Min   1st Qu..25%   Median   3rd Qu..75%    Max         CV   Missing Values
#> ---  ---------  ---------  -----  ------------  -------  ------------  -----  ---------  ---------------
#> LW    1757.058   177.1815   1380          1630     1745          1880   2595   10.08399                0
#> The number of levels of Interaction 1 is 6.
#> Model equation for all Traits is : y = mean + Sex + AE + OP + b* LW + AE*OP + Random(c)
#> [1] "Your parameter file its ready!"
```

Once the parameter file is ready, we can proceed to fit our model with
Bunny

``` r

bunny_results <- Bunny(params = param_list, Chain = FALSE)
#>  Bunny Starting ... 
#> 
#> 
#> Warning: Removed 0 rows due to missing values in model effects.
#> 
#> 
#> 
#> Analysis for Trait  IMF  in progress 
#> ---------------------------------------------------
#> 
#> 
#> Features of posterior samples:
#> ---------------------------------------------------
#> Number of iterations = 30000 
#> Burn-in = 5000 
#> Lag = 10 
#> Number of samples stored = 2500 
#> ---------------------------------------------------
#> 
#> 
#> Model Evaluation Criterion:
#> ---------------------------------------------------
#> DIC (Deviance Information Criterion) = -431.3439 
#> ---------------------------------------------------
#> 
#> 
#> 
#> Geweke's Convergence Diagnostics Z-Scores Summary:
#> ---------------------------------------------------
#> Effects Z-Scores:
#>   (Intercept): -0.706283301205728
#>   Sex2: -0.691777750956906
#>   AE2: -0.288664984915848
#>   OP2: 2.44457702392539 (Potential issue with convergence)
#>   OP3: 1.92579323544178
#>   LW: 0.64251639232671
#>   AE2:OP2: 0.0193777774042915
#>   AE2:OP3: 0.716215285027778
#> 
#> VarianceComponents Z-Scores:
#>   c: 2.84235978631171 (Potential issue with convergence)
#>   Ve: -2.6135118221404 (Potential issue with convergence)
#> 
#> Interpretation of Geweke's Z-Scores:
#> Z-scores within the range of -2 to 2 generally indicate that the chain has converged to the target distribution.
#> Z-scores outside this range may suggest issues with convergence, warranting further investigation.
#> ---------------------------------------------------
#> 
#> 
#> Computing Means... 
#> 
#> Means computed 
#> ---------------------------------------------------
#> 
#> Computing Contrasts between levels of Treatment effects... 
#> 
#> Contrasts computed 
#> 
#> Covariates computed 
#> Variances of Random Effects computed 
#> 
#> Analysis for Trait  PFat  in progress 
#> ---------------------------------------------------
#> 
#> 
#> Features of posterior samples:
#> ---------------------------------------------------
#> Number of iterations = 30000 
#> Burn-in = 5000 
#> Lag = 10 
#> Number of samples stored = 2500 
#> ---------------------------------------------------
#> 
#> 
#> Model Evaluation Criterion:
#> ---------------------------------------------------
#> DIC (Deviance Information Criterion) = 2477.18 
#> ---------------------------------------------------
#> 
#> 
#> 
#> Geweke's Convergence Diagnostics Z-Scores Summary:
#> ---------------------------------------------------
#> Effects Z-Scores:
#>   (Intercept): 0.968295014827297
#>   Sex2: -0.217629211961074
#>   AE2: -0.85129236340269
#>   OP2: -0.630064011041756
#>   OP3: -0.293286233303498
#>   LW: -0.884946440847891
#>   AE2:OP2: -0.117125849431837
#>   AE2:OP3: -0.0976706998196129
#> 
#> VarianceComponents Z-Scores:
#>   c: 0.214417254379243
#>   Ve: -0.125400195080648
#> 
#> Interpretation of Geweke's Z-Scores:
#> Z-scores within the range of -2 to 2 generally indicate that the chain has converged to the target distribution.
#> Z-scores outside this range may suggest issues with convergence, warranting further investigation.
#> ---------------------------------------------------
#> 
#> 
#> Computing Means... 
#> 
#> Means computed 
#> ---------------------------------------------------
#> 
#> Computing Contrasts between levels of Treatment effects... 
#> 
#> Contrasts computed 
#> 
#> Covariates computed 
#> Variances of Random Effects computed 
#> ---------------------------------------------------
#> 
#> Bunny finished. The posterior chains of your estimates are ready :) 
#> ---------------------------------------------------
```

Function Bunny creates a list containing the samples of the posterior
chains for the model mean, means of treatment levels, contrats between
those levels, covariates, variance components (residual and random). The
bunny output will serve as input for function Bayes, together with my
param_list object.

Although posterior chains might seem complex at first, they offer us the
ability to make multiple inferences from the entire distribution, not
just single-point estimates-making our analysis more engaging. The
function simplifies in-depth analysis of posterior distributions from
Bayesian mixed models. For instance, we calculate the probability of the
difference between Sex1 and Sex2 exceeding critical values (0.05 for IMF
and 1 for PFat) and obtain guaranteed values for treatment means,
covariates, and contrasts at a 90% confidence level. Enabling plot=TRUE
visually presents these distributions, with dashed lines at 0 and R
clarifying the positions of P0, PR, and PS.

``` r

inferences <- Bayes(
   params = param_list,
   bunny = bunny_results,
   HPD = 0.95,
   K = TRUE, # Compute a guaranteed value of the estimate
   probK = 0.90, # With 90% probability
   PR = TRUE, # Compute the probability of the posterior chain being greater than a relevant value
   R = c(0.05, 1), # Assuming two traits with relevant values specified
   PS = TRUE, # Compute probability of similarity
   SaveTable = TRUE, # Save detailed inferences in a CSV file
   plot = TRUE) # Additionally, generate plots for contrasts)
#>  Bayes Starting ... 
#> 
#> 
#> 
#> Processing Trait: IMF 
#> ---------------------------------------------------
#>  Model Mean
#> Median:  1.181753 
#> Mean:  1.181719 
#> SD:  0.006995739 
#> HPD Lower:  1.168324 
#> HPD Upper:  1.195962 
#> ---------------------------------------------------
#> ---------------------------------------------------
#>  Residual Variance
#> Median:  0.02389688 
#> Mean:  0.0239866 
#> SD:  0.001595832 
#> HPD Lower:  0.02098504 
#> HPD Upper:  0.02710292 
#> ---------------------------------------------------
#> Inferences of posterior chains for treatMeans 
#> ---------------------------------------------------
#> Sex 1 
#> Median:  -74.58206 
#> Mean:  -163.8566 
#> SD:  16278.05 
#> HPD Lower:  -30536.95 
#> HPD Upper:  32099.51 
#> P0:  0.5016 
#> Guaranteed Value with prob 0.9 :  NA 
#> ---------------------------------------------------
#> Sex 2 
#> Median:  -74.61037 
#> Mean:  -163.8699 
#> SD:  16278.05 
#> HPD Lower:  -30536.97 
#> HPD Upper:  32099.5 
#> P0:  0.5016 
#> Guaranteed Value with prob 0.9 :  NA 
#> ---------------------------------------------------
#> AE:OP 1.1 
#> Median:  1.193676 
#> Mean:  1.193852 
#> SD:  0.008676645 
#> HPD Lower:  1.17646 
#> HPD Upper:  1.210474 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  1.18296 
#> ---------------------------------------------------
#> AE:OP 2.1 
#> Median:  1.16386 
#> Mean:  1.163478 
#> SD:  0.0179647 
#> HPD Lower:  1.129017 
#> HPD Upper:  1.199008 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  1.140074 
#> ---------------------------------------------------
#> AE:OP 1.2 
#> Median:  1.136244 
#> Mean:  1.136071 
#> SD:  0.02290061 
#> HPD Lower:  1.091059 
#> HPD Upper:  1.180448 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  1.107109 
#> ---------------------------------------------------
#> AE:OP 2.2 
#> Median:  1.147277 
#> Mean:  1.146511 
#> SD:  0.05478792 
#> HPD Lower:  1.042352 
#> HPD Upper:  1.253652 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  1.075022 
#> ---------------------------------------------------
#> AE:OP 1.3 
#> Median:  1.18067 
#> Mean:  1.182952 
#> SD:  0.07856725 
#> HPD Lower:  1.04079 
#> HPD Upper:  1.34346 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  1.084363 
#> ---------------------------------------------------
#> AE:OP 2.3 
#> Median:  -453.4629 
#> Mean:  -989.0024 
#> SD:  97668.32 
#> HPD Lower:  -183227.5 
#> HPD Upper:  192591.2 
#> P0:  0.5016 
#> Guaranteed Value with prob 0.9 :  NA 
#> ---------------------------------------------------
#> Inferences of posterior chains for Compare 
#> ---------------------------------------------------
#> Sex 1-2 
#> Median:  0.01312632 
#> Mean:  0.01323516 
#> SD:  0.0138709 
#> HPD Lower:  -0.01273888 
#> HPD Upper:  0.04014196 
#> P0:  0.8292 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 0.05 :  0.0056 
#> PS with R 0.05 :  0.9944 
#> ---------------------------------------------------
#> AE:OP 1.1-2.1 
#> Median:  0.0302283 
#> Mean:  0.03037378 
#> SD:  0.02079609 
#> HPD Lower:  -0.01011574 
#> HPD Upper:  0.07165686 
#> P0:  0.9288 
#> Guaranteed Value with prob 0.9 :  0.00374364 
#> PR with R 0.05 :  0.1656 
#> PS with R 0.05 :  0.8344 
#> ---------------------------------------------------
#> AE:OP 1.1-1.2 
#> Median:  0.05793524 
#> Mean:  0.05778149 
#> SD:  0.02454429 
#> HPD Lower:  0.01084488 
#> HPD Upper:  0.1056387 
#> P0:  0.9912 
#> Guaranteed Value with prob 0.9 :  0.02600334 
#> PR with R 0.05 :  0.628 
#> PS with R 0.05 :  0.372 
#> ---------------------------------------------------
#> AE:OP 1.1-2.2 
#> Median:  0.04609569 
#> Mean:  0.04734112 
#> SD:  0.05546444 
#> HPD Lower:  -0.05998196 
#> HPD Upper:  0.1551561 
#> P0:  0.804 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 0.05 :  0.4728 
#> PS with R 0.05 :  0.4896 
#> ---------------------------------------------------
#> AE:OP 1.1-1.3 
#> Median:  0.0126994 
#> Mean:  0.01090013 
#> SD:  0.07920663 
#> HPD Lower:  -0.1456043 
#> HPD Upper:  0.1595756 
#> P0:  0.5636 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 0.05 :  0.3072 
#> PS with R 0.05 :  0.4732 
#> ---------------------------------------------------
#> AE:OP 1.1-2.3 
#> Median:  454.6586 
#> Mean:  990.1962 
#> SD:  97668.32 
#> HPD Lower:  -192590 
#> HPD Upper:  183228.7 
#> P0:  0.5016 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 0.05 :  0.5016 
#> PS with R 0.05 :  0 
#> ---------------------------------------------------
#> AE:OP 2.1-1.2 
#> Median:  0.02755565 
#> Mean:  0.02740771 
#> SD:  0.02922752 
#> HPD Lower:  -0.02797199 
#> HPD Upper:  0.08385146 
#> P0:  0.83 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 0.05 :  0.2252 
#> PS with R 0.05 :  0.7688 
#> ---------------------------------------------------
#> AE:OP 2.1-2.2 
#> Median:  0.01631929 
#> Mean:  0.01696734 
#> SD:  0.05653106 
#> HPD Lower:  -0.08806846 
#> HPD Upper:  0.1273499 
#> P0:  0.612 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 0.05 :  0.2792 
#> PS with R 0.05 :  0.6024 
#> ---------------------------------------------------
#> AE:OP 2.1-1.3 
#> Median:  -0.01756371 
#> Mean:  -0.01947364 
#> SD:  0.08002513 
#> HPD Lower:  -0.1801124 
#> HPD Upper:  0.1320113 
#> P0:  0.5964 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 0.05 :  0.3488 
#> PS with R 0.05 :  0.46 
#> ---------------------------------------------------
#> AE:OP 2.1-2.3 
#> Median:  454.6104 
#> Mean:  990.1658 
#> SD:  97668.32 
#> HPD Lower:  -192590.1 
#> HPD Upper:  183228.7 
#> P0:  0.5016 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 0.05 :  0.5016 
#> PS with R 0.05 :  0 
#> ---------------------------------------------------
#> AE:OP 1.2-2.2 
#> Median:  -0.01112311 
#> Mean:  -0.01044037 
#> SD:  0.0602413 
#> HPD Lower:  -0.1235743 
#> HPD Upper:  0.1058543 
#> P0:  0.5716 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 0.05 :  0.2608 
#> PS with R 0.05 :  0.5756 
#> ---------------------------------------------------
#> AE:OP 1.2-1.3 
#> Median:  -0.04341168 
#> Mean:  -0.04688136 
#> SD:  0.08178417 
#> HPD Lower:  -0.2112872 
#> HPD Upper:  0.1082995 
#> P0:  0.7232 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 0.05 :  0.472 
#> PS with R 0.05 :  0.412 
#> ---------------------------------------------------
#> AE:OP 1.2-2.3 
#> Median:  454.6135 
#> Mean:  990.1384 
#> SD:  97668.32 
#> HPD Lower:  -192590.1 
#> HPD Upper:  183228.7 
#> P0:  0.5016 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 0.05 :  0.5016 
#> PS with R 0.05 :  0 
#> ---------------------------------------------------
#> AE:OP 2.2-1.3 
#> Median:  -0.03505602 
#> Mean:  -0.03644098 
#> SD:  0.09464477 
#> HPD Lower:  -0.2254628 
#> HPD Upper:  0.1428055 
#> P0:  0.6488 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 0.05 :  0.4376 
#> PS with R 0.05 :  0.3852 
#> ---------------------------------------------------
#> AE:OP 2.2-2.3 
#> Median:  454.6136 
#> Mean:  990.1489 
#> SD:  97668.32 
#> HPD Lower:  -192590.1 
#> HPD Upper:  183228.7 
#> P0:  0.5016 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 0.05 :  0.5016 
#> PS with R 0.05 :  0 
#> ---------------------------------------------------
#> AE:OP 1.3-2.3 
#> Median:  454.7041 
#> Mean:  990.1853 
#> SD:  97668.33 
#> HPD Lower:  -192590.1 
#> HPD Upper:  183228.7 
#> P0:  0.5016 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 0.05 :  0.5016 
#> PS with R 0.05 :  0 
#> ---------------------------------------------------
#> Inferences of posterior chains for Cov 
#> ---------------------------------------------------
#> Cov LW 
#> Median:  0.0002744898 
#> Mean:  0.0002738316 
#> SD:  4.668241e-05 
#> HPD Lower:  0.0001791407 
#> HPD Upper:  0.000364558 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  0.0002165383 
#> ---------------------------------------------------
#> Inferences of posterior chains for RandomVariances 
#> ---------------------------------------------------
#> RandomVariances c 
#> Median:  2.369058e-11 
#> Mean:  6.334662e-05 
#> SD:  0.0002816475 
#> HPD Lower:  9.900045e-15 
#> HPD Upper:  0.0004208236 
#> ---------------------------------------------------
#> 
#> 
#> 
#> Processing Trait: PFat 
#> ---------------------------------------------------
#>  Model Mean
#> Median:  10.62782 
#> Mean:  10.62777 
#> SD:  0.1370366 
#> HPD Lower:  10.3617 
#> HPD Upper:  10.89515 
#> ---------------------------------------------------
#> ---------------------------------------------------
#>  Residual Variance
#> Median:  7.129127 
#> Mean:  7.162594 
#> SD:  0.6939259 
#> HPD Lower:  5.916009 
#> HPD Upper:  8.631536 
#> ---------------------------------------------------
#> Inferences of posterior chains for treatMeans 
#> ---------------------------------------------------
#> Sex 1 
#> Median:  -1048.205 
#> Mean:  -229.0788 
#> SD:  16515.89 
#> HPD Lower:  -31547.91 
#> HPD Upper:  33698.77 
#> P0:  0.5228 
#> Guaranteed Value with prob 0.9 :  NA 
#> ---------------------------------------------------
#> Sex 2 
#> Median:  -1046.722 
#> Mean:  -227.4935 
#> SD:  16515.88 
#> HPD Lower:  -31545.56 
#> HPD Upper:  33700.62 
#> P0:  0.5228 
#> Guaranteed Value with prob 0.9 :  NA 
#> ---------------------------------------------------
#> AE:OP 1.1 
#> Median:  10.83149 
#> Mean:  10.83514 
#> SD:  0.1677673 
#> HPD Lower:  10.49577 
#> HPD Upper:  11.14815 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  10.61911 
#> ---------------------------------------------------
#> AE:OP 2.1 
#> Median:  10.21195 
#> Mean:  10.21424 
#> SD:  0.3443984 
#> HPD Lower:  9.539995 
#> HPD Upper:  10.90501 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  9.772097 
#> ---------------------------------------------------
#> AE:OP 1.2 
#> Median:  10.13795 
#> Mean:  10.14402 
#> SD:  0.4204504 
#> HPD Lower:  9.32378 
#> HPD Upper:  10.93136 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  9.591773 
#> ---------------------------------------------------
#> AE:OP 2.2 
#> Median:  9.35235 
#> Mean:  9.333182 
#> SD:  1.053711 
#> HPD Lower:  7.214042 
#> HPD Upper:  11.33864 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  7.994417 
#> ---------------------------------------------------
#> AE:OP 1.3 
#> Median:  9.496957 
#> Mean:  9.509461 
#> SD:  1.435073 
#> HPD Lower:  6.613862 
#> HPD Upper:  12.19436 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  7.671027 
#> ---------------------------------------------------
#> AE:OP 2.3 
#> Median:  -6333.806 
#> Mean:  -1419.753 
#> SD:  99095.25 
#> HPD Lower:  -189331 
#> HPD Upper:  202141.9 
#> P0:  0.5228 
#> Guaranteed Value with prob 0.9 :  NA 
#> ---------------------------------------------------
#> Inferences of posterior chains for Compare 
#> ---------------------------------------------------
#> Sex 1-2 
#> Median:  -1.589206 
#> Mean:  -1.585269 
#> SD:  0.2497118 
#> HPD Lower:  -2.067915 
#> HPD Upper:  -1.112423 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  -1.266717 
#> PR with R 1 :  0.9888 
#> PS with R 1 :  0.0112 
#> ---------------------------------------------------
#> AE:OP 1.1-2.1 
#> Median:  0.621273 
#> Mean:  0.6208987 
#> SD:  0.3986686 
#> HPD Lower:  -0.1807814 
#> HPD Upper:  1.372098 
#> P0:  0.9356 
#> Guaranteed Value with prob 0.9 :  0.09878104 
#> PR with R 1 :  0.1772 
#> PS with R 1 :  0.8228 
#> ---------------------------------------------------
#> AE:OP 1.1-1.2 
#> Median:  0.6774114 
#> Mean:  0.6911199 
#> SD:  0.4434718 
#> HPD Lower:  -0.1519715 
#> HPD Upper:  1.564032 
#> P0:  0.9416 
#> Guaranteed Value with prob 0.9 :  0.1274498 
#> PR with R 1 :  0.244 
#> PS with R 1 :  0.756 
#> ---------------------------------------------------
#> AE:OP 1.1-2.2 
#> Median:  1.490075 
#> Mean:  1.501955 
#> SD:  1.071504 
#> HPD Lower:  -0.5924205 
#> HPD Upper:  3.578754 
#> P0:  0.9148 
#> Guaranteed Value with prob 0.9 :  0.1096211 
#> PR with R 1 :  0.6896 
#> PS with R 1 :  0.2996 
#> ---------------------------------------------------
#> AE:OP 1.1-1.3 
#> Median:  1.329375 
#> Mean:  1.325676 
#> SD:  1.440467 
#> HPD Lower:  -1.403719 
#> HPD Upper:  4.216679 
#> P0:  0.8224 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 1 :  0.5884 
#> PS with R 1 :  0.36 
#> ---------------------------------------------------
#> AE:OP 1.1-2.3 
#> Median:  6344.658 
#> Mean:  1430.588 
#> SD:  99095.25 
#> HPD Lower:  -202130.6 
#> HPD Upper:  189342.1 
#> P0:  0.5228 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 1 :  0.5228 
#> PS with R 1 :  0 
#> ---------------------------------------------------
#> AE:OP 2.1-1.2 
#> Median:  0.05759493 
#> Mean:  0.07022118 
#> SD:  0.5488466 
#> HPD Lower:  -1.001815 
#> HPD Upper:  1.089162 
#> P0:  0.5472 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 1 :  0.0424 
#> PS with R 1 :  0.9352 
#> ---------------------------------------------------
#> AE:OP 2.1-2.2 
#> Median:  0.8645986 
#> Mean:  0.8810566 
#> SD:  1.0826 
#> HPD Lower:  -1.314689 
#> HPD Upper:  2.904502 
#> P0:  0.798 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 1 :  0.4516 
#> PS with R 1 :  0.502 
#> ---------------------------------------------------
#> AE:OP 2.1-1.3 
#> Median:  0.7133779 
#> Mean:  0.7047778 
#> SD:  1.466253 
#> HPD Lower:  -1.936912 
#> HPD Upper:  3.819265 
#> P0:  0.6776 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 1 :  0.4208 
#> PS with R 1 :  0.4644 
#> ---------------------------------------------------
#> AE:OP 2.1-2.3 
#> Median:  6343.588 
#> Mean:  1429.967 
#> SD:  99095.26 
#> HPD Lower:  -202131.5 
#> HPD Upper:  189341.7 
#> P0:  0.5228 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 1 :  0.5228 
#> PS with R 1 :  0 
#> ---------------------------------------------------
#> AE:OP 1.2-2.2 
#> Median:  0.7922738 
#> Mean:  0.8108354 
#> SD:  1.134922 
#> HPD Lower:  -1.413278 
#> HPD Upper:  3.004246 
#> P0:  0.7676 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 1 :  0.4332 
#> PS with R 1 :  0.5116 
#> ---------------------------------------------------
#> AE:OP 1.2-1.3 
#> Median:  0.6441827 
#> Mean:  0.6345566 
#> SD:  1.480735 
#> HPD Lower:  -2.151404 
#> HPD Upper:  3.620949 
#> P0:  0.6696 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 1 :  0.4036 
#> PS with R 1 :  0.4648 
#> ---------------------------------------------------
#> AE:OP 1.2-2.3 
#> Median:  6343.901 
#> Mean:  1429.897 
#> SD:  99095.23 
#> HPD Lower:  -202131.8 
#> HPD Upper:  189341.1 
#> P0:  0.5228 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 1 :  0.5228 
#> PS with R 1 :  0 
#> ---------------------------------------------------
#> AE:OP 2.2-1.3 
#> Median:  -0.1573003 
#> Mean:  -0.1762788 
#> SD:  1.783203 
#> HPD Lower:  -3.598816 
#> HPD Upper:  3.299606 
#> P0:  0.5376 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 1 :  0.3184 
#> PS with R 1 :  0.434 
#> ---------------------------------------------------
#> AE:OP 2.2-2.3 
#> Median:  6343.205 
#> Mean:  1429.086 
#> SD:  99095.26 
#> HPD Lower:  -202130.3 
#> HPD Upper:  189340 
#> P0:  0.5228 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 1 :  0.5228 
#> PS with R 1 :  0 
#> ---------------------------------------------------
#> AE:OP 1.3-2.3 
#> Median:  6342.705 
#> Mean:  1429.262 
#> SD:  99095.18 
#> HPD Lower:  -202129.1 
#> HPD Upper:  189340.9 
#> P0:  0.5228 
#> Guaranteed Value with prob 0.9 :  NA 
#> PR with R 1 :  0.5228 
#> PS with R 1 :  0 
#> ---------------------------------------------------
#> Inferences of posterior chains for Cov 
#> ---------------------------------------------------
#> Cov LW 
#> Median:  0.01819134 
#> Mean:  0.01821529 
#> SD:  0.0008181156 
#> HPD Lower:  0.01655331 
#> HPD Upper:  0.01981983 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  0.017206 
#> ---------------------------------------------------
#> Inferences of posterior chains for RandomVariances 
#> ---------------------------------------------------
#> RandomVariances c 
#> Median:  1.126626 
#> Mean:  1.123152 
#> SD:  0.5969304 
#> HPD Lower:  0.003254809 
#> HPD Upper:  2.129208 
#> ---------------------------------------------------
```

<img src="man/figures/README-Bayes-1.png" width="100%" /><img src="man/figures/README-Bayes-2.png" width="100%" />

    #> 
    #> Progam finsihed!! :)

This package makes extensive use of `MCMCglmm` R package. We acknowledge
the work by Jarrod D. Hadfield in this area, as detailed in the
following reference:

Hadfield, J. D. (2010). MCMC methods for multi-response generalized
linear mixed models: the MCMCglmm R package. *Journal of Statistical
Software*, 33, 1-22. Available at [Journal of Statistical
Software](https://www.jstatsoft.org/article/view/v033i02).
