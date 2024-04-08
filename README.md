
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RabbitR

<!-- badges: start -->
<!-- badges: end -->

This is a teaching-oriented package for linear mixed models solved using
Bayesian theory. The package includes visualization and characterization
of marginal posterior distributions of the estimates.

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
#>   Welcome to RabbitR! Hop into the documentation with '?RabbitR'.
#> 
## basic example code
```

In this example, we are going to use DataIMF from RabbitR package.The
DataIMF dataset (502 observations across 8 variables) comes from three
generations of a divergent selection experiment for intramuscular fat in
rabbits.The data are based on perirenal fat (PFat), intramuscular fat
(IMF) and loin pH of rabbits belonging to both sexes (Sex), with an
specific live weight (LW). The data have been taken at different seasons
(AE, 2 levels) and rabbits were born at different parity orders (OP),
and have a random litter effect (c).This is how DataIMF looks like:

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

The RabbitR package applies the same model framework to all traits:

IMF = m + Sex + AE + OP + b·LW + Rand(c) + e PFat = m + Sex + AE + OP +
b·LW + Rand(c) + e

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
  na.codes="99999",
  hTrait = c("IMF", "PFat"),
  hTreatment = "Sex",
  askCompare="D",
  hNoise = c("AE", "OP"),
  hCov = c("LW"),
  hRand = "c")
#> 
#> Let's create you Parameter file:
#> ---------------------------------------------------
#> The number of rows in the data file is 502
#> See below the summary statistics of the traits:  IMF PFat
#> 
#> 
#> Table: Summary Statistics of Traits
#> 
#>              Mean             SD     Min   1st Qu..25%   Median   3rd Qu..75%        Max          CV   Missing Values
#> -----  ----------  -------------  ------  ------------  -------  ------------  ---------  ----------  ---------------
#> IMF     1594.7712   12535.113678   0.796       1.06225   1.1685        1.2975   99999.00   786.01330                0
#> PFat      10.6202       4.522064   2.510       7.48000   9.8000       12.9150      44.06    42.57984                0
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
#> DIC (Deviance Information Criterion) = 10846.71 
#> ---------------------------------------------------
#> 
#> 
#> 
#> Geweke's Convergence Diagnostics Z-Scores Summary:
#> ---------------------------------------------------
#> Effects Z-Scores:
#>   (Intercept): -1.41713609993517
#>   Sex2: -0.409850783211325
#>   AE2: -0.936136175805283
#>   OP2: -0.552480085917536
#>   OP3: 2.79013152996274 (Potential issue with convergence)
#>   LW: 1.63630548160322
#> 
#> VarianceComponents Z-Scores:
#>   c: 0.900119326722185
#>   Ve: -0.332753807946659
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
#> DIC (Deviance Information Criterion) = 2477.075 
#> ---------------------------------------------------
#> 
#> 
#> 
#> Geweke's Convergence Diagnostics Z-Scores Summary:
#> ---------------------------------------------------
#> Effects Z-Scores:
#>   (Intercept): 0.126440728102395
#>   Sex2: -0.153149949478658
#>   AE2: -0.188349264408747
#>   OP2: 0.375191572228321
#>   OP3: 0.423190599793789
#>   LW: -0.107594138444365
#> 
#> VarianceComponents Z-Scores:
#>   c: 0.32166577878488
#>   Ve: -0.571118842359247
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
#> Median:  1613.867 
#> Mean:  1621.151 
#> SD:  585.4535 
#> HPD Lower:  558.058 
#> HPD Upper:  2836.934 
#> ---------------------------------------------------
#> ---------------------------------------------------
#>  Residual Variance
#> Median:  119955218 
#> Mean:  121089344 
#> SD:  12320481 
#> HPD Lower:  98290538 
#> HPD Upper:  146350616 
#> ---------------------------------------------------
#> Inferences of posterior chains for treatMeans 
#> ---------------------------------------------------
#> Sex 1 
#> Median:  2405.515 
#> Mean:  2428.851 
#> SD:  2210.345 
#> HPD Lower:  -1672.139 
#> HPD Upper:  6935.267 
#> P0:  0.8636 
#> Guaranteed Value with prob 0.9 :  5289.027 
#> ---------------------------------------------------
#> Sex 2 
#> Median:  3810.436 
#> Mean:  3867.668 
#> SD:  2237.876 
#> HPD Lower:  -318.6588 
#> HPD Upper:  8465.921 
#> P0:  0.9612 
#> Guaranteed Value with prob 0.9 :  6818.402 
#> ---------------------------------------------------
#> Inferences of posterior chains for Compare 
#> ---------------------------------------------------
#> Sex 1-2 
#> Median:  -1446.215 
#> Mean:  -1438.817 
#> SD:  972.8501 
#> HPD Lower:  -3326.035 
#> HPD Upper:  423.3839 
#> P0:  0.9316 
#> Guaranteed Value with prob 0.9 :  -2652.724 
#> PR with R 0.05 :  0.9316 
#> PS with R 0.05 :  0 
#> ---------------------------------------------------
#> Inferences of posterior chains for Cov 
#> ---------------------------------------------------
#> Cov LW 
#> Median:  18.30793 
#> Mean:  18.25327 
#> SD:  3.431885 
#> HPD Lower:  11.98053 
#> HPD Upper:  25.11083 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  22.70118 
#> ---------------------------------------------------
#> Inferences of posterior chains for RandomVariances 
#> ---------------------------------------------------
#> RandomVariances c 
#> Median:  27500538 
#> Mean:  27059684 
#> SD:  11324375 
#> HPD Lower:  23828.47 
#> HPD Upper:  45080652 
#> ---------------------------------------------------
#> 
#> 
#> 
#> Processing Trait: PFat 
#> ---------------------------------------------------
#>  Model Mean
#> Median:  10.62089 
#> Mean:  10.62267 
#> SD:  0.1378657 
#> HPD Lower:  10.36315 
#> HPD Upper:  10.89314 
#> ---------------------------------------------------
#> ---------------------------------------------------
#>  Residual Variance
#> Median:  7.183413 
#> Mean:  7.258138 
#> SD:  0.7548109 
#> HPD Lower:  5.899888 
#> HPD Upper:  8.732008 
#> ---------------------------------------------------
#> Inferences of posterior chains for treatMeans 
#> ---------------------------------------------------
#> Sex 1 
#> Median:  9.047551 
#> Mean:  9.056359 
#> SD:  0.5279915 
#> HPD Lower:  8.086357 
#> HPD Upper:  10.1636 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  9.728966 
#> ---------------------------------------------------
#> Sex 2 
#> Median:  10.63628 
#> Mean:  10.64981 
#> SD:  0.5344104 
#> HPD Lower:  9.600491 
#> HPD Upper:  11.68683 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  11.31304 
#> ---------------------------------------------------
#> Inferences of posterior chains for Compare 
#> ---------------------------------------------------
#> Sex 1-2 
#> Median:  -1.596074 
#> Mean:  -1.593455 
#> SD:  0.2394848 
#> HPD Lower:  -2.059116 
#> HPD Upper:  -1.129324 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  -1.892489 
#> PR with R 1 :  0.9916 
#> PS with R 1 :  0.0084 
#> ---------------------------------------------------
#> Inferences of posterior chains for Cov 
#> ---------------------------------------------------
#> Cov LW 
#> Median:  0.01821714 
#> Mean:  0.01823961 
#> SD:  0.0008370555 
#> HPD Lower:  0.01663047 
#> HPD Upper:  0.01989438 
#> P0:  1 
#> Guaranteed Value with prob 0.9 :  0.01930539 
#> ---------------------------------------------------
#> Inferences of posterior chains for RandomVariances 
#> ---------------------------------------------------
#> RandomVariances c 
#> Median:  1.055631 
#> Mean:  1.019521 
#> SD:  0.6624487 
#> HPD Lower:  1.898864e-06 
#> HPD Upper:  2.101233 
#> ---------------------------------------------------
```

<img src="man/figures/README-Bayes-1.png" width="100%" /><img src="man/figures/README-Bayes-2.png" width="100%" />
