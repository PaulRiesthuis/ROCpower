#' Simulate and Analyze partial ROC/AUC for Two Groups
#' @name simulate_two_partial_roc

# Set package-wide seed for reproducibility
set.seed(2794)

#' This function simulates partial ROC/AUC data for two groups, performs multiple simulations if required,
#' calculates AUC confidence intervals, and conducts statistical tests on AUC differences.
#'
#' @param mean_signal_g1 Mean of the signal distribution for Group 1.
#' @param mean_signal_g2 Mean of the signal distribution for Group 2.
#' @param mean_noise_g1 Mean of the noise distribution for Group 1.
#' @param mean_noise_g2 Mean of the noise distribution for Group 2.
#' @param sd_signal_g1 Standard deviation of the signal distribution for Group 1.
#' @param sd_signal_g2 Standard deviation of the signal distribution for Group 2.
#' @param sd_noise_g1 Standard deviation of the noise distribution for Group 1.
#' @param sd_noise_g2 Standard deviation of the noise distribution for Group 2.
#' @param n_g1 Number of participants in Group 1.
#' @param n_g2 Number of participants in Group 2.
#' @param n_studied Number of studied items per participant.
#' @param n_new Number of new items per participant.
#' @param n_simulations Number of simulations.
#' @param SESOI Smallest effect size of interest for power calculations.
#' @param paired Logical; whether to simulate paired data.
#' @param rho Correlation between repeated measures in the paired case.
#' @param pauc Partial area under the curve of interest
#' @param seed Random seed for reproducibility.
#' @import pROC MASS
#' @return A power analysis data frame summarizing results across simulations.
#' @export
simulate_two_partial_roc <- function(mean_signal_g1 = 1, mean_signal_g2 = 0.58,
                             mean_noise_g1 = 0, mean_noise_g2 = 0,
                             sd_signal_g1 = 1, sd_signal_g2 = 1,
                             sd_noise_g1 = 1, sd_noise_g2 = 1,
                             n_g1 = 100, n_g2 = 100,
                             n_studied = 5, n_new = 5,
                             pauc = c(.65,.33),
                             n_simulations = 1000, SESOI = 0.05,
                             paired = FALSE, rho = 0.5, seed = 2794) {

  set.seed(seed) # Corrected set.seed usage

  simulate_roc <- function() {
    if (!paired) {
      # Independent groups case
      n_sig_g1 <- n_g1 * n_studied
      n_noise_g1 <- n_g1 * n_new
      n_sig_g2 <- n_g2 * n_studied
      n_noise_g2 <- n_g2 * n_new

      signal_g1 <- rnorm(n_sig_g1, mean_signal_g1, sd_signal_g1)
      noise_g1 <- rnorm(n_noise_g1, mean_noise_g1, sd_noise_g1)
      signal_g2 <- rnorm(n_sig_g2, mean_signal_g2, sd_signal_g2)
      noise_g2 <- rnorm(n_noise_g2, mean_noise_g2, sd_noise_g2)

    } else {
      # Paired case with correlation
      cov_matrix_signal <- matrix(c(sd_signal_g1^2, rho * sd_signal_g1 * sd_signal_g2,
                                    rho * sd_signal_g1 * sd_signal_g2, sd_signal_g2^2), nrow = 2)
      cov_matrix_noise <- matrix(c(sd_noise_g1^2, rho * sd_noise_g1 * sd_noise_g2,
                                   rho * sd_noise_g1 * sd_noise_g2, sd_noise_g2^2), nrow = 2)

      signal_data <- MASS::mvrnorm(n_g1 * n_studied, mu = c(mean_signal_g1, mean_signal_g2), Sigma = cov_matrix_signal)
      noise_data <- MASS::mvrnorm(n_g1 * n_new, mu = c(mean_noise_g1, mean_noise_g2), Sigma = cov_matrix_noise)

      signal_g1 <- signal_data[, 1]
      signal_g2 <- signal_data[, 2]
      noise_g1 <- noise_data[, 1]
      noise_g2 <- noise_data[, 2]
    }

    ratings_g1 <- c(signal_g1, noise_g1)
    ratings_g2 <- c(signal_g2, noise_g2)
    labels <- c(rep(1, length(signal_g1)), rep(0, length(noise_g1)))

    # Define 6-point scale cutoffs
    cutoffs_g1 <- quantile(ratings_g1, probs = seq(0, 1, length.out = 7))
    cutoffs_g2 <- quantile(ratings_g2, probs = seq(0, 1, length.out = 7))

    ratings_g1 <- as.numeric(cut(ratings_g1, breaks = cutoffs_g1, labels = 1:6, include.lowest = TRUE))
    ratings_g2 <- as.numeric(cut(ratings_g2, breaks = cutoffs_g2, labels = 1:6, include.lowest = TRUE))

    roc_g1 <- pROC::roc(labels, ratings_g1, direction = "<", partial.auc = pauc)
    roc_g2 <- pROC::roc(labels, ratings_g2, direction = "<", partial.auc = pauc)

    return(list(roc_g1 = roc_g1, roc_g2 = roc_g2))
  }

  # Simulation loop
  roc_g1_list <- vector("list", n_simulations)
  roc_g2_list <- vector("list", n_simulations)

  for (i in 1:n_simulations) {
    rocs <- simulate_roc()
    roc_g1_list[[i]] <- rocs$roc_g1
    roc_g2_list[[i]] <- rocs$roc_g2
  }

  # ROC Analysis function
  # Function to collect AUCs, calculate CIs, and perform roc.test
  perform_roc_tests <- function(roc_g1_list, roc_g2_list) {
    n_simulations <- length(roc_g1_list)

    p_values <- numeric(n_simulations)
    auc_exp <- numeric(n_simulations)
    auc_control <- numeric(n_simulations)
    conf_lowexp95 <- numeric(n_simulations)
    conf_highexp95 <- numeric(n_simulations)
    conf_lowcontrol95 <- numeric(n_simulations)
    conf_highcontrol95 <- numeric(n_simulations)
    Diff <- numeric(n_simulations)
    Diff_conf_low95 <- numeric(n_simulations)
    Diff_conf_high95 <- numeric(n_simulations)
    Diff_conf_low90 <- numeric(n_simulations)
    Diff_conf_high90 <- numeric(n_simulations)
    d <- numeric(n_simulations)

    # Perform roc.test and calculate CIs for each dataset
    for (i in 1:n_simulations) {
      # Perform roc.test for each simulation
      test_result <- roc.test(roc_g1_list[[i]], roc_g2_list[[i]], paired = paired)
      p_values[i] <- test_result$p.value

      # Confidence intervals for each group
      CI_exp95 <- ci(roc_g1_list[[i]], conf.level = 0.95)
      CI_control95 <- ci(roc_g2_list[[i]], conf.level = 0.95)

      # AUC and confidence interval extraction
      auc_exp[i] <- CI_exp95[2]
      auc_control[i] <- CI_control95[2]
      conf_lowexp95[i] <- CI_exp95[1]
      conf_highexp95[i] <- CI_exp95[3]
      conf_lowcontrol95[i] <- CI_control95[1]
      conf_highcontrol95[i] <- CI_control95[3]

      # Difference in AUC
      Diff[i] <- auc_exp[i] - auc_control[i]

      # 95% confidence interval for the difference
      Diff_conf_low95[i] <- Diff[i] - (1.96 * (Diff[i] / test_result$statistic))
      Diff_conf_high95[i] <- Diff[i] + (1.96 * (Diff[i] / test_result$statistic))

      # 90% confidence interval for the difference
      Diff_conf_low90[i] <- Diff[i] - (1.645 * (Diff[i] / test_result$statistic))
      Diff_conf_high90[i] <- Diff[i] + (1.645 * (Diff[i] / test_result$statistic))

      # Store test statistic
      d[i] <- test_result$statistic
    }

    # Return p-values, AUCs, CIs, and differences
    return(list(
      p_values = p_values,
      auc_exp = auc_exp, auc_control = auc_control,
      conf_lowexp95 = conf_lowexp95, conf_highexp95 = conf_highexp95,
      conf_lowcontrol95 = conf_lowcontrol95, conf_highcontrol95 = conf_highcontrol95,
      Diff = Diff,
      Diff_conf_low95 = Diff_conf_low95, Diff_conf_high95 = Diff_conf_high95,
      Diff_conf_low90 = Diff_conf_low90, Diff_conf_high90 = Diff_conf_high90,
      d = d
    ))
  }

  # Run roc.test on all 1000 simulations
  results <- perform_roc_tests(roc_g1_list, roc_g2_list)
  # Power table
  power_table <- data.frame(
    "NHST" = mean(results$Diff_conf_low95 > 0 | results$Diff_conf_high95 < 0, na.rm=T),
    "ET" = mean(results$Diff_conf_low90 > -SESOI & results$Diff_conf_high90 < SESOI, na.rm=T),
    "ME" = mean(results$Diff_conf_low95 > SESOI | results$Diff_conf_high95 < -SESOI, na.rm=T))

  # Generate summary text
  summary_text <- glue("
The analysis yielded the following results:

1. **NHST (Null Hypothesis Significance Testing):** {round(power_table$NHST * 100, 2)}% of simulations rejected the null hypothesis at the 0.05 level.
2. **ET (Equivalence Testing):** {round(power_table$ET * 100, 2)}% of simulations demonstrated equivalence within the specified SESOI.
3. **MET (Minimum-Effects Testing):** {round(power_table$ME * 100, 2)}% of simulations showed significant minimum effects in either direction relative to the SESOI.

### **Power Analysis Report**
Based on a simulation-based power analysis (Riesthuis et al., 2025), using the following parameters:

#### **Group 1**
- Mean Signal: {mean_signal_g1}
- Signal SD: {sd_signal_g1}
- Mean Noise: {mean_noise_g1}
- Noise SD: {sd_noise_g1}

#### **Group 2**
- Mean Signal: {mean_signal_g2}
- Signal SD: {sd_signal_g2}
- Mean Noise: {mean_noise_g2}
- Noise SD: {sd_noise_g2}

#### **Study Parameters**
- SESOI: {SESOI}
- pAUC: {pauc}
- paired = {paired}
- Sample Size (n): {n_g1}
- Number of Studied Items: {n_studied}
- Number of New Items: {n_new}
- Correlation: {rho}

#### **Simulation Parameters**
- Number of Simulations: {n_simulations}
- Set Seed: {seed}
")


  return(summary = cat(summary_text))
}

