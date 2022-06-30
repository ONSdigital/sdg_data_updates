# Author: Emma Wood 
# Contact: emma.wood@ons.gov.uk
# compile tables for indicator 13-2-2


#--- get input from user ---
source("config.R") # pulls in all the configurations. Change to "config.R" for real update

if (SDGupdater::get_characters_after_dot(filename) != "xlsx") {
  stop(paste("File must be an xlsx file. Save", filename, "as an xlsx and re-run script"))
}

source("by_gas_type.R") 

existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}

date <- Sys.Date()

csv_filename <- paste0(date, "_13-2-2.csv")
# qa_filename <- paste0(date, "_update_type_1_checks.html") 

write.csv(csv_formatted, paste0(output_folder, "/", csv_filename), row.names = FALSE)


# rmarkdown::render('type_1_checks.Rmd', output_file = paste0(output_folder, "/", qa_filename))
# 
# message(paste0("The csv and QA file have been created and saved in '", paste0(getwd(), "/", output_folder, "'"),
#                " as ", csv_filename, "and ", qa_filename, "'\n\n"))

# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")


