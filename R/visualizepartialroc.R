#' Simulate and Plot Partial ROC Curves for Two Groups
#'
#' This function simulates partial ROC data for two groups, generates confidence ratings,
#' computes ROC curves, and returns the plots with their AUC.
#'
#' @param mean_signal_g1 Mean of the signal distribution for Group 1.
#' @param mean_signal_g2 Mean of the signal distribution for Group 2.
#' @param n_studied Number of studied items per participant.
#' @param n_new Number of new items per participant.
#' @param n_g1 Number of participants (default = 10000 for stable AUC).
#' @param sd_signal_g1 Standard deviation of the signal for Group 1.
#' @param sd_signal_g2 Standard deviation of the signal for Group 2.
#' @param sd_noise_g1 Standard deviation of the noise for Group 1.
#' @param sd_noise_g2 Standard deviation of the noise for Group 2.
#' @param mean_noise_g1 Mean of the noise for Group 1.
#' @param mean_noise_g2 Mean of the noise for Group 2.
#' @param rho Correlation between the two groups (default = 0).
#' @param seed Random seed for reproducibility.
#'
#' @import MASS pROC ggplot2
#' @return A list containing:
#'   - `roc_g1`: ROC object for Group 1
#'   - `roc_g2`: ROC object for Group 2
#'   - `plot_g1`: ROC plot for Group 1
#'   - `plot_g2`: ROC plot for Group 2
#'
#' @export
#'
#' @examples
#' # Get partial ROC curves and AUCs for default parameters
#' result <- visualize_partial_roc()
#' # To get partial ROC curves and AUC for single group use group 1 statistics
#'
#' Visualize partial ROC curves and AUC for parameters of interest
#' visualize_partial_roc(mean_signal_g1 = 1, mean_signal_g2 = 0.58,
#' n_studied = 5, n_new = 5,
#' n_g1 = 10000, # Is high to get precise estimate of ROC curve and AUC
#' sd_signal_g1 = 1, sd_signal_g2 = 1,
#' sd_noise_g1 = 1, sd_noise_g2 = 1,
#' mean_noise_g1 = 0, mean_noise_g2 = 0,
#' pauc = c(.63,.50),
#' rho = 0, seed = 2794)
visualize_partial_roc <- function(mean_signal_g1 = 1, mean_signal_g2 = 0.58,
                               n_studied = 5, n_new = 5,
                               n_g1 = 10000,
                               sd_signal_g1 = 1, sd_signal_g2 = 1,
                               sd_noise_g1 = 1, sd_noise_g2 = 1,
                               mean_noise_g1 = 0, mean_noise_g2 = 0,
                               pauc = c(.63,.50),
                               rho = 0, seed = 2794) {

  set.seed(seed)

  # Covariance matrices for correlated signal and noise
  cov_matrix_signal <- matrix(c(sd_signal_g1^2, rho * sd_signal_g1 * sd_signal_g2,
                                rho * sd_signal_g1 * sd_signal_g2, sd_signal_g2^2), nrow = 2)
  cov_matrix_noise <- matrix(c(sd_noise_g1^2, rho * sd_noise_g1 * sd_noise_g2,
                               rho * sd_noise_g1 * sd_noise_g2, sd_noise_g2^2), nrow = 2)

  # Generate correlated signal and noise distributions
  signal_data <- MASS::mvrnorm(n_g1 * n_studied, mu = c(mean_signal_g1, mean_signal_g2), Sigma = cov_matrix_signal)
  noise_data <- MASS::mvrnorm(n_g1 * n_new, mu = c(mean_noise_g1, mean_noise_g2), Sigma = cov_matrix_noise)

  # Combine signal and noise into ratings
  ratings_g1 <- c(signal_data[, 1], noise_data[, 1])
  ratings_g2 <- c(signal_data[, 2], noise_data[, 2])

  # Define labels (1 = signal, 0 = noise)
  labels <- c(rep(1, n_g1 * n_studied), rep(0, n_g1 * n_new))

  # Define 6-point rating scale cutoffs
  cutoffs_g1 <- quantile(ratings_g1, probs = seq(0, 1, length.out = 7))
  cutoffs_g2 <- quantile(ratings_g2, probs = seq(0, 1, length.out = 7))

  # Assign confidence ratings
  ratings_g1 <- as.numeric(cut(ratings_g1, breaks = cutoffs_g1, labels = 1:6, include.lowest = TRUE))
  ratings_g2 <- as.numeric(cut(ratings_g2, breaks = cutoffs_g2, labels = 1:6, include.lowest = TRUE))

  # Compute ROC curves
  roc_g1 <- pROC::roc(labels, ratings_g1, direction = "<", partial.auc = pauc)
  roc_g2 <- pROC::roc(labels, ratings_g2, direction = "<", partial.auc = pauc)


  # Plot the ROC curve
  par(pty="s")
  plot(roc_g1,
       col = "blue",
       main = "ROC curves",
       legacy.axes=TRUE,
       print.auc = TRUE,
       print.auc.y = .40,
       xlab="False Positive Rate",
       ylab="True Postive Rate",
       auc.polygon=TRUE)
  plot(roc_g2,
       col= "red",
       add=T,
       legacy.axes=TRUE,
       print.auc = TRUE,
       print.auc.y = .30,
       xlab="False Positive Rate",
       ylab="True Postive Rate",
       auc.polygon=TRUE)
  legend("bottomright", legend=c("Group1", "Group2"),
         col=c("Blue","red"), lwd=2)

  return(list(roc_g1 = roc_g1, roc_g2 = roc_g2))
}
