# compile tables for 15.1.1


source("config.R")
source("update_15-1-1.R")

existing_files <- list.files()
output_folder_exists <- ifelse("Output" %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create("Output")
}


date <- Sys.Date()
csv_filename <- paste0(date, "_15-1-1.csv")
pre_calculations_filename <- paste0(date, "_before_calcs_15-1-1.csv")

write.csv(csv_formatted, paste0("Output/", csv_filename), row.names = FALSE)
write.csv(all_data, paste0("Output/", pre_calculations_filename), row.names = FALSE)

rmarkdown::render('15-1-1_checks.Rmd', output_file = paste0('Output/', date ,'_15-1-1_checks.html'))

message(paste0("csv has been created and saved in '", paste0(getwd(), "/Output"),
               "' as '", csv_filename, "'\n\n"))

# so we end on the same directory as we started:
setwd("..")

