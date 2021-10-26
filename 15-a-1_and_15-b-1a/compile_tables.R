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

csv_formatted <- ODA_15.a.1(data_underlying_SID = read.csv(paste0(getwd(),"/Input/",filename), 
                                                           header=T))
csv_formatted$Units <- "GBP (£ Millions)"
csv_formatted$Series <- "Total official development assistance for biodiversity, by recipient countries"
csv_formatted$UnitMeasure <- "GBP"
csv_formatted$UnitMultiplier <- "Millions"
csv_formatted$ObservationStatus <- "Normal value"
csv_formatted <- csv_formatted[order(csv_formatted$IncomeGroup), ]

# reordering columns so they match with csv spreadsheet for indicator
csv_formatted <- csv_formatted[, c(1, 4, 5, 2, 6, 7, 8, 3)]
colnames(csv_formatted) <- c("Year",	"Units",	"Series", 
                             "Country income classification",	"Unit measure",	
                             "Unit multiplier",	"Observation status",	"Value")

date <- Sys.Date()
csv_filename <- paste0(date, "_15.a.1a_15.b.1a.csv")


write.csv(csv_formatted, paste0("Output/", csv_filename), row.names = FALSE)



# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")
