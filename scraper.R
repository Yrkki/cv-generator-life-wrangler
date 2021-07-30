# ETL job for the LifeSpan Life Store SSOT provisioning solution for use with the CV Generator

# Configuration
options("encoding" = "UTF-8")
library(tidyverse)
library(readxl)
library(jsonlite)

# Locations
in_path <- "C:\\Users\\Jorich\\Dropbox\\Career\\CVs\\"
out_path <- "C:\\Users\\Jorich\\source\\repos\\cv-generator\\cv-generator-life-store\\public\\json\\"
path <- paste0(in_path, "CV.xlsx")

# Extract data geometry
geometry <- read_excel(path = path, sheet = "Geometry", range = "A1:H9")
geometry

# Prepare parameters
sheets <- geometry$sheet_in
ranges <- geometry$reference
files <- geometry$file_out
row_removes <- geometry$row_remove

# Apply extractor function to all sheets in geometry, with parameters
xl_list <- mapply(function(sheet, range, file, row_remove) {
  xl_sheet <- read_excel(path = path, sheet = sheet, range = range)
  if (!is.na(row_remove)) {
    xl_sheet <- xl_sheet[-row_remove,]
  }
  # names(xl_sheet)
  # head(xl_sheet[1])
  # # data.frame(xl_sheet)
  # xl_sheet %>% knitr::kable()
  json <- jsonlite::toJSON(xl_sheet, pretty = TRUE, Date = "ISO8601")
  json <- str_replace_all(json, "\\\\r\\\\n", "\\\\n")
  # json <- trimws(json)
  # json
  write(json, paste0(out_path, file, ".json"))
  xl_sheet
}, sheets, ranges, files, row_removes, SIMPLIFY = FALSE)
xl_list