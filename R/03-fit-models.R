# 03-fit-models.R -----------------------------------------------------------
# Model fitting and inference helpers for the 2023 Boston Marathon analysis.
# The report sources this file, so the functions here return objects rather
# than printing them. Running the file directly prints a short summary, which
# is convenient when checking results outside the report.

suppressPackageStartupMessages({
  library(dplyr)
  library(sandwich)
  library(lmtest)
})

#' Fit the primary and sensitivity regressions
#'
#' The primary model regresses net finishing time on the half-marathon split,
#' both in minutes. The sensitivity model repeats the fit on the log scale,
#' where the even-pacing benchmark for the slope becomes 1 instead of 2.
fit_marathon_models <- function(data) {
  list(
    primary = lm(finish_min ~ half_min, data = data),
    log_log = lm(log(finish_min) ~ log(half_min), data = data)
  )
}

#' Test a slope against a benchmark value
#'
#' Classical t test of H0: beta1 = `benchmark`. Setting `robust = TRUE` uses
#' heteroskedasticity-consistent (HC1) standard errors instead of the
#' constant-variance standard errors.
test_slope <- function(fit, benchmark, robust = FALSE, level = 0.95) {
  vcov_matrix <- if (robust) sandwich::vcovHC(fit, type = "HC1") else stats::vcov(fit)
  estimate <- stats::coef(fit)[[2]]
  std_error <- sqrt(vcov_matrix[2, 2])
  df_residual <- stats::df.residual(fit)
  t_stat <- (estimate - benchmark) / std_error
  critical <- stats::qt(1 - (1 - level) / 2, df_residual)

  list(
    estimate = estimate,
    std_error = std_error,
    benchmark = benchmark,
    t_statistic = t_stat,
    df = df_residual,
    p_value = 2 * stats::pt(-abs(t_stat), df_residual),
    conf_low = estimate - critical * std_error,
    conf_high = estimate + critical * std_error,
    robust = robust
  )
}

#' Collect the diagnostic quantities reported in the paper
model_diagnostics <- function(fit) {
  augmented <- data.frame(
    fitted = stats::fitted(fit),
    resid = stats::resid(fit),
    std_resid = stats::rstandard(fit),
    hat = stats::hatvalues(fit),
    cooks = stats::cooks.distance(fit)
  )
  summary_fit <- summary(fit)

  list(
    augmented = augmented,
    r_squared = summary_fit$r.squared,
    sigma = summary_fit$sigma,
    n = stats::nobs(fit),
    max_cooks = max(augmented$cooks),
    n_large_cooks = sum(augmented$cooks > 1),
    bp_test = lmtest::bptest(fit)
  )
}

#' Residual standard deviation within equal-sized bins of the predictor
#'
#' Used to show how the spread of residuals changes across the range of the
#' explanatory variable, which is easier to read than a residual plot alone.
residual_spread_by_bin <- function(fit, predictor, n_bins = 10) {
  data.frame(
    predictor = predictor,
    resid = stats::resid(fit)
  ) %>%
    mutate(bin = dplyr::ntile(predictor, n_bins)) %>%
    group_by(bin) %>%
    summarise(
      mean_predictor = mean(predictor),
      resid_sd = stats::sd(resid),
      .groups = "drop"
    )
}

if (sys.nframe() == 0) {
  processed <- readRDS(file.path("data", "processed", "marathon.rds"))
  fits <- fit_marathon_models(processed$analysis)
  print(summary(fits$primary))
  print(test_slope(fits$primary, benchmark = 2))
  print(test_slope(fits$primary, benchmark = 2, robust = TRUE))
  print(test_slope(fits$log_log, benchmark = 1))
}
