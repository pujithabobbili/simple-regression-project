# 01-download-data.R --------------------------------------------------------
# Downloads the 2023 Boston Marathon results file from the SCORE Network
# Sports Data Repository into data/raw/. The raw file is not tracked by git
# (see .gitignore), so this script must be run before R/02-prepare-data.R.
#
# Source: SCORE Network Sports Data Repository, dataset "2023 Boston Marathon
# runners" contributed by Fay, Dykstra, and Ramler (2023). See README.md for
# the full data-source and licensing statement.

raw_dir <- file.path("data", "raw")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

destination <- file.path(raw_dir, "boston_marathon_2023.csv")

# The repository is served from data.scorenetwork.org and mirrored on the
# GitHub repository that builds that site. Both point at the same file; the
# mirror is used when the primary host cannot be reached.
sources <- c(
  "https://data.scorenetwork.org/data/boston_marathon_2023.csv",
  paste0(
    "https://raw.githubusercontent.com/SCOREnetworkorg/",
    "sports-data-repository/main/data/boston_marathon_2023.csv"
  )
)

download_from_first_available <- function(urls, destfile) {
  for (url in urls) {
    ok <- tryCatch(
      {
        utils::download.file(url, destfile, mode = "wb", quiet = TRUE)
        TRUE
      },
      error = function(e) FALSE,
      warning = function(w) FALSE
    )
    if (ok && file.exists(destfile) && file.size(destfile) > 0) {
      message("Downloaded results from: ", url)
      return(invisible(destfile))
    }
  }
  stop("Could not download the results file from any known source.")
}

download_from_first_available(sources, destination)

message("Raw data written to: ", destination)
