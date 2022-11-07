library('SDGupdater')

packages <- c('tidyr', 'dplyr', 'stringr',
              'openxlsx', 'janitor', 
              'ggplot2', 'DT', 'pander')

install_absent_packages(packages)

library(tidyr)
library(dplyr)
library(stringr)
library(openxlsx)
library(janitor)
library(ggplot2) # for figures for QMI

# run scripts (create outputs) -------------------------------------------------
source('14-1-1b_functions.R')
source('example_config.R') # change to 'config.R' for real run
source('14-1-1b_update.R')

# create an output file if one does not already exist --------------------------
existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}

# create elements we will use to name files ------------------------------------
today <- Sys.Date()

publication_filename <- paste0(today, "_sdg-14-1-1b-plastic-beach-litter.xlsx")
csv_filename <- paste0(today, "_14_1_1b.csv")
qa_filename <- paste0(today, "_14_1_1b_checks.html") 

# save files and print messages ------------------------------------------------

# ----------------- publication -----------------
# write.xlsx(table_list, file = paste0(output_folder, "/", publication_filename)) 

publication <- loadWorkbook(paste0(input_folder, "/", cover_sheet_filename))

addWorksheet(publication, "Notes")
addWorksheet(publication, "UK")
addWorksheet(publication, "England")
addWorksheet(publication, "Northern_Ireland")
addWorksheet(publication, "Scotland")
addWorksheet(publication, "Wales")
addWorksheet(publication, "Suspected_sources")

writeData(publication, "Notes", notes)
writeData(publication, "UK", uk)
writeData(publication, "England", england)
writeData(publication, "Northern_Ireland", ni)
writeData(publication, "Scotland", scotland)
writeData(publication, "Wales", wales)
writeData(publication, "Suspected_sources", sources_sheet_subset)

## create and add a style to the column headers
headerStyle_numbers <- createStyle(
  fontSize = 12, 
  halign = "right",
  textDecoration = "bold",
  wrapText = TRUE,
  fontName = "Arial"
)
headerStyle_text <- createStyle(
  fontSize = 12, 
  halign = "left",
  valign = "top",
  textDecoration = "bold",
  wrapText = TRUE,
  fontName = "Arial"
)
## style for body
bodyStyle_numbers <- createStyle(  
  fontSize = 12, 
  halign = "right",
  fontName = "Arial"
)
bodyStyle_text <- createStyle(  
  fontSize = 12, 
  halign = "left",
  wrapText = TRUE,
  fontName = "Arial"
)

# notes tab
addStyle(publication,
         sheet = 2, 
         cols = 1:2,
         rows = 4,
         headerStyle_text, 
         gridExpand = TRUE)

addStyle(publication,
         sheet = 8, 
         cols = 1:2,
         rows = 2:10,
         bodyStyle_text, 
         gridExpand = TRUE)

# sources tab
addStyle(publication,
         sheet = 8, 
         cols = 1:2,
         rows = 1,
         headerStyle_text, 
         gridExpand = TRUE)

addStyle(publication,
         sheet = 8, 
         cols = 1:2,
         rows = 2:(nrow(sources_sheet_subset) + 1),
         bodyStyle_text, 
         gridExpand = TRUE)

# data tables
for(i in 3:7) {
  addStyle(publication,
           sheet = i, 
           cols = 1:2,
           rows = 1,
           headerStyle_text, 
           gridExpand = TRUE)
  addStyle(publication,
           sheet = i, 
           cols = 3:4,
           rows = 1,
           headerStyle_numbers, 
           gridExpand = TRUE)
  
  addStyle(publication,
           sheet = i, 
           cols = 1:2,
           rows = 2:(nrow(uk) + 1),
           bodyStyle_text, 
           gridExpand = TRUE)
  addStyle(publication,
           sheet = i, 
           cols = 3:4,
           rows = 2:(nrow(uk) + 1),
           bodyStyle_numbers, 
           gridExpand = TRUE)
}

saveWorkbook(publication, 
             paste0(output_folder, "/", publication_filename))

# ----------------- csv and QA -----------------


write.csv(csv_output, paste0(output_folder, "/", csv_filename), row.names = FALSE)

rmarkdown::render('14-1-1b_checks.Rmd', output_file = paste0(output_folder, "/", qa_filename))

message(paste0("The tables for publication, csv, and QA files have been created 
               and saved in '", paste0(getwd(), "/", output_folder, "'"),
               " as ", csv_filename, "and ", qa_filename, "'\n\n"))

# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")
