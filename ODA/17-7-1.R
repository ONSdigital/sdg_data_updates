# Author: Atanaska Nikolova (August 2023)
# code to get data for indicator 17.7.1 
# the function takes arguments data_underlying_SID_1 and data_underlying_SID_2 (as csv files)
# These are the ods SID spreadsheets downloaded from the source (currently two sets covering all available years)
# save the SID file as .csv but BEFORE you do that:
#   make sure the last column (the net ODA) is formatted as numbers and extend to 4 decimal places 
# output is year x net ODA for Environmentally Sound Technologies (EST)


# example datasets SID files: #USE ODA renamed

data_underlying_SID_1 <- read.csv("D:\\SDG general\\SDG_updates\\dataunderSID-Final2020.csv",header=T)
data_underlying_SID_2 <- read.csv("D:\\SDG general\\SDG_updates\\data-underlying-sid-2017.csv",header=T)


ODA_17.7.1 <- function(data_underlying_SID_1,data_underlying_SID_2){
  ODA_datasets <- list(data_underlying_SID_1, data_underlying_SID_2)
  library(stringr)
  
  EST <- c("low carbon", "low-carbon", "clean technology", "environmental technology", 
           "green technology", "cleantech", "renewable energy", "wastewater management", 
           "wastewater treatment", "energy storage", "energy distribution", "water remediation",
           "bioenergy", "solar", "climate friendly","geothermal", "climate smart", "sustainable energy",
           "air pollution", "carbon footprint", "global emissions", "clean energy",
           "offshore wind", "wind energy", "wave energy", "hydropower", "sustainable sanitation", 
           "nuclear power", "biofuel", "atmospheric pollution", "biogas", "bio-energy", "photovoltaic", 
           "carbon reduction", "energy efficient", "biomass energy", "nanogrid", "nano-grid")
  
  
  #creating some empty lists that will be populated in the loop below
  SID_filtered <- vector(mode = "list", length = length(ODA_datasets))
  EST_funding <- vector(mode = "list", length = length(ODA_datasets))
  
  for(i in 1:length(ODA_datasets)){
    colnames(ODA_datasets[[i]])[ncol(ODA_datasets[[i]])] <- "ODA"
  
    ODA_datasets[[i]]$LongDescription <- tolower(ODA_datasets[[i]]$LongDescription)
    ODA_datasets[[i]]$ProjectTitle <- tolower(ODA_datasets[[i]]$ProjectTitle)
  
    ODA_datasets[[i]]$EST_ProjectTitle <- sapply(str_extract_all(ODA_datasets[[i]]$ProjectTitle, paste("\\b", EST, "\\b", sep="", collapse="|")), paste, collapse=",")
    ODA_datasets[[i]]$EST_LongDesc <- sapply(str_extract_all(ODA_datasets[[i]]$LongDescription, paste("\\b", EST, "\\b", sep="", collapse="|")), paste, collapse=",")
  
    SID_filtered[[i]] <- ODA_datasets[[i]][ODA_datasets[[i]]$EST_ProjectTitle != "" | ODA_datasets[[i]]$EST_LongDesc != "", ]
  
    EST_funding[[i]] <- aggregate(SID_filtered[[i]]$ODA,
                           by = list(Year = SID_filtered[[i]]$Year),
                           FUN = sum)
  
    colnames(EST_funding[[i]])[2] <- "Value"
  }
  EST_funding <- do.call("rbind", EST_funding)
  EST_funding <- EST_funding[order(EST_funding$Year),]
  return(EST_funding)
}

#example call
EST_funding <- ODA_17.7.1(data_underlying_SID_1, data_underlying_SID_2)

write.csv(EST_funding,"D:\\SDG general\\SDG_updates\\17.7.1.csv")
