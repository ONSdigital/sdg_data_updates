# compile tables for 15.1.1
library('SDGupdater')

packages <- c('openxlsx', 'stringr', 'janitor',
              'tidyr', 'dplyr', 
              'ggplot2', 'DT', 'pander')

install_absent_packages(packages)

source("config.R")
source("update_15-1-1.R")

existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}


date <- Sys.Date()
csv_filename <- paste0(date, "_15-1-1.csv")
pre_calculations_filename <- paste0(date, "_before_calcs_15-1-1.csv")

write.csv(csv_formatted, paste0(output_folder, "/", csv_filename), row.names = FALSE)
write.csv(all_data, paste0(output_folder, "/", pre_calculations_filename), row.names = FALSE)

rmarkdown::render('15-1-1_checks.Rmd', 
                  output_file = paste0(output_folder, '/', date ,'_15-1-1_checks.html'))

message(paste0("csv has been created and saved in '", 
               paste0(getwd(), "/", output_folder),
               "' as '", csv_filename, "'\n\n"))

# so we end on the same directory as we started:
setwd("..")

