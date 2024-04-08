
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
b·LW + Rand(c) + e To facilitate this analysis, we will employ the
CreateParam, Bunny and Bayes functions. This pipeline will go trough the
process of running general linear models, generating posterior
distributions, and computing inferences.

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

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
