# 03-fit-models.R -----------------------------------------------------------
# Model fitting and interval helpers for the 2023 Boston Marathon analysis.
# The report sources this file, so the functions here return objects rather
# than printing them. Running the file directly prints a short summary, which
# is convenient when checking results outside the report.

suppressPackageStartupMessages({
  library(dplyr)
  library(sandwich)
})

#' Fit the simple linear regression of finishing time on halfway split
#'
#' Both times are in minutes, so the slope can be compared directly with 2,
#' the value implied by running the two halves in equal time.
fit_marathon_model <- function(data) {
  lm(finish_min ~ half_min, data = data)
}

#' Confidence interval for the slope
#'
#' Uses heteroskedasticity-consistent (HC1) standard errors by default,
#' because the residual spread grows with the halfway split.
slope_interval <- function(fit, robust = TRUE, level = 0.95) {
  vcov_matrix <- if (robust) sandwich::vcovHC(fit, type = "HC1") else stats::vcov(fit)
  std_error <- sqrt(diag(vcov_matrix))
  critical <- stats::qt(1 - (1 - level) / 2, stats::df.residual(fit))

  data.frame(
    term = names(stats::coef(fit)),
    estimate = unname(stats::coef(fit)),
    std_error = unname(std_error),
    conf_low = unname(stats::coef(fit) - critical * std_error),
    conf_high = unname(stats::coef(fit) + critical * std_error)
  )
}

#' Collect the diagnostic quantities reported in the paper
model_diagnostics <- function(fit) {
  augmented <- data.frame(
    fitted = stats::fitted(fit),
    resid = stats::resid(fit),
    cooks = stats::cooks.distance(fit)
  )

  list(
    augmented = augmented,
    sigma = summary(fit)$sigma,
    max_cooks = max(augmented$cooks)
  )
}

#' Residual spread and interval coverage within tenths of the halfway split
#'
#' For each decile of the split, reports the residual standard deviation and
#' the share of runners whose finishing time falls inside the usual
#' constant-variance 95% prediction interval.
spread_by_decile <- function(fit, data, n_bins = 10) {
  usual <- suppressWarnings(stats::predict(fit, interval = "prediction"))

  data.frame(
    split = data$half_min,
    resid = stats::resid(fit),
    inside = data$finish_min >= usual[, "lwr"] & data$finish_min <= usual[, "upr"]
  ) %>%
    mutate(decile = dplyr::ntile(split, n_bins)) %>%
    group_by(decile) %>%
    summarise(
      mean_split = mean(split),
      resid_sd = stats::sd(resid),
      coverage = 100 * mean(inside),
      .groups = "drop"
    )
}

#' Prediction interval that allows the spread to change with the split
#'
#' Adds the 2.5th and 97.5th percentiles of the residuals of runners whose
#' split lies within `window` minutes of `x0` to the fitted value at `x0`.
#' Because it uses nearby runners only, the interval widens where the spread
#' is larger and can be longer on the slow side than on the fast side.
local_prediction_interval <- function(fit, data, x0, window = 5, level = 0.95) {
  nearby <- abs(data$half_min - x0) <= window
  limits <- stats::quantile(
    stats::resid(fit)[nearby], c((1 - level) / 2, 1 - (1 - level) / 2),
    names = FALSE
  )
  centre <- unname(stats::predict(fit, newdata = data.frame(half_min = x0)))

  data.frame(
    half_min = x0,
    fit = centre,
    lwr = centre + limits[1],
    upr = centre + limits[2],
    n_nearby = sum(nearby)
  )
}

if (sys.nframe() == 0) {
  processed <- readRDS(file.path("data", "processed", "marathon.rds"))
  fit <- fit_marathon_model(processed$analysis)
  print(summary(fit))
  print(slope_interval(fit))
  print(spread_by_decile(fit, processed$analysis))
  print(local_prediction_interval(fit, processed$analysis, x0 = 105))
}
