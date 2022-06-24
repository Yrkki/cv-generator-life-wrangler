# Scrape wrangling ETL job for the Store SSOT storage solution
# of the LifeSpan ecosystem

# Installation
if (!require(tidyverse)) {
    install.packages("tidyverse", repos = "http://cran.us.r-project.org")
}

# Configuration
options("encoding" = "UTF-8")
library(tidyverse)
library(readxl)

# Locations
app_data <- Sys.getenv("USERPROFILE")
app_data <- paste0(app_data, "\\")
in_path <- paste0(app_data, "Dropbox\\Career\\CVs\\")
out_path <- paste0(app_data, "source\\repos\\cv-generator\\")
path <- paste0(in_path, "CV.xlsx")

# Extract data
services <- read_excel(path = path, sheet = "LifeSpan", range = "V1:AH29")
services <- services %>% slice(2:n())
projects <- services$Project
contents <- services$README.md

# Process all projects with their respective content
items <- mapply(function(project, content) {
    # file <- paste0(out_path, "out\\", project, ".README.md") # nolint
    file <- paste0(out_path, project, "\\README.md")
    message("Generating ", file, " file...")

    content <- str_replace_all(content, "\\r", "")
    write(content, file)
}, projects, contents, SIMPLIFY = FALSE)

message("Done")
