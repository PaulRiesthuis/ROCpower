% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/twopartialroc.R
\name{simulate_two_partial_roc}
\alias{simulate_two_partial_roc}
\title{Simulate and Analyze partial ROC/AUC for Two Groups}
\usage{
simulate_two_partial_roc(
  mean_signal_g1 = 1,
  mean_signal_g2 = 0.58,
  mean_noise_g1 = 0,
  mean_noise_g2 = 0,
  sd_signal_g1 = 1,
  sd_signal_g2 = 1,
  sd_noise_g1 = 1,
  sd_noise_g2 = 1,
  n_g1 = 100,
  n_g2 = 100,
  n_studied = 5,
  n_new = 5,
  pauc = c(0.65, 0.33),
  n_simulations = 1000,
  SESOI = 0.05,
  paired = FALSE,
  rho = 0.5,
  seed = 2794
)
}
\arguments{
\item{mean_signal_g1}{Mean of the signal distribution for Group 1.}

\item{mean_signal_g2}{Mean of the signal distribution for Group 2.}

\item{mean_noise_g1}{Mean of the noise distribution for Group 1.}

\item{mean_noise_g2}{Mean of the noise distribution for Group 2.}

\item{sd_signal_g1}{Standard deviation of the signal distribution for Group 1.}

\item{sd_signal_g2}{Standard deviation of the signal distribution for Group 2.}

\item{sd_noise_g1}{Standard deviation of the noise distribution for Group 1.}

\item{sd_noise_g2}{Standard deviation of the noise distribution for Group 2.}

\item{n_g1}{Number of participants in Group 1.}

\item{n_g2}{Number of participants in Group 2.}

\item{n_studied}{Number of studied items per participant.}

\item{n_new}{Number of new items per participant.}

\item{pauc}{Partial area under the curve of interest.}

\item{n_simulations}{Number of simulations.}

\item{SESOI}{Smallest effect size of interest for power calculations.}

\item{paired}{Logical; whether to simulate paired data.}

\item{rho}{Correlation between repeated measures in the paired case.}

\item{seed}{Random seed for reproducibility.}
}
\value{
A power analysis data frame summarizing results across simulations.
}
\description{
Simulate and Analyze partial ROC/AUC for Two Groups

This function simulates partial ROC/AUC data for two groups, performs multiple simulations if required,
calculates AUC confidence intervals, and conducts statistical tests on AUC differences.
}
\examples{
# Run a basic simulation with default parameters
simulate_two_partial_roc()

# Run a simulation with different signal means
simulate_two_partial_roc(mean_signal_g1 = 1.2, mean_signal_g2 = 0.6)

# Run a simulation with a different partial AUC range
simulate_two_partial_roc(pauc = c(0.7, 0.4))

# Run a paired simulation with correlation
simulate_two_partial_roc(paired = TRUE, rho = 0.4)

# Run a simulation for parameters of interest
simulate_two_partial_roc <- function(mean_signal_g1 = 1, mean_signal_g2 = 0.58,
mean_noise_g1 = 0, mean_noise_g2 = 0,
sd_signal_g1 = 1, sd_signal_g2 = 1,
sd_noise_g1 = 1, sd_noise_g2 = 1,
n_g1 = 100, n_g2 = 100,
n_studied = 5, n_new = 5,
pauc = c(.65,.33),
n_simulations = 1000, SESOI = 0.05,
paired = FALSE, rho = 0.5, seed = 2794)
}
