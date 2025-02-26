#' ROC Simulation Package
#'
#' This package provides functions for simulating signal detection data,
#' computing ROC curves, and performing power analyses.
#' @name simulate_single_roc
#'
# Set package-wide seed for reproducibility
set.seed(2794)

#' Simulate and Analyze single group ROC/AUC Data
#'
#' This function simulates single group ROC/AUC data, performs multiple simulations if required, and computes confidence intervals for AUC along with power estimates.
#'
#' @param mean_signal Mean of the signal distribution.
#' @param mean_noise Mean of the noise distribution.
#' @param sd_signal Standard deviation of the signal distribution.
#' @param sd_noise Standard deviation of the noise distribution.
#' @param n_g Number of participants per group.
#' @param n_studied Number of studied items.
#' @param n_new Number of new items.
#' @param n_simulations Number of simulations. If greater than 1, multiple ROC curves are generated.
#' @param SESOI Smallest effect size of interest for power calculations.
#' @param seed Random seed for reproducibility.
#' @import pROC glue
#' @return If `n_simulations == 1`, returns a single ROC object. If `n_simulations > 1`, returns a power analysis data frame.
#' @export
#'
#' @examples
#' # Run a basic simulation with default parameters
#' simulate_single_roc()
#'
#' # Run a simulation with a different signal mean
#' simulate_single_roc(mean_signal = 1.2)
#' # Run a simulation for parameters of interest
#' simulate_single_roc(mean_signal = 0.34, mean_noise = 0,
#' sd_signal = 1, sd_noise = 1,
#' n_g = 100, n_studied = 5, n_new = 5,
#' n_simulations = 1000, SESOI = 0.55, seed = 2794)
simulate_single_roc <- function(mean_signal = 0.34, mean_noise = 0,
                                sd_signal = 1, sd_noise = 1,
                                n_g = 100, n_studied = 5, n_new = 5,
                                n_simulations = 1000, SESOI = 0.55, seed = 2794) {
set.seed(seed)
  simulate_roc <- function() {
    n_sig_g <- n_g * n_studied
    n_noise_g <- n_g * n_new

    signal_g <- rnorm(n_sig_g, mean_signal, sd_signal)
    noise_g <- rnorm(n_noise_g, mean_noise, sd_noise)

    ratings_g <- c(signal_g, noise_g)
    labels_g <- c(rep(1, n_sig_g), rep(0, n_noise_g))

    cutoffs_g <- quantile(ratings_g, probs = seq(0, 1, length.out = 7))
    ratings_g <- cut(ratings_g, breaks = cutoffs_g, labels = 1:6, include.lowest = TRUE)

    roc_g <- pROC::roc(labels_g, as.numeric(ratings_g))
    return(roc_g)
  }

  if (n_simulations == 1) {
    return(simulate_roc())
  } else {
    # Simulation of datasets
    roc_g1_list <- vector("list", n_simulations)

    # Simulate datasets and store ROC results
    for (i in 1:n_simulations) {
      roc_g1_list[[i]] <- simulate_roc()
    }

    # Function to collect AUCs, calculate CIs, and perform power analysis
    perform_roc_tests <- function(roc_g1_list) {
      n_simulations <- length(roc_g1_list)
      auc_control <- numeric(n_simulations)
      conf_lowcontrol95 <- numeric(n_simulations)
      conf_highcontrol95 <- numeric(n_simulations)
      conf_lowcontrol90 <- numeric(n_simulations)
      conf_highcontrol90 <- numeric(n_simulations)

      # Perform roc.test and calculate CIs for each dataset
      for (i in 1:n_simulations) {
        CI_control95 <- ci(roc_g1_list[[i]], conf.level = 0.95)
        CI_control90 <- ci(roc_g1_list[[i]], conf.level = 0.90)

        # AUC and confidence interval extraction
        auc_control[i] <- CI_control95[2]
        conf_lowcontrol95[i] <- CI_control95[1]
        conf_highcontrol95[i] <- CI_control95[3]
        conf_lowcontrol90[i] <- CI_control90[1]
        conf_highcontrol90[i] <- CI_control90[3]
      }

      # Create power table
      power_table <- data.frame(
        "NHST" = mean(conf_lowcontrol95 > 0.5 | conf_highcontrol95 < 0.5, na.rm = TRUE),
        "ET" = mean(conf_lowcontrol90 > -SESOI & conf_highcontrol90 < SESOI, na.rm = TRUE),
        "ME" = mean(conf_lowcontrol95 > SESOI | conf_highcontrol95 < -SESOI, na.rm = TRUE)
      )

      # Generate summary text
      summary_text <- glue("
The analysis yielded the following results:

1. **NHST (Null Hypothesis Significance Testing):** {round(power_table$NHST * 100, 2)}% of simulations rejected the null hypothesis at the 0.05 level.
2. **ET (Equivalence Testing):** {round(power_table$ET * 100, 2)}% of simulations demonstrated equivalence within the specified SESOI.
3. **MET (Minimum-Effects Testing):** {round(power_table$ME * 100, 2)}% of simulations showed significant minimum effects in either direction relative to the SESOI.

### **Power Analysis Report**
Based on a simulation-based power analysis (Riesthuis et al., 2025), using the following parameters:

#### **Group 1**
- Mean Signal: {mean_signal}
- Signal SD: {sd_signal}
- Mean Noise: {mean_noise}
- Noise SD: {sd_noise}

#### **Study Parameters**
- SESOI: {SESOI}
- Sample Size (n): {n_g}
- Number of Studied Items: {n_studied}
- Number of New Items: {n_new}

#### **Simulation Parameters**
- Number of Simulations: {n_simulations}
- Set Seed: {seed}
")

      return(summary = cat(summary_text))
    }
    # Run power analysis
    return(perform_roc_tests(roc_g1_list))
  }
}
