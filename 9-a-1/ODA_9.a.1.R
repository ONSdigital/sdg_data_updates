# Author: Atanaska Nikolova (March 2022)
# function and code to get data for indicator 9.a.1 
# the function takes argument data_underlying_SID (as a csv file)
# output is year x income group (DAC classification) breakdown of net ODA in GBP (thousands)

# EDIT path below to point to your local repo (won't be needed when part of Rproject)
setwd("D:/SDG general/SDG_updates/sdg_data_updates/9-a-1") 


# main function to run ### test till the end after renaming sid sector


ODA_9.a.1 <- function(data_underlying_SID){
  colnames(data_underlying_SID)[ncol(data_underlying_SID)] <- "ODA"

  #renaming the SIDsector column to have a consistent name because it differs slightly between the two csv spreadsheets
  rows_to_rename <- which(grepl("Economic Infrastructure",data_underlying_SID$SIDsector))
  data_underlying_SID$SIDsector[rows_to_rename] <- "Economic Infrastructure" 
  SIDsector = "Economic Infrastructure"
  
  infrastructure <- aggregate(data_underlying_SID$ODA,
                            by = list(Year = data_underlying_SID$Year, 
                                    IncomeGroup = data_underlying_SID$IncomeGroup,
                                    SID_sector = data_underlying_SID$SIDsector==SIDsector), 
                            FUN = sum)
  infrastructure <- infrastructure[infrastructure$SID_sector==TRUE,]
  infrastructure[infrastructure$SID_sector==TRUE,"SID_sector"] <- "Economic Infrastructure and Services"
  colnames(infrastructure)[4] <- "Value"
  infrastructure[(infrastructure$IncomeGroup == "0" | infrastructure$IncomeGroup == "Part I unallocated by income"),
             "IncomeGroup"] <- "Unspecified"
  #add headline:
  headline<-aggregate(infrastructure$Value,
            by = list(Year = infrastructure$Year),
            FUN = sum)
  headline$IncomeGroup <- ""
  headline$SID_sector <- "Economic Infrastructure and Services"
  headline$Value <- headline$x
  headline <- headline[,-2]
  infrastructure <- rbind(infrastructure, headline)
  infrastructure$`Observation status` <- "Definition differs"
  infrastructure$`Unit multiplier` <- "Thousands"
  names(infrastructure)[names(infrastructure) == 'IncomeGroup'] <- 'Country income classification'
  infrastructure$Units <- "GBP (£ thousands)"
  
  # we don't need the SID sector column, so removing it
  infrastructure <- infrastructure[,-3]
  #reordering the columns to make compatible with csv
  infrastructure <- infrastructure[, c(1, 2, 4, 5, 6, 3)]
  infrastructure <- infrastructure[order(infrastructure$`Country income classification`),]
  
  return(infrastructure)
}


# example run on two separate SID files covering all available years:
# save the SID files (downloaded from Source 1) as .csv but BEFORE you do that:
# make sure the last column (the net ODA) is formatted as numbers and extend to 4 decimal places 
# the function takes arguments data_underlying_SID (the csv file in Inputs folder) 


infra_201720 <- ODA_9.a.1(data_underlying_SID = read.csv("./Example_input/dataunderSID-Final2020.csv", header=TRUE))
infra_200916 <- ODA_9.a.1(data_underlying_SID = read.csv("./Example_input/data-underlying-sid-2017.csv", header=TRUE)) 


# creating a final table to use in the Indicator csv
final_table <- rbind(infra_200916, infra_201720) 
final_table <- final_table[order(final_table$`Country income classification`),]

# Don't want to overwrite an Output folder that already exists, 
# or depend on the user having remembered to create an Output folder themselves
existing_files <- list.files()
output_folder_exists <- ifelse("Example_output" %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create("Example_output")
}

write.csv(final_table,"./Example_output/9.a.1.csv", row.names = FALSE)
