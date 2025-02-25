
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ROCpower

<!-- badges: start -->
<!-- badges: end -->

The goal of ROCpower is to examine the sample sizes required to conduct
the NHST, Minimum-effect tests, and equivalence tests for Receiver
Operating Characteristic curves

## Installation

You can install the development version of ROCpower like so:

``` r
install_github("PaulRiesthuis/ROCpower")
```

## Example single ROC curve

To run a power analsysis for a single ROC curve

``` r
library(ROCpower)
## basic example code. Adjust the means and sds to get the ROC/AUC of interest.
simulate_single_roc <- function(mean_signal = 0.34, mean_noise = 0,
                                sd_signal = 1, sd_noise = 1,
                                n_g = 100, n_studied = 5, n_new = 5,
                                n_simulations = 1000, SESOI = 0.55, seed = 2794)
simulate_single_roc
```

## Example power analysis for difference between ROC curves

To run a power analysis for difference between ROC curves

``` r
library(ROCpower)
## basic example code. Adjust the means, sds, sample sizes for each group, and the correlation to get the ROC/AUC of interest.
simulate_two_roc <- function(mean_signal_g1 = 1, mean_signal_g2 = 0.58,
                             mean_noise_g1 = 0, mean_noise_g2 = 0,
                             sd_signal_g1 = 1, sd_signal_g2 = 1,
                             sd_noise_g1 = 1, sd_noise_g2 = 1,
                             n_g1 = 100, n_g2 = 100,
                             n_studied = 5, n_new = 5,
                             n_simulations = 1000, SESOI = 0.05,
                             paired = FALSE, rho = 0.5, seed = 2794)
  
simulate_two_roc
```
