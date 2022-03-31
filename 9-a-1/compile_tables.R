# This file is directly called by update_indicator_main.R.
# It has to be called compile_tables.R
# It is the control script that runs all the others.



source("config.R") # pulls in all the configurations
source("update_9-a-1.R") # does the donkey-work of making the csv

# Using the sourced function, we run it on the two input files to get the final data for formatting
ind_9_a_1_200916 <- ODA_9.a.1(data_underlying_SID = read.csv(paste0(input_folder, "/", filename_1),
                                                             header=TRUE)) 
ind_9_a_1_201720 <- ODA_9.a.1(data_underlying_SID = read.csv(paste0(input_folder, "/", filename_2),
                                                             header=TRUE))


csv_formatted <- rbind(ind_9_a_1_200916, ind_9_a_1_201720) 
csv_formatted <- csv_formatted[order(csv_formatted$`Country income classification`),]



existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}

date <- Sys.Date()

# we add the date to the output file so that old outputs are not automatically overwritten.
# However, it shouldn't matter if they are overwritten, as files can easily be recreated with the code.
# We may want to review the decision to add date to the filename.
csv_filename <- paste0(date, "_update_9-a-1.csv")

write.csv(csv_formatted, paste0(output_folder, "/", csv_filename), row.names = FALSE)


message(paste0("The csv file has been created and saved in '", paste0(getwd(), "/", output_folder, "'"),
               " as ", csv_filename))

# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")
