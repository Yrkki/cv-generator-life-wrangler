# ETL job for the LifeSpan℠. Life Store SSOT provisioning solution
# for use with the CV Generator

# Report on environment
R.Version()$version.string

# Installation
if (!require(tidyverse)) {
  install.packages("tidyverse", repos = "http://cran.us.r-project.org")
}

# Configuration
options("encoding" = "UTF-8")
library(tidyverse)
library(readxl)
library(jsonlite)

# Locations
app_data <- Sys.getenv("USERPROFILE")
app_data <- paste0(app_data, "\\")
in_path <- paste0(app_data, "Dropbox\\Career\\CVs\\")
out_path <- paste0(
  app_data,
  "source\\repos\\cv-generator\\cv-generator-life-store\\public\\json\\"
)
path <- paste0(in_path, "CV.xlsx")

# Extract data geometry
geometry <- read_excel(path = path, sheet = "Geometry", range = "A1:H9")
geometry

# Prepare parameters
sheets <- geometry$sheet_in
ranges <- geometry$reference
files <- geometry$file_out
row_removes <- geometry$row_remove

# date type checker
is_date <- function(x) inherits(x, c("Date", "POSIXt"))

# date formatter
date_formatter <- function(d) as.numeric(d) / 3600 / 24 + 25569

# Apply extractor function to all sheets in geometry, with parameters
xl_list <- mapply(function(sheet, range, file, row_remove) {
  xl_sheet <- read_excel(path = path, sheet = sheet, range = range)
  if (!is.na(row_remove)) {
    xl_sheet <- xl_sheet[-row_remove, ]
  }
  # names(xl_sheet) # nolint
  # head(xl_sheet[1]) # nolint
  # # data.frame(xl_sheet) # nolint
  # xl_sheet %>% knitr::kable() # nolint
  xl_sheet <- xl_sheet %>% mutate_if(is_date, date_formatter)
  json <- jsonlite::toJSON(xl_sheet, pretty = TRUE, Date = "ISO8601")
  json <- str_replace_all(json, "\\\\r\\\\n", "\\\\n")
  # json <- trimws(json) # nolint
  # json # nolint
  write(json, paste0(out_path, file, ".json"))
  xl_sheet
}, sheets, ranges, files, row_removes, SIMPLIFY = FALSE)
xl_list
