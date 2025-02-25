library(testthat)
library(pROC)
library(glue)

test_that("simulate_single_roc returns an ROC object when n_simulations == 1", {
  set.seed(2794)
  result <- simulate_single_roc(n_simulations = 1)

  expect_s3_class(result, "roc")  # Check if result is an ROC object
  expect_true(!is.null(result$auc))  # Ensure AUC is calculated
})


