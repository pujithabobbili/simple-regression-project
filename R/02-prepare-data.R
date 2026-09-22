# 02-prepare-data.R ---------------------------------------------------------
# Builds the analysis data set from the raw 2023 Boston Marathon results.
# Run R/01-download-data.R first. Output is written to data/processed/ and is
# not tracked by git.
#
# Cleaning rules:
#   * keep finishers with a recorded half-marathon split (the split is the
#     explanatory variable, so runners missing it cannot enter the model);
#   * convert times from seconds to minutes for interpretability;
#   * derive second-half time and the second-to-first half ratio.
# Unusual pacing patterns are retained: a runner who walks the first half or
# collapses in the second is a genuine race outcome, not a recording error,
# and discarding those runners would bias the pacing estimate. Their influence
# on the fit is assessed with regression diagnostics instead.

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})

raw_path <- file.path("data", "raw", "boston_marathon_2023.csv")
if (!file.exists(raw_path)) {
  stop("Raw data not found. Run R/01-download-data.R first.")
}

results_raw <- read_csv(raw_path, show_col_types = FALSE)

marathon <- results_raw %>%
  mutate(
    half_min = half_time_sec / 60,
    finish_min = finish_net_sec / 60,
    gun_min = finish_gun_sec / 60,
    second_half_min = finish_min - half_min,
    split_ratio = second_half_min / half_min,
    sex = factor(gender, levels = c("W", "M"), labels = c("Women", "Men")),
    age_group = factor(age_group)
  ) %>%
  select(
    place_overall, place_gender, sex, age_group,
    half_min, finish_min, gun_min, second_half_min, split_ratio
  )

# Runners missing the half-marathon split cannot be modelled.
n_all <- nrow(marathon)
analysis_data <- marathon %>% filter(!is.na(half_min))
n_dropped <- n_all - nrow(analysis_data)

message(sprintf(
  "Finishers: %d; dropped for missing half split: %d (%.2f%%); analysed: %d",
  n_all, n_dropped, 100 * n_dropped / n_all, nrow(analysis_data)
))

processed_dir <- file.path("data", "processed")
dir.create(processed_dir, recursive = TRUE, showWarnings = FALSE)

# Both the full finisher table and the modelling subset are saved: the former
# is used to describe missingness in the paper, the latter to fit the model.
saveRDS(
  list(all_finishers = marathon, analysis = analysis_data),
  file.path(processed_dir, "marathon.rds")
)

message("Processed data written to: ", file.path(processed_dir, "marathon.rds"))
