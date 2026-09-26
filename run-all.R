# run-all.R -----------------------------------------------------------------
# Runs the analysis end to end: download the results file, build the analysis
# data set, then render the report. Run from the project root.

source(file.path("R", "01-download-data.R"))
source(file.path("R", "02-prepare-data.R"))

system2("quarto", c("render", file.path("report", "paper.qmd")))
