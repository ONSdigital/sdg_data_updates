# This file is directly called by update_indicator_main.R.
# It has to be called compile_tables.R
# It is the control script that runs all the others.


source("config.R") # pulls in all the configurations
source("update_15.a.1a_15.b.1a.R") # does the donkey-work of making the csv

existing_files <- list.files()
output_folder_exists <- ifelse("Output" %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create("Output")
}

first_file <- read.csv(paste0(getwd(), "/", input_folder, "/", filename_1), header = TRUE)
second_file <- read.csv(paste0(getwd(), "/", input_folder, "/", filename_2), header = TRUE)
                                               
biodiversity_values_file_1 <- ODA_15.a.1(data_underlying_SID = first_file)
biodiversity_values_file_2 <- ODA_15.a.1(data_underlying_SID = second_file)

csv_formatted <- rbind(biodiversity_values_file_1, biodiversity_values_file_2)
csv_formatted$Units <- "GBP (£ Millions)"
csv_formatted$Series <- "Total official development assistance for biodiversity, by recipient countries"
csv_formatted$`Unit multiplier` <- "Millions"
csv_formatted$`Observation status` <- "Normal value"

#reordering the columns to make compatible with csv ordering
csv_formatted <- csv_formatted[, c(1, 5, 2, 4, 6, 7, 3)]
csv_formatted <- csv_formatted[order(csv_formatted$Year, csv_formatted$`Country income classification`), ]


date <- Sys.Date()
csv_filename <- paste0(date, "_15.a.1a_15.b.1a.csv")

write.csv(csv_formatted, paste0("Output/", csv_filename), row.names = FALSE)

message(paste0("The csv has been created and saved in '", paste0(getwd(), "/Output", "'"),
               " as ", csv_filename))

# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")
