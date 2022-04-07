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

first_input_file <- ODA_15.a.1(data_underlying_SID = read.csv(paste0(getwd(),"/",input_folder,"/",filename_1), 
                                                           header=T))
second_input_file <- ODA_15.a.1(data_underlying_SID = read.csv(paste0(getwd(),"/",input_folder,"/",filename_2), 
                                                              header=T))
csv_formatted <- rbind(first_input_file, second_input_file)
csv_formatted$Units <- "GBP (£ Millions)"
csv_formatted$Series <- "Total official development assistance for biodiversity, by recipient countries"
csv_formatted$UnitMultiplier <- "Millions"
csv_formatted$ObservationStatus <- "Normal value"

#reordering the columns to make compatible with csv ordering
csv_formatted <- csv_formatted[, c(1, 5, 2, 4, 6, 7, 3)]
csv_formatted <- csv_formatted[order(csv_formatted$Year, csv_formatted$`Country income classification`), ]


date <- Sys.Date()
csv_filename <- paste0(date, "_15.a.1a_15.b.1a.csv")


write.csv(csv_formatted, paste0("Output/", csv_filename), row.names = FALSE)



# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")
