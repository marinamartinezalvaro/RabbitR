
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

IMF = m + Sex + AE + OP + b·LW + Rand(c) + e

PFat = m + Sex + AE + OP + b·LW + Rand(c) + e

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
#> Note: No interaction effects specified
#> 
#> Model equation for all Traits is : y = mean + Sex + AE + OP + b* LW + Random(c)
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
#> DIC (Deviance Information Criterion) = -432.9782 
#> ---------------------------------------------------
#> 
#> 
#> 
#> Geweke's Convergence Diagnostics Z-Scores Summary:
#> ---------------------------------------------------
#> Effects Z-Scores:
#>   (Intercept): -0.561166539739003
#>   Sex2: -0.30050448897673
#>   AE2: -0.350541294668947
#>   OP2: -0.124256419093273
#>   OP3: 1.68771800985571
#>   LW: 0.745928264477138
#> 
#> VarianceComponents Z-Scores:
#>   c: 2.27617910150364 (Potential issue with convergence)
#>   Ve: -1.46806176493024
#> 
#> Interpretation of Geweke's Z-Scores:
#> Z-scores within the range of -2 to 2 generally indicate that the chain has converged to the target distribution.
#> Z-scores outside this range may suggest issues with convergence, warranting further investigation.
#> ---------------------------------------------------
#> 
#> 
#> Computing Means... 
#> 
#>  Means computed! 
#> ---------------------------------------------------
#> 
#> Computing Contrasts between levels of Treatment effects... 
#> ---------------------------------------------------
#>  Contrasts computed!  Covariates computed!  Variances of Random Effects computed! 
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
#> DIC (Deviance Information Criterion) = 2474.962 
#> ---------------------------------------------------
#> 
#> 
#> 
#> Geweke's Convergence Diagnostics Z-Scores Summary:
#> ---------------------------------------------------
#> Effects Z-Scores:
#>   (Intercept): 0.56295387862287
#>   Sex2: 0.429486454068053
#>   AE2: -0.241830592772411
#>   OP2: -1.51989438189441
#>   OP3: -0.419190627509812
#>   LW: -0.536467927600128
#> 
#> VarianceComponents Z-Scores:
#>   c: -1.077895798628
#>   Ve: 1.26867284064471
#> 
#> Interpretation of Geweke's Z-Scores:
#> Z-scores within the range of -2 to 2 generally indicate that the chain has converged to the target distribution.
#> Z-scores outside this range may suggest issues with convergence, warranting further investigation.
#> ---------------------------------------------------
#> 
#> 
#> Computing Means... 
#> 
#>  Means computed! 
#> ---------------------------------------------------
#> 
#> Computing Contrasts between levels of Treatment effects... 
#> ---------------------------------------------------
#>  Contrasts computed!  Covariates computed!  Variances of Random Effects computed!
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
#> Median:  1.181934 
#> Mean:  1.181953 
#> SD:  0.007018359 
#> HPD Lower:  1.168617 
#> HPD Upper:  1.195995 
#> ---------------------------------------------------
#> ---------------------------------------------------
#>  Residual Variance
#> Median:  0.02388016 
#> Mean:  0.02394869 
#> SD:  0.001625195 
#> HPD Lower:  0.02069276 
#> HPD Upper:  0.02712196 
#> ---------------------------------------------------
#> Inferences of posterior chains for treatMeans 
#> ---------------------------------------------------
#> Sex 1 
#> Median:  1.166706 
#> Mean:  1.165928 
#> SD:  0.02839652 
#> HPD Lower:  1.112862 
#> HPD Upper:  1.219871 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  1.202283 
#> ---------------------------------------------------
#> Sex 2 
#> Median:  1.153149 
#> Mean:  1.152455 
#> SD:  0.02846924 
#> HPD Lower:  1.098314 
#> HPD Upper:  1.209316 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  1.189226 
#> ---------------------------------------------------
#> Inferences of posterior chains for Compare 
#> ---------------------------------------------------
#> Sex 1-2 
#> Median:  0.0136849 
#> Mean:  0.01347306 
#> SD:  0.01402777 
#> HPD Lower:  -0.01532127 
#> HPD Upper:  0.03937308 
#> P0:  0.8304 
#> Guaranteed Value with prob 0.9 :  0.03192241 
#> PR with R 0.05 :  0.0036 
#> PS with R 0.05 :  0.9964 
#> ---------------------------------------------------
#> Inferences of posterior chains for Cov 
#> ---------------------------------------------------
#> Cov LW 
#> Median:  0.00027447 
#> Mean:  0.0002752855 
#> SD:  4.578658e-05 
#> HPD Lower:  0.0001899744 
#> HPD Upper:  0.0003662265 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  0.0003344473 
#> ---------------------------------------------------
#> Inferences of posterior chains for RandomVariances 
#> ---------------------------------------------------
#> RandomVariances c 
#> Median:  3.132024e-07 
#> Mean:  0.0001499061 
#> SD:  0.0004423472 
#> HPD Lower:  1.42194e-12 
#> HPD Upper:  0.001045848 
#> ---------------------------------------------------
#> 
#> 
#> 
#> Processing Trait: PFat 
#> ---------------------------------------------------
#>  Model Mean
#> Median:  10.62626 
#> Mean:  10.62411 
#> SD:  0.1370603 
#> HPD Lower:  10.34926 
#> HPD Upper:  10.87476 
#> ---------------------------------------------------
#> ---------------------------------------------------
#>  Residual Variance
#> Median:  7.075414 
#> Mean:  7.140453 
#> SD:  0.7012371 
#> HPD Lower:  5.848523 
#> HPD Upper:  8.510283 
#> ---------------------------------------------------
#> Inferences of posterior chains for treatMeans 
#> ---------------------------------------------------
#> Sex 1 
#> Median:  9.034583 
#> Mean:  9.033289 
#> SD:  0.5269318 
#> HPD Lower:  7.950903 
#> HPD Upper:  10.0159 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  9.717454 
#> ---------------------------------------------------
#> Sex 2 
#> Median:  10.63319 
#> Mean:  10.62284 
#> SD:  0.5247854 
#> HPD Lower:  9.555619 
#> HPD Upper:  11.61131 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  11.29208 
#> ---------------------------------------------------
#> Inferences of posterior chains for Compare 
#> ---------------------------------------------------
#> Sex 1-2 
#> Median:  -1.592421 
#> Mean:  -1.589552 
#> SD:  0.2357411 
#> HPD Lower:  -2.059659 
#> HPD Upper:  -1.151798 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  -1.891676 
#> PR with R 1 :  0.9932 
#> PS with R 1 :  0.0068 
#> ---------------------------------------------------
#> Inferences of posterior chains for Cov 
#> ---------------------------------------------------
#> Cov LW 
#> Median:  0.01818749 
#> Mean:  0.01821006 
#> SD:  0.0008301467 
#> HPD Lower:  0.01670523 
#> HPD Upper:  0.01995836 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  0.01929237 
#> ---------------------------------------------------
#> Inferences of posterior chains for RandomVariances 
#> ---------------------------------------------------
#> RandomVariances c 
#> Median:  1.167787 
#> Mean:  1.137753 
#> SD:  0.5990442 
#> HPD Lower:  0.008924544 
#> HPD Upper:  2.094267 
#> ---------------------------------------------------
```

<img src="man/figures/README-Bayes-1.png" width="100%" /><img src="man/figures/README-Bayes-2.png" width="100%" />

This package makes extensive use of `MCMCglmm` R package. We acknowledge
the work by Jarrod D. Hadfield in this area, as detailed in the
following reference:

Hadfield, J. D. (2010). MCMC methods for multi-response generalized
linear mixed models: the MCMCglmm R package. *Journal of Statistical
Software*, 33, 1-22. Available at [Journal of Statistical
Software](https://www.jstatsoft.org/article/view/v033i02).
