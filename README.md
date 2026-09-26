# Halfway Splits and Finishing Times in the 2023 Boston Marathon

A simple linear regression study of marathon pacing, prepared for MATH 261A
(Regression Theory) Project 1.

- **Author:** Pujitha Bobbili
- **Date of submission:** September 25, 2026 (Project 1, Version 1)

## Research question

How accurately does a runner's half-marathon split predict their net finishing
time, and does the relationship show that runners pace the two halves of the
race evenly?

Because even pacing implies that finishing time is exactly twice the halfway
split, the slope of the regression has a benchmark value of 2. The analysis
therefore tests the fitted slope against 2 rather than against 0. Fitted to the
26,526 finishers of the 2023 Boston Marathon with a recorded half-marathon
split, the slope is 2.218 (95% CI 2.212 to 2.224), so each extra minute taken to
reach halfway is associated with about 1.22 extra minutes over the second half
rather than the one minute even pacing would require.

## Data source and license

The data are the official results of the 2023 Boston Marathon, held on April 17,
2023. The file `boston_marathon_2023.csv` was obtained from the **SCORE Network
Sports Data Repository** (<https://data.scorenetwork.org>), where it is
published as the dataset "2023 Boston Marathon runners", contributed by Jack
Fay, A. J. Dykstra, and Ivan Ramler (2023) and compiled from the official
results published by the Boston Athletic Association (<https://www.baa.org>).
The dataset page is at
<https://data.scorenetwork.org/running/boston_marathon_2023.html>.

**License.** The SCORE Network repository does not attach a formal open-data
license (such as a Creative Commons license) to this dataset. The repository's
submission policy requires contributors to certify that any data they submit are
publicly shareable and carry no licensing restrictions that would prevent the
repository from sharing them for educational purposes, and the repository
distributes the file publicly on that basis. The data are used here for
non-commercial academic coursework consistent with that policy. The underlying
race results remain the work of the Boston Athletic Association, which is
credited as the original source in the report and in the reference list.

**Redistribution.** No raw or processed data files are stored in this
repository, in line with the project requirements. `R/01-download-data.R`
retrieves the file from the source at run time, and `data/` is listed in
`.gitignore`.

## Use of external resources

External resources, including large language models, were used in preparing
this project. A large language model (Claude) was used to help refine the
research question, draft and revise the prose of the report, write and debug
the R code, build and format the tables and figures, organize the repository,
and proofread the text. The Boston Marathon pacing literature cited in the
report was located through ordinary literature searching and read by the
author; the statistical choices, the interpretation of the results, and the
final text are the author's own, and all model output, quantitative claims, and
citations were checked against the fitted model and the published sources
before submission. No other external tools or collaborators contributed to the
project. Software used in the analysis is cited in the report's reference list.

## Repository structure

```
simple-regression-project/
├── README.md                        This file
├── simple-regression-project.Rproj  RStudio project file
├── run-all.R                        Runs the full pipeline end to end
├── .gitignore                       Excludes data/ and render artifacts
├── R/
│   ├── 01-download-data.R           Downloads the results file into data/raw/
│   ├── 02-prepare-data.R            Cleans and derives variables; writes data/processed/
│   └── 03-fit-models.R              Model-fitting and diagnostic helper functions
├── report/
│   ├── paper.Rmd                    Source of the report
│   ├── paper.pdf                    Rendered report (the submitted document)
│   └── references.bib               BibTeX bibliography
└── data/                            Created at run time; not tracked by git
    ├── raw/                         Downloaded results file
    └── processed/                   Analysis data set (marathon.rds)
```

## Reproducing the analysis

Open `simple-regression-project.Rproj` in RStudio (or set the working directory
to the project root) and run:

```r
source("run-all.R")
```

This downloads the data, builds the analysis data set, and renders
`report/paper.pdf`. The three steps can also be run individually in the order
shown in the structure above.

### Requirements

R (version 4.3.3 was used) with the packages `dplyr`, `readr`, `ggplot2`,
`patchwork`, `knitr`, `rmarkdown`, `bookdown`, `kableExtra`, `sandwich`, and
`lmtest`. Rendering the report to PDF also requires a LaTeX installation, such
as TinyTeX:

```r
install.packages("tinytex")
tinytex::install_tinytex()
```
