source("config.R")

source("indicator.R")

# Don't want to overwrite an Output folder that already exists, or depend on the user having remembered to create an Output folder themselves
existing_files <- list.files()
output_folder_exists <- ifelse("Output" %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create("Output")
}

date_time <- Sys.time()
filename_date_time <- SDGupdater::create_datetime_for_filename(date_time)

csv_data_filename <- paste0(output_folder, '/', filename_date_time, "_4-b-1", ".csv")
# markdown_filename <- paste0(output_folder, '/', filename_date_time, "_4-b-1_QA", year, ".html")

write.csv(csv_data, csv_data_filename, row.names = FALSE)
# rmarkdown::render('QA.Rmd', output_file = markdown_filename)

message(paste0("csv has been created and saved in '", output_folder,
             "' as '", csv_data_filename, "\n\n"))#,
             # " Please also read the QA document '", markdown_filename, "'"))

# so we end on the same directory as we started:
setwd("./..")

